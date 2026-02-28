import { supabase } from '../config/supabaseClient.js';

// ==================== ADD PRODUCT ====================
export const addProduct = async (req, res) => {
  try {
    console.log(' Add product request');
    console.log('Body:', req.body);
    
    const { 
      jeweller_id, 
      name, 
      description, 
      price,
      price_mode,
      category,
      metal_type,
      karat,
      weight_grams,
      making_charge,
      image_url,
      stock_quantity 
    } = req.body;

    // Validate
    if (!jeweller_id || !name || !description) {
      return res.status(400).json({
        success: false,
        message: 'jeweller_id, name, and description are required'
      });
    }

    // Check jeweller exists and is verified
    const { data: jeweller, error: jewellerError } = await supabase
      .from('users')
      .select('id, role, verified, verification_status')
      .eq('id', jeweller_id)
      .single();

    if (jewellerError || !jeweller) {
      console.log('❌ Jeweller not found');
      return res.status(404).json({
        success: false,
        message: 'Jeweller not found'
      });
    }

    if (jeweller.role !== 'jeweller') {
      return res.status(403).json({
        success: false,
        message: 'Only jewellers can add products'
      });
    }

    if (!jeweller.verified || jeweller.verification_status !== 'approved') {
      return res.status(403).json({
        success: false,
        message: 'Your account must be verified before adding products'
      });
    }

    // Insert product
    const { data: newProduct, error } = await supabase
      .from('products')
      .insert([{
        jeweller_id,
        name: name.trim(),
        description: description.trim(),
        price: price ? parseFloat(price) : null,
        price_mode: price_mode || 'show_price',
        category: category || null,
        metal_type: metal_type || 'Gold',
        karat: karat || null,
        weight: weight_grams ? parseFloat(weight_grams) : null,
        making_charge: making_charge ? parseFloat(making_charge) : null,
        image_url: image_url || null,
        primary_image_url: image_url || null,
        stock_quantity: stock_quantity || 1,
        is_available: true,
        is_active: true
      }])
      .select()
      .single();

    if (error) {
      console.error('❌ Database error:', error);
      throw error;
    }

    console.log(' Product created:', newProduct.id);

    return res.status(201).json({
      success: true,
      message: 'Product added successfully',
      product: newProduct
    });

  } catch (error) {
    console.error(' Add product error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// ==================== GET ALL PRODUCTS ====================
export const getAllProducts = async (req, res) => {
  try {
    console.log(' Get products');
    
    const { category, search, min_price, max_price } = req.query;

    let query = supabase
      .from('products')
      .select(`
        *,
        jeweller:users!products_jeweller_id_fkey(
          id,
          name,
          business_name,
          district,
          province,
          verified,
          phone,
          email
        )
      `)
      .eq('is_active', true);

    if (category && category !== 'All') {
      query = query.eq('category', category);
    }

    if (search) {
      query = query.or(`name.ilike.%${search}%,description.ilike.%${search}%`);
    }

    if (min_price) {
      query = query.gte('price', parseFloat(min_price));
    }

    if (max_price) {
      query = query.lte('price', parseFloat(max_price));
    }

    query = query.order('created_at', { ascending: false });

    const { data: products, error } = await query;

    if (error) throw error;

    console.log(`✅ Found ${products.length} products`);

    return res.status(200).json({
      success: true,
      count: products.length,
      products: products
    });

  } catch (error) {
    console.error('❌ Get products error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// ==================== GET SINGLE PRODUCT ====================
export const getProductById = async (req, res) => {
  try {
    const { id } = req.params;
    console.log('🔍 Get product:', id);

    const { data: product, error } = await supabase
      .from('products')
      .select(`
        *,
        jeweller:users!products_jeweller_id_fkey(
          id,
          name,
          business_name,
          district,
          province,
          verified,
          phone,
          email
        )
      `)
      .eq('id', id)
      .single();

    if (error || !product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Increment view count
    await supabase
      .from('products')
      .update({ total_views: (product.total_views || 0) + 1 })
      .eq('id', id);

    console.log(' Product found');

    return res.status(200).json({
      success: true,
      product: product
    });

  } catch (error) {
    console.error(' Get product error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// ==================== GET JEWELLER'S PRODUCTS ====================
export const getJewellerProducts = async (req, res) => {
  try {
    const { jeweller_id } = req.params;
    console.log(' Get jeweller products:', jeweller_id);

    const { data: products, error } = await supabase
      .from('products')
      .select('*')
      .eq('jeweller_id', jeweller_id)
      .order('created_at', { ascending: false });

    if (error) throw error;

    console.log(` Found ${products.length} products`);

    return res.status(200).json({
      success: true,
      count: products.length,
      products: products
    });

  } catch (error) {
    console.error(' Error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// ==================== UPDATE PRODUCT ====================
export const updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    console.log(' Update product:', id);

    const { data: existing, error: fetchError } = await supabase
      .from('products')
      .select('*')
      .eq('id', id)
      .single();

    if (fetchError || !existing) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    const updateData = { updated_at: new Date().toISOString() };
    
    Object.keys(req.body).forEach(key => {
      if (req.body[key] !== undefined) {
        if (key === 'weight_grams') {
          updateData.weight = parseFloat(req.body[key]);
        } else {
          updateData[key] = req.body[key];
        }
      }
    });

    const { data: updated, error } = await supabase
      .from('products')
      .update(updateData)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;

    console.log('✅ Product updated');

    return res.status(200).json({
      success: true,
      message: 'Product updated',
      product: updated
    });

  } catch (error) {
    console.error(' Update error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// ==================== TOGGLE VISIBILITY ====================
export const toggleProductVisibility = async (req, res) => {
  try {
    const { id } = req.params;
    console.log('👁️ Toggle visibility:', id);

    const { data: product, error: fetchError } = await supabase
      .from('products')
      .select('is_active')
      .eq('id', id)
      .single();

    if (fetchError || !product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    const newStatus = !product.is_active;

    const { data: updated, error } = await supabase
      .from('products')
      .update({ 
        is_active: newStatus,
        updated_at: new Date().toISOString()
      })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;

    console.log(`✅ Product ${newStatus ? 'shown' : 'hidden'}`);

    return res.status(200).json({
      success: true,
      message: `Product ${newStatus ? 'shown' : 'hidden'}`,
      product: updated
    });

  } catch (error) {
    console.error('❌ Toggle error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// ==================== DELETE PRODUCT ====================
export const deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;
    console.log('🗑️ Delete product:', id);

    const { data: existing, error: fetchError } = await supabase
      .from('products')
      .select('*')
      .eq('id', id)
      .single();

    if (fetchError || !existing) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    const { error } = await supabase
      .from('products')
      .delete()
      .eq('id', id);

    if (error) throw error;

    console.log('✅ Product deleted');

    return res.status(200).json({
      success: true,
      message: 'Product deleted'
    });

  } catch (error) {
    console.error('❌ Delete error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// ==================== GET CATEGORIES ====================
export const getCategories = async (req, res) => {
  try {
    const { data: products, error } = await supabase
      .from('products')
      .select('category')
      .not('category', 'is', null);

    if (error) throw error;

    const categories = [...new Set(products.map(p => p.category))].filter(Boolean);

    return res.status(200).json({
      success: true,
      count: categories.length,
      categories: categories
    });

  } catch (error) {
    console.error('❌ Get categories error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};