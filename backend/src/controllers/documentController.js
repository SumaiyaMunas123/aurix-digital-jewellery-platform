import { supabase } from '../config/supabaseClient.js';

// Upload documents(Jeweller) 
// Expects multipart/form-data with files keyed by document type
// This version accepts base64 or URLs (storage upload handled client-side via Supabase JS SDK)
// and saves the public URLs into the jeweller_documents table.
export const saveDocumentUrls = async (req, res) => {
  try {
    const jeweller_id = req.user?.id;
    if (!jeweller_id) {
      return res.status(401).json({ success: false, message: 'Unauthorised' });
    }

    const documents = req.body?.documents; // { key: publicUrl, ... }
    if (!documents || typeof documents !== 'object') {
      return res.status(400).json({ success: false, message: 'documents object is required' });
    }

    // Upsert document record for this jeweller
    const { data: existing } = await supabase
      .from('jeweller_documents')
      .select('id')
      .eq('jeweller_id', jeweller_id)
      .single();

    const payload = {
      jeweller_id,
      ...documents,
      updated_at: new Date().toISOString(),
    };

    let result;
    if (existing) {
      result = await supabase
        .from('jeweller_documents')
        .update(payload)
        .eq('jeweller_id', jeweller_id)
        .select()
        .single();
    } else {
      result = await supabase
        .from('jeweller_documents')
        .insert({ ...payload, submitted_at: new Date().toISOString() })
        .select()
        .single();
    }

    if (result.error) throw result.error;

    // Update verification_status back to 'pending' if they resubmit after rejection
    await supabase
      .from('users')
      .update({ verification_status: 'pending', rejected_at: null, rejection_reason: null })
      .eq('id', jeweller_id)
      .eq('verification_status', 'rejected');

    return res.status(200).json({
      success: true,
      message: 'Documents saved successfully',
      documents: result.data,
    });
  } catch (error) {
    console.error('saveDocumentUrls error:', error.message);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// Get documents (Jeweller) 
export const getMyDocuments = async (req, res) => {
  try {
    const jeweller_id = req.user?.id;
    if (!jeweller_id) return res.status(401).json({ success: false, message: 'Unauthorised' });

    const { data, error } = await supabase
      .from('jeweller_documents')
      .select('*')
      .eq('jeweller_id', jeweller_id)
      .single();

    if (error && error.code !== 'PGRST116') throw error; // PGRST116 = not found

    return res.status(200).json({ success: true, documents: data || null });
  } catch (error) {
    console.error('getMyDocuments error:', error.message);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// Get jeweller documents (Admin) 
export const getJewellerDocuments = async (req, res) => {
  try {
    const { jeweller_id } = req.params;

    const { data, error } = await supabase
      .from('jeweller_documents')
      .select('*')
      .eq('jeweller_id', jeweller_id)
      .single();

    if (error && error.code !== 'PGRST116') throw error;

    return res.status(200).json({ success: true, documents: data || null });
  } catch (error) {
    console.error('getJewellerDocuments error:', error.message);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// Add document feedback (Admin) 
export const addDocumentFeedback = async (req, res) => {
  try {
    const { jeweller_id } = req.params;
    const { document_key, feedback } = req.body;
    const admin_id = req.user?.id;

    if (!document_key || !feedback) {
      return res.status(400).json({ success: false, message: 'document_key and feedback are required' });
    }

    // Store feedback as JSONB column in jeweller_documents
    // First fetch existing feedback
    const { data: existing, error: fetchErr } = await supabase
      .from('jeweller_documents')
      .select('feedback')
      .eq('jeweller_id', jeweller_id)
      .single();

    if (fetchErr && fetchErr.code !== 'PGRST116') throw fetchErr;

    const currentFeedback = existing?.feedback || {};
    const updatedFeedback = {
      ...currentFeedback,
      [document_key]: {
        message: feedback,
        admin_id,
        created_at: new Date().toISOString(),
      },
    };

    const { data, error } = await supabase
      .from('jeweller_documents')
      .update({ feedback: updatedFeedback, updated_at: new Date().toISOString() })
      .eq('jeweller_id', jeweller_id)
      .select()
      .single();

    if (error) throw error;

    // Log admin action
    await logAdminAction({
      admin_id,
      jeweller_id,
      action: 'document_feedback',
      details: { document_key, feedback },
    });

    return res.status(200).json({ success: true, message: 'Feedback saved', documents: data });
  } catch (error) {
    console.error('addDocumentFeedback error:', error.message);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// Shared: admin action logging utility
export const logAdminAction = async ({ admin_id, jeweller_id, action, details = {} }) => {
  try {
    await supabase.from('admin_action_logs').insert({
      admin_id,
      jeweller_id,
      action,
      details,
      performed_at: new Date().toISOString(),
    });
  } catch (err) {
    console.error('⚠️ Failed to log admin action:', err.message);
  }
};

//  Get admin logs for a jeweller (Admin)
export const getAdminLogs = async (req, res) => {
  try {
    const { jeweller_id } = req.params;

    const { data, error } = await supabase
      .from('admin_action_logs')
      .select('*')
      .eq('jeweller_id', jeweller_id)
      .order('performed_at', { ascending: false });

    if (error) throw error;

    return res.status(200).json({ success: true, logs: data });
  } catch (error) {
    console.error('getAdminLogs error:', error.message);
    return res.status(500).json({ success: false, message: error.message });
  }
};