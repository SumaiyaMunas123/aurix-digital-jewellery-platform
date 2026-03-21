import { supabase } from '../config/supabaseClient.js';
import { logAdminAction } from './documentController.js';

// Get pending jewellers

export const getPendingJewellers = async (req, res) => {
  try {
    console.log('Get pending jewellers');

    const { data: jewellers, error } = await supabase
      .from('users')
      .select('*')
      .eq('role', 'jeweller')
      .eq('verification_status', 'pending')
      .order('created_at', { ascending: false });

    if (error) throw error;

    console.log(`Found ${jewellers.length} pending jewellers`);

    return res.status(200).json({
      success: true,
      count: jewellers.length,
      jewellers: jewellers
    });

  } catch (error) {
    console.error('Error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// Get all jewellers 
export const getAllJewellers = async (req, res) => {
  try {
    console.log('Get all jewellers');

    const { status } = req.query;

    let query = supabase
      .from('users')
      .select('*')
      .eq('role', 'jeweller')
      .order('created_at', { ascending: false });

    if (status) {
      query = query.eq('verification_status', status);
    }

    const { data: jewellers, error } = await query;

    if (error) throw error;

    console.log(`Found ${jewellers.length} jewellers`);

    return res.status(200).json({
      success: true,
      count: jewellers.length,
      jewellers: jewellers
    });

  } catch (error) {
    console.error('Error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// Get jeweller status

export const getJewellerStatus = async (req, res) => {
  try {
    const { jeweller_id } = req.params;
    console.log('🔍 Get status:', jeweller_id);

    const { data: jeweller, error } = await supabase
      .from('users')
      .select('id, verification_status, verified, rejection_reason')
      .eq('id', jeweller_id)
      .eq('role', 'jeweller')
      .single();

    if (error || !jeweller) {
      return res.status(404).json({
        success: false,
        message: 'Jeweller not found'
      });
    }

    console.log('Status:', jeweller.verification_status);

    return res.status(200).json({
      success: true,
      status: jeweller.verification_status,
      verified: jeweller.verified,
      rejection_reason: jeweller.rejection_reason
    });

  } catch (error) {
    console.error('Error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// Approve jeweller
export const approveJeweller = async (req, res) => {
  try {
    const { jeweller_id } = req.params;
    console.log('Approve jeweller:', jeweller_id);

    const { data: jeweller, error: fetchError } = await supabase
      .from('users')
      .select('*')
      .eq('id', jeweller_id)
      .eq('role', 'jeweller')
      .single();

    if (fetchError || !jeweller) {
      return res.status(404).json({
        success: false,
        message: 'Jeweller not found'
      });
    }

    const { data: updated, error } = await supabase
      .from('users')
      .update({
        verified: true,
        verification_status: 'approved',
        rejection_reason: null
      })
      .eq('id', jeweller_id)
      .select()
      .single();

    if (error) throw error;

    // Log the admin action
    await logAdminAction({
      admin_id: req.user?.id,
      jeweller_id,
      action: 'approved',
      details: { previous_status: jeweller.verification_status },
    });

    console.log('Jeweller approved');

    return res.status(200).json({
      success: true,
      message: 'Jeweller approved successfully',
      jeweller: updated
    });

  } catch (error) {
    console.error('Error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// Reject jeweller
export const rejectJeweller = async (req, res) => {
  try {
    const { jeweller_id } = req.params;
    const { reason } = req.body;
    
    console.log('Reject jeweller:', jeweller_id);

    if (!reason) {
      return res.status(400).json({
        success: false,
        message: 'Rejection reason is required'
      });
    }

    const { data: jeweller, error: fetchError } = await supabase
      .from('users')
      .select('*')
      .eq('id', jeweller_id)
      .eq('role', 'jeweller')
      .single();

    if (fetchError || !jeweller) {
      return res.status(404).json({
        success: false,
        message: 'Jeweller not found'
      });
    }

    const { data: updated, error } = await supabase
      .from('users')
      .update({
        verified: false,
        verification_status: 'rejected',
        rejection_reason: reason
      })
      .eq('id', jeweller_id)
      .select()
      .single();

    if (error) throw error;

    // Log the admin action
    await logAdminAction({
      admin_id: req.user?.id,
      jeweller_id,
      action: 'rejected',
      details: { reason, previous_status: jeweller.verification_status },
    });

    console.log('Jeweller rejected');

    return res.status(200).json({
      success: true,
      message: 'Jeweller rejected successfully',
      jeweller: updated
    });

  } catch (error) {
    console.error('Error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// Get stats
export const getPlatformStats = async (req, res) => {
  try {
    console.log('Get stats');

    const [
      { count: totalCustomers },
      { count: totalJewellers },
      { count: approvedJewellers },
      { count: pendingJewellers },
      { count: totalProducts }
    ] = await Promise.all([
      supabase.from('users').select('*', { count: 'exact', head: true }).eq('role', 'customer'),
      supabase.from('users').select('*', { count: 'exact', head: true }).eq('role', 'jeweller'),
      supabase.from('users').select('*', { count: 'exact', head: true }).eq('role', 'jeweller').eq('verified', true),
      supabase.from('users').select('*', { count: 'exact', head: true }).eq('role', 'jeweller').eq('verification_status', 'pending'),
      supabase.from('products').select('*', { count: 'exact', head: true })
    ]);

    const stats = {
      totalCustomers: totalCustomers || 0,
      totalJewellers: totalJewellers || 0,
      approvedJewellers: approvedJewellers || 0,
      pendingJewellers: pendingJewellers || 0,
      totalProducts: totalProducts || 0
    };

    console.log('Stats:', stats);

    return res.status(200).json({
      success: true,
      stats: stats
    });

  } catch (error) {
    console.error('Error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};