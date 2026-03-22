import { supabase } from '../config/supabaseClient.js';

export const adminGetAllOrders = async (req, res) => {
  try {
    const { search, status, page = 1, limit = 20 } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);

    let query = supabase
      .from('orders')
      .select(`
        id, order_number, quantity, unit_price, total_price,
        status, created_at, updated_at,
        customer:users!orders_customer_id_fkey(id, name, email, phone),
        jeweller:users!orders_jeweller_id_fkey(id, name, business_name, email, phone),
        product:products!orders_product_id_fkey(id, name, category, primary_image_url, image_url)
      `, { count: 'exact' });

    if (search) {
      query = query.or(`order_number.ilike.%${search}%`);
    }
    if (status) {
      query = query.eq('status', status);
    }

    query = query
      .order('created_at', { ascending: false })
      .range(offset, offset + parseInt(limit) - 1);

    const { data: orders, error, count } = await query;
    if (error) throw error;

    return res.status(200).json({
      success: true,
      count,
      page: parseInt(page),
      limit: parseInt(limit),
      totalPages: Math.ceil((count || 0) / parseInt(limit)),
      orders: orders || [],
    });

  } catch (error) {
    console.error('adminGetAllOrders error:', error.message);
    return res.status(500).json({ success: false, message: error.message });
  }
};

export const adminGetOrderById = async (req, res) => {
  try {
    const { id } = req.params;

    const { data: order, error } = await supabase
      .from('orders')
      .select(`
        *,
        customer:users!orders_customer_id_fkey(id, name, email, phone),
        jeweller:users!orders_jeweller_id_fkey(id, name, business_name, email, phone),
        product:products!orders_product_id_fkey(id, name, category, price, primary_image_url, image_url)
      `)
      .eq('id', id)
      .single();

    if (error || !order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    return res.status(200).json({ success: true, order });

  } catch (error) {
    console.error('adminGetOrderById error:', error.message);
    return res.status(500).json({ success: false, message: error.message });
  }
};

export const adminGetOrderStats = async (req, res) => {
  try {
    const [
      { count: total },
      { count: pending_payment },
      { count: payment_confirmed },
      { count: processing },
      { count: in_production },
      { count: ready_for_pickup },
      { count: completed },
      { count: cancelled },
    ] = await Promise.all([
      supabase.from('orders').select('*', { count: 'exact', head: true }),
      supabase.from('orders').select('*', { count: 'exact', head: true }).eq('status', 'pending_payment'),
      supabase.from('orders').select('*', { count: 'exact', head: true }).eq('status', 'payment_confirmed'),
      supabase.from('orders').select('*', { count: 'exact', head: true }).eq('status', 'processing'),
      supabase.from('orders').select('*', { count: 'exact', head: true }).eq('status', 'in_production'),
      supabase.from('orders').select('*', { count: 'exact', head: true }).eq('status', 'ready_for_pickup'),
      supabase.from('orders').select('*', { count: 'exact', head: true }).eq('status', 'completed'),
      supabase.from('orders').select('*', { count: 'exact', head: true }).eq('status', 'cancelled'),
    ]);

    return res.status(200).json({
      success: true,
      stats: {
        total: total || 0,
        pending_payment: pending_payment || 0,
        payment_confirmed: payment_confirmed || 0,
        processing: processing || 0,
        in_production: in_production || 0,
        ready_for_pickup: ready_for_pickup || 0,
        completed: completed || 0,
        cancelled: cancelled || 0,
      },
    });

  } catch (error) {
    console.error('adminGetOrderStats error:', error.message);
    return res.status(500).json({ success: false, message: error.message });
  }
};

export const adminUpdateOrderStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, note } = req.body;

    const validStatuses = [
      'pending_payment', 'payment_confirmed', 'processing',
      'in_production', 'ready_for_pickup', 'completed', 'cancelled'
    ];

    if (!status || !validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Invalid status. Must be one of: ${validStatuses.join(', ')}`
      });
    }

    const { data: existing, error: fetchError } = await supabase
      .from('orders')
      .select('id, order_number, status')
      .eq('id', id)
      .single();

    if (fetchError || !existing) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    const updateData = {
      status,
      updated_at: new Date().toISOString(),
    };

    if (status === 'payment_confirmed') updateData.payment_confirmed_at = new Date().toISOString();
    if (status === 'in_production')     updateData.started_production_at = new Date().toISOString();
    if (status === 'ready_for_pickup')  updateData.ready_at = new Date().toISOString();
    if (status === 'completed')         updateData.completed_at = new Date().toISOString();
    if (status === 'cancelled') {
      updateData.cancelled_at = new Date().toISOString();
      if (note) updateData.cancellation_reason = note;
    }
    if (note && status !== 'cancelled') updateData.jeweller_notes = note;

    const { data: updated, error } = await supabase
      .from('orders')
      .update(updateData)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;

    return res.status(200).json({
      success: true,
      message: `Order status updated to ${status}`,
      order: updated,
    });

  } catch (error) {
    console.error('adminUpdateOrderStatus error:', error.message);
    return res.status(500).json({ success: false, message: error.message });
  }
};

export const adminDeleteOrder = async (req, res) => {
  try {
    const { id } = req.params;

    const { data: existing, error: fetchError } = await supabase
      .from('orders').select('id, order_number').eq('id', id).single();

    if (fetchError || !existing) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    const { error } = await supabase.from('orders').delete().eq('id', id);
    if (error) throw error;

    return res.status(200).json({
      success: true,
      message: `Order ${existing.order_number} deleted successfully`,
    });

  } catch (error) {
    console.error('adminDeleteOrder error:', error.message);
    return res.status(500).json({ success: false, message: error.message });
  }
};