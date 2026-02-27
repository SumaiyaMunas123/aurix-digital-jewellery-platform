import { supabase } from '../config/supabaseClient.js';

// ==================== GET ALL PENDING JEWELLERS ====================
export const getPendingJewellers = async (req, res) => {
  try {
    console.log('📋 Fetching pending jewellers...');
    
    const { data: jewellers, error } = await supabase
      .from('users')
      .select('id, email, name, phone, business_name, business_registration_number, certification_document_url, created_at')
      .eq('role', 'jeweller')
      .eq('verification_status', 'pending')
      .order('created_at', { ascending: false });

    if (error) throw error;

    console.log(`✅ Found ${jewellers.length} pending jewellers`);

    res.status(200).json({
      success: true,
      count: jewellers.length,
      jewellers: jewellers
    });

  } catch (error) {
    console.error('❌ Error fetching pending jewellers:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching pending jewellers',
      error: error.message
    });
  }
};

// ==================== GET ALL JEWELLERS (ALL STATUSES) ====================
export const getAllJewellers = async (req, res) => {
  try {
    console.log('📋 Fetching all jewellers...');
    
    const { data: jewellers, error } = await supabase
      .from('users')
      .select('id, email, name, phone, business_name, business_registration_number, verification_status, verified, created_at, verified_at')
      .eq('role', 'jeweller')
      .order('created_at', { ascending: false });

    if (error) throw error;

    console.log(`✅ Found ${jewellers.length} jewellers`);

    res.status(200).json({
      success: true,
      count: jewellers.length,
      jewellers: jewellers
    });

  } catch (error) {
    console.error('❌ Error fetching jewellers:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching jewellers',
      error: error.message
    });
  }
};

// ==================== APPROVE JEWELLER ====================
export const approveJeweller = async (req, res) => {
  try {
    const { jeweller_id } = req.params;
    const { admin_id } = req.body; // ID of admin who approved (optional for now)

    console.log(`✅ Approving jeweller ID: ${jeweller_id}`);

    // First, check if jeweller exists and is pending
    const { data: existingJeweller, error: fetchError } = await supabase
      .from('users')
      .select('*')
      .eq('id', jeweller_id)
      .eq('role', 'jeweller')
      .single();

    if (fetchError || !existingJeweller) {
      console.log('❌ Jeweller not found');
      return res.status(404).json({
        success: false,
        message: 'Jeweller not found'
      });
    }

    if (existingJeweller.verification_status !== 'pending') {
      console.log('⚠️ Jeweller already processed:', existingJeweller.verification_status);
      return res.status(400).json({
        success: false,
        message: `Jeweller is already ${existingJeweller.verification_status}`
      });
    }

    // Update jeweller status to approved
    const { data: updatedUser, error } = await supabase
      .from('users')
      .update({
        verification_status: 'approved',
        verified: true,
        verified_at: new Date().toISOString(),
        verified_by: admin_id || null
      })
      .eq('id', jeweller_id)
      .eq('role', 'jeweller')
      .select()
      .single();

    if (error) throw error;

    console.log('✅ Jeweller approved successfully:', updatedUser.email);

    res.status(200).json({
      success: true,
      message: 'Jeweller approved successfully',
      user: {
        id: updatedUser.id,
        email: updatedUser.email,
        name: updatedUser.name,
        business_name: updatedUser.business_name,
        verification_status: updatedUser.verification_status,
        verified: updatedUser.verified,
        verified_at: updatedUser.verified_at
      }
    });

  } catch (error) {
    console.error('❌ Error approving jeweller:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while approving jeweller',
      error: error.message
    });
  }
};

// ==================== REJECT JEWELLER ====================
export const rejectJeweller = async (req, res) => {
  try {
    const { jeweller_id } = req.params;
    const { admin_id, reason } = req.body;

    console.log(`❌ Rejecting jeweller ID: ${jeweller_id}`);

    if (!reason || reason.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Please provide a reason for rejection'
      });
    }

    // First, check if jeweller exists and is pending
    const { data: existingJeweller, error: fetchError } = await supabase
      .from('users')
      .select('*')
      .eq('id', jeweller_id)
      .eq('role', 'jeweller')
      .single();

    if (fetchError || !existingJeweller) {
      console.log('❌ Jeweller not found');
      return res.status(404).json({
        success: false,
        message: 'Jeweller not found'
      });
    }

    if (existingJeweller.verification_status !== 'pending') {
      console.log('⚠️ Jeweller already processed:', existingJeweller.verification_status);
      return res.status(400).json({
        success: false,
        message: `Jeweller is already ${existingJeweller.verification_status}`
      });
    }

    // Update jeweller status to rejected
    const { data: updatedUser, error } = await supabase
      .from('users')
      .update({
        verification_status: 'rejected',
        verified: false,
        rejection_reason: reason.trim(),
        verified_at: new Date().toISOString(),
        verified_by: admin_id || null
      })
      .eq('id', jeweller_id)
      .eq('role', 'jeweller')
      .select()
      .single();

    if (error) throw error;

    console.log('❌ Jeweller rejected:', updatedUser.email);

    res.status(200).json({
      success: true,
      message: 'Jeweller rejected',
      user: {
        id: updatedUser.id,
        email: updatedUser.email,
        name: updatedUser.name,
        business_name: updatedUser.business_name,
        verification_status: updatedUser.verification_status,
        verified: updatedUser.verified,
        rejection_reason: updatedUser.rejection_reason,
        verified_at: updatedUser.verified_at
      }
    });

  } catch (error) {
    console.error('❌ Error rejecting jeweller:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while rejecting jeweller',
      error: error.message
    });
  }
};

// ==================== GET VERIFICATION STATUS ====================
export const getVerificationStatus = async (req, res) => {
  try {
    const { jeweller_id } = req.params;

    console.log(`🔍 Checking verification status for: ${jeweller_id}`);

    const { data: jeweller, error } = await supabase
      .from('users')
      .select('id, verification_status, rejection_reason, verified_at, verified')
      .eq('id', jeweller_id)
      .eq('role', 'jeweller')
      .single();

    if (error || !jeweller) {
      console.log('❌ Jeweller not found');
      return res.status(404).json({
        success: false,
        message: 'Jeweller not found'
      });
    }

    console.log(`✅ Status: ${jeweller.verification_status}`);

    res.status(200).json({
      success: true,
      status: jeweller.verification_status,
      verified: jeweller.verified,
      rejection_reason: jeweller.rejection_reason,
      verified_at: jeweller.verified_at
    });

  } catch (error) {
    console.error('❌ Error checking verification status:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while checking verification status',
      error: error.message
    });
  }
};

// ==================== GET JEWELLER DETAILS ====================
export const getJewellerDetails = async (req, res) => {
  try {
    const { jeweller_id } = req.params;

    console.log(`📄 Fetching details for jeweller: ${jeweller_id}`);

    const { data: jeweller, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', jeweller_id)
      .eq('role', 'jeweller')
      .single();

    if (error || !jeweller) {
      console.log('❌ Jeweller not found');
      return res.status(404).json({
        success: false,
        message: 'Jeweller not found'
      });
    }

    // Don't send password
    delete jeweller.password;

    console.log(`✅ Found jeweller: ${jeweller.email}`);

    res.status(200).json({
      success: true,
      jeweller: jeweller
    });

  } catch (error) {
    console.error('❌ Error fetching jeweller details:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching jeweller details',
      error: error.message
    });
  }
};