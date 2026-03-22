import { supabase } from '../config/supabaseClient.js';

// ==================== GET ALL PRODUCTS (ADMIN VIEW) ====================
export const adminGetAllProducts = async (req, res) => {
  try {
    const { search, category, admin_status, is_active, page = 1, limit = 20 } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);

    let query = supabase
      .from('products')
      .select(`
        id, name, description, category, price, price_mode,
        metal_type, karat, weight, stock_quantity, sku, rejection_reason,
        is_active, is_available, primary_image_url, image_url,
        total_views, total_sold, admin_status,
        created_at, updated_at, jeweller_id,
        jeweller:users!products_jeweller_id_fkey(
          id, name, business_name, email, phone,
          district, province, verified, verification_status
        )
      `, { count: 'exact' });

    if (search) query = query.or(`name.ilike.%${search}%,description.ilike.%${search}%`);
    if (category && category !== 'All') query = query.eq('category', category);
    if (admin_status) query = query.eq('admin_status', admin_status);
    if (is_active !== undefined && is_active !== '') query = query.eq('is_active', is_active === 'true');

    query = query
      .order('created_at', { ascending: false })
      .range(offset, offset + parseInt(limit) - 1);

    const { data: products, error, count } = await query;
    if (error) throw error;

    return res.status(200).json({
      success: true,
      count,
      page: parseInt(page),
      limit: parseInt(limit),
      totalPages: Math.ceil(count / parseInt(limit)),
      products: products || [],
    });

  } catch (error) {
    console.error('adminGetAllProducts error:', error.message);
    return res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
};

// ==================== GET SINGLE PRODUCT (ADMIN) ====================
export const adminGetProductById = async (req, res) => {
  try {
    const { id } = req.params;

    const { data: product, error } = await supabase
      .from('products')
      .select(`
        *,
        jeweller:users!products_jeweller_id_fkey(
          id, name, business_name, email, phone, district, province,
          verified, verification_status
        )
      `)
      .eq('id', id)
      .single();

    if (error || !product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    return res.status(200).json({ success: true, product });

  } catch (error) {
    console.error('adminGetProductById error:', error.message);
    return res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
};

// ==================== APPROVE PRODUCT ====================
// Pending → Approved  OR  Flagged → Approved
// Sets is_active: true so the product becomes visible to buyers.
export const adminApproveProduct = async (req, res) => {
  try {
    const { id } = req.params;

    const { data: existing, error: fetchError } = await supabase
      .from('products')
      .select('id, name, admin_status, jeweller_id, stock_quantity')
      .eq('id', id)
      .single();

    if (fetchError || !existing) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    if (existing.admin_status === 'approved') {
      return res.status(400).json({ success: false, message: 'Product is already approved' });
    }

    // A product with 0 stock cannot be made live — keep it flagged
    if ((existing.stock_quantity || 0) === 0) {
      return res.status(400).json({
        success: false,
        message: 'Cannot approve a product with 0 stock. The jeweller must restock first.',
      });
    }

    const { data: updated, error } = await supabase
      .from('products')
      .update({
        admin_status: 'approved',
        is_active: true,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;

    // Log action
    await supabase.from('admin_product_actions').insert([{
      admin_id: req.user.id,
      product_id: id,
      jeweller_id: existing.jeweller_id,
      action: 'approved',
      details: { product_name: existing.name, previous_status: existing.admin_status },
    }]);

    return res.status(200).json({
      success: true,
      message: 'Product approved and is now visible to buyers',
      product: updated,
    });

  } catch (error) {
    console.error('adminApproveProduct error:', error.message);
    return res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
};

// ==================== REJECT PRODUCT ====================
// Pending → Rejected  OR  Flagged → Rejected
// Sets is_active: false so product is hidden from buyers.
export const adminRejectProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    const { data: existing, error: fetchError } = await supabase
      .from('products')
      .select('id, name, admin_status, jeweller_id')
      .eq('id', id)
      .single();

    if (fetchError || !existing) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    if (existing.admin_status === 'rejected') {
      return res.status(400).json({ success: false, message: 'Product is already rejected' });
    }

    const { data: updated, error } = await supabase
      .from('products')
      .update({
        admin_status: 'rejected',
        is_active: false,
        rejection_reason: reason || null,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;

    // Log action
    await supabase.from('admin_product_actions').insert([{
      admin_id: req.user.id,
      product_id: id,
      jeweller_id: existing.jeweller_id,
      action: 'rejected',
      details: { product_name: existing.name, previous_status: existing.admin_status, reason: reason || null },
    }]);

    return res.status(200).json({
      success: true,
      message: 'Product rejected and hidden from buyers',
      product: updated,
    });

  } catch (error) {
    console.error('adminRejectProduct error:', error.message);
    return res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
};

// ==================== DELETE PRODUCT ====================
export const adminDeleteProduct = async (req, res) => {
  try {
    const { id } = req.params;

    const { data: existing, error: fetchError } = await supabase
      .from('products').select('id, name, jeweller_id').eq('id', id).single();

    if (fetchError || !existing) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    const { error } = await supabase.from('products').delete().eq('id', id);
    if (error) throw error;

    await supabase.from('admin_product_actions').insert([{
      admin_id: req.user.id,
      product_id: id,
      jeweller_id: existing.jeweller_id,
      action: 'deleted',
      details: { product_name: existing.name },
    }]);

    return res.status(200).json({ success: true, message: 'Product deleted successfully' });

  } catch (error) {
    console.error('adminDeleteProduct error:', error.message);
    return res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
};

// ==================== TOGGLE VISIBILITY ====================
export const adminToggleProductVisibility = async (req, res) => {
  try {
    const { id } = req.params;
    const { is_active } = req.body;

    const { data: existing, error: fetchError } = await supabase
      .from('products').select('id, name, is_active, jeweller_id').eq('id', id).single();

    if (fetchError || !existing) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    const newStatus = is_active !== undefined ? Boolean(is_active) : !existing.is_active;

    const { data: updated, error } = await supabase
      .from('products')
      .update({ is_active: newStatus, updated_at: new Date().toISOString() })
      .eq('id', id).select().single();

    if (error) throw error;

    await supabase.from('admin_product_actions').insert([{
      admin_id: req.user.id,
      product_id: id,
      jeweller_id: existing.jeweller_id,
      action: newStatus ? 'shown' : 'hidden',
      details: { product_name: existing.name, previous_status: existing.is_active },
    }]);

    return res.status(200).json({
      success: true,
      message: `Product ${newStatus ? 'shown' : 'hidden'} successfully`,
      product: updated,
    });

  } catch (error) {
    console.error('adminToggleProductVisibility error:', error.message);
    return res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
};

// ==================== STATS ====================
export const adminGetProductStats = async (req, res) => {
  try {
    const [
      { count: total },
      { count: approved },
      { count: pending },
      { count: flagged },
      { count: rejected },
      { data: topViewed },
      { data: topSold },
    ] = await Promise.all([
      supabase.from('products').select('*', { count: 'exact', head: true }),
      supabase.from('products').select('*', { count: 'exact', head: true }).eq('admin_status', 'approved'),
      supabase.from('products').select('*', { count: 'exact', head: true }).eq('admin_status', 'pending'),
      supabase.from('products').select('*', { count: 'exact', head: true }).eq('admin_status', 'flagged'),
      supabase.from('products').select('*', { count: 'exact', head: true }).eq('admin_status', 'rejected'),
      supabase.from('products')
        .select('id, name, total_views, primary_image_url, jeweller:users!products_jeweller_id_fkey(business_name, name)')
        .order('total_views', { ascending: false }).limit(5),
      supabase.from('products')
        .select('id, name, total_sold, primary_image_url, jeweller:users!products_jeweller_id_fkey(business_name, name)')
        .order('total_sold', { ascending: false }).limit(5),
    ]);

    return res.status(200).json({
      success: true,
      stats: {
        total: total || 0,
        approved: approved || 0,
        pending: pending || 0,
        flagged: flagged || 0,
        rejected: rejected || 0,
      },
      topViewed: topViewed || [],
      topSold: topSold || [],
    });

  } catch (error) {
    console.error('adminGetProductStats error:', error.message);
    return res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
};

// ==================== PRODUCTS BY JEWELLER (ADMIN) ====================
export const adminGetProductsByJeweller = async (req, res) => {
  try {
    const { jeweller_id } = req.params;

    const { data: products, error } = await supabase
      .from('products').select('*').eq('jeweller_id', jeweller_id)
      .order('created_at', { ascending: false });

    if (error) throw error;

    return res.status(200).json({ success: true, count: products.length, products: products || [] });

  } catch (error) {
    console.error('adminGetProductsByJeweller error:', error.message);
    return res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
};