import { supabase } from '../config/supabaseClient.js';

const MAX_MESSAGE_LENGTH = 2000;

// Single, consistent participant check used throughout the file
const isThreadParticipant = (thread, userId) => {
  return userId === thread.customer_id || userId === thread.jeweller_id;
};

const syncThreadUnreadCounts = async (thread) => {
  const { data: unreadMessages, error: unreadError } = await supabase
    .from('chat_messages')
    .select('sender_id')
    .eq('thread_id', thread.id)
    .eq('is_read', false);

  if (unreadError) throw unreadError;

  let unreadByCustomer = 0;
  let unreadByJeweller = 0;

  for (const unreadMessage of unreadMessages || []) {
    if (unreadMessage.sender_id === thread.jeweller_id) {
      unreadByCustomer += 1;
    }
    if (unreadMessage.sender_id === thread.customer_id) {
      unreadByJeweller += 1;
    }
  }

  const { error: syncError } = await supabase
    .from('chat_threads')
    .update({
      unread_by_customer: unreadByCustomer,
      unread_by_jeweller: unreadByJeweller,
      updated_at: new Date().toISOString()
    })
    .eq('id', thread.id);

  if (syncError) throw syncError;

  return {
    unread_by_customer: unreadByCustomer,
    unread_by_jeweller: unreadByJeweller
  };
};

// ==================== START/GET CHAT THREAD ====================
export const startChat = async (req, res) => {
  try {
    const customer_id = req.user?.id;
    const { jeweller_id, product_id } = req.body;

    console.log('💬 Start chat request');
    console.log('Customer:', customer_id);
    console.log('Jeweller:', jeweller_id);
    console.log('Product:', product_id || 'none');

    if (!customer_id || !jeweller_id) {
      return res.status(400).json({
        success: false,
        message: 'Authenticated customer and jeweller_id are required'
      });
    }

    let query = supabase
      .from('chat_threads')
      .select(`
        *,
        customer:users!chat_threads_customer_id_fkey(id, name, email),
        jeweller:users!chat_threads_jeweller_id_fkey(id, name, business_name, phone),
        product:products(id, name, price, primary_image_url)
      `)
      .eq('customer_id', customer_id)
      .eq('jeweller_id', jeweller_id);

    if (product_id) {
      query = query.eq('product_id', product_id);
    } else {
      query = query.is('product_id', null);
    }

    const { data: existingThread, error: fetchError } = await query.maybeSingle();

    if (existingThread) {
      console.log('✅ Chat thread already exists:', existingThread.id);
      return res.status(200).json({
        success: true,
        message: 'Chat thread exists',
        thread: existingThread
      });
    }

    const { data: newThread, error: createError } = await supabase
      .from('chat_threads')
      .insert([{
        customer_id,
        jeweller_id,
        product_id: product_id || null,
        status: 'active',
        subject: product_id ? 'Product Inquiry' : 'General Inquiry',
        last_message: null,
        last_message_at: new Date().toISOString(),
        last_message_by: null,
        unread_by_customer: 0,
        unread_by_jeweller: 0,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select(`
        *,
        customer:users!chat_threads_customer_id_fkey(id, name, email),
        jeweller:users!chat_threads_jeweller_id_fkey(id, name, business_name, phone),
        product:products(id, name, price, primary_image_url)
      `)
      .single();

    if (createError) throw createError;

    console.log('✅ New chat thread created:', newThread.id);

    return res.status(201).json({
      success: true,
      message: 'Chat thread created',
      thread: newThread
    });

  } catch (error) {
    console.error('❌ Start chat error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// ==================== SEND MESSAGE ====================
export const sendMessage = async (req, res) => {
  try {
    const sender_id = req.user?.id;
    const {
      thread_id,
      message,
      message_type = 'text',
      file_url = null,
      quotation_id = null,
      ai_design_id = null
    } = req.body;

    console.log('💬 Send message');
    console.log('Thread:', thread_id);
    console.log('Sender:', sender_id);
    console.log('Type:', message_type);

    if (!thread_id || !sender_id) {
      return res.status(400).json({
        success: false,
        message: 'thread_id is required'
      });
    }

    if (message && message.length > MAX_MESSAGE_LENGTH) {
      return res.status(400).json({
        success: false,
        message: `Message exceeds max length of ${MAX_MESSAGE_LENGTH} characters`
      });
    }

    if (!message && !file_url && !quotation_id && !ai_design_id) {
      return res.status(400).json({
        success: false,
        message: 'Message content is required (message, file_url, quotation_id, or ai_design_id)'
      });
    }

    const { data: thread, error: threadError } = await supabase
      .from('chat_threads')
      .select('*')
      .eq('id', thread_id)
      .single();

    if (threadError || !thread) {
      return res.status(404).json({
        success: false,
        message: 'Chat thread not found'
      });
    }

    // FIX: removed duplicate/unclosed if block (isThreadMember + isThreadParticipant)
    if (!isThreadParticipant(thread, sender_id)) {
      return res.status(403).json({
        success: false,
        message: 'You are not part of this chat'
      });
    }

    const { data: newMessage, error: messageError } = await supabase
      .from('chat_messages')
      .insert([{
        thread_id,
        sender_id,
        message_text: message ? message.trim() : null,
        message_type,
        file_url,
        quotation_id,
        ai_design_id,
        is_read: false,
        read_at: null,
        created_at: new Date().toISOString()
      }])
      .select(`
        *,
        sender:users(id, name, role, business_name)
      `)
      .single();

    if (messageError) throw messageError;

    const updateData = {
      last_message: message ? message.trim().substring(0, 100) : `[${message_type}]`,
      last_message_at: new Date().toISOString(),
      last_message_by: sender_id,
      updated_at: new Date().toISOString()
    };

    const { error: threadUpdateError } = await supabase
      .from('chat_threads')
      .update(updateData)
      .eq('id', thread_id);

    if (threadUpdateError) throw threadUpdateError;

    await syncThreadUnreadCounts(thread);

    console.log('✅ Message sent:', newMessage.id);

    return res.status(201).json({
      success: true,
      message: 'Message sent',
      data: newMessage
    });

  } catch (error) {
    console.error('❌ Send message error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// ==================== GET CHAT THREADS ====================
export const getChatThreads = async (req, res) => {
  try {
    const { user_id } = req.params;
    const { status = 'active' } = req.query;

    if (req.user?.id !== user_id) {
      return res.status(403).json({
        success: false,
        message: 'You can only access your own chat threads'
      });
    }

    console.log('📋 Get chat threads for user:', user_id);

    let query = supabase
      .from('chat_threads')
      .select(`
        *,
        customer:users!chat_threads_customer_id_fkey(id, name, email),
        jeweller:users!chat_threads_jeweller_id_fkey(id, name, business_name, phone),
        product:products(id, name, price, primary_image_url)
      `)
      .or(`customer_id.eq.${user_id},jeweller_id.eq.${user_id}`)
      .order('last_message_at', { ascending: false });

    if (status) {
      query = query.eq('status', status);
    }

    const { data: threads, error } = await query;

    if (error) throw error;

    const threadsWithUnread = threads.map(thread => {
      const isCustomer = thread.customer_id === user_id;
      const unreadCount = isCustomer ? thread.unread_by_customer : thread.unread_by_jeweller;

      return {
        ...thread,
        unread_count: unreadCount || 0,
        unreadCount: unreadCount || 0
      };
    });

    console.log(`✅ Found ${threads.length} chat threads`);

    return res.status(200).json({
      success: true,
      threads: threadsWithUnread
    });

  } catch (error) {
    console.error('❌ Get threads error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// ==================== GET MESSAGES ====================
export const getMessages = async (req, res) => {
  try {
    const { thread_id } = req.params;
    // FIX: removed duplicate variable declarations — parse limit/offset once, correctly
    const parsedLimit = Number.parseInt(req.query.limit, 10);
    const parsedOffset = Number.parseInt(req.query.offset, 10);
    const limit = Number.isFinite(parsedLimit) ? Math.min(Math.max(parsedLimit, 1), 100) : 50;
    const offset = Number.isFinite(parsedOffset) ? Math.max(parsedOffset, 0) : 0;
    const user_id = req.query.user_id;

    console.log('💬 Get messages for thread:', thread_id);

    const { data: thread, error: threadError } = await supabase
      .from('chat_threads')
      .select('id, customer_id, jeweller_id')
      .eq('id', thread_id)
      .single();

    if (threadError || !thread) {
      return res.status(404).json({
        success: false,
        message: 'Chat thread not found'
      });
    }

    // FIX: removed duplicate/unclosed if block — use req.user.id as the authoritative check
    if (!isThreadParticipant(thread, req.user?.id)) {
      return res.status(403).json({
        success: false,
        message: 'You are not part of this chat'
      });
    }

    const { data: messages, error } = await supabase
      .from('chat_messages')
      .select(`
        *,
        sender:users(id, name, role, business_name)
      `)
      .eq('thread_id', thread_id)
      .order('created_at', { ascending: true })
      .range(offset, offset + limit - 1);

    if (error) throw error;

    console.log(`✅ Found ${messages.length} messages`);

    return res.status(200).json({
      success: true,
      count: messages.length,
      pagination: {
        limit,
        offset
      },
      // FIX: removed duplicate messages key in object literal
      messages: messages || []
    });

  } catch (error) {
    console.error('❌ Get messages error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// ==================== MARK MESSAGES AS READ ====================
export const markAsRead = async (req, res) => {
  try {
    const { thread_id } = req.body;
    const user_id = req.user?.id;

    console.log('👁️ Mark messages as read');
    console.log('Thread:', thread_id);
    console.log('User:', user_id);

    if (!thread_id || !user_id) {
      return res.status(400).json({
        success: false,
        message: 'thread_id is required'
      });
    }

    const { data: thread, error: threadError } = await supabase
      .from('chat_threads')
      .select('customer_id, jeweller_id')
      .eq('id', thread_id)
      .single();

    if (threadError || !thread) {
      return res.status(404).json({
        success: false,
        message: 'Chat thread not found'
      });
    }

    // FIX: removed duplicate/unclosed if block (isThreadMember + isThreadParticipant)
    if (!isThreadParticipant(thread, user_id)) {
      return res.status(403).json({
        success: false,
        message: 'You are not part of this chat'
      });
    }

    const now = new Date().toISOString();

    const { error: updateError } = await supabase
      .from('chat_messages')
      .update({
        is_read: true,
        read_at: now
      })
      .eq('thread_id', thread_id)
      .neq('sender_id', user_id)
      .eq('is_read', false);

    if (updateError) throw updateError;

    await syncThreadUnreadCounts({ id: thread_id, ...thread });

    console.log('✅ Messages marked as read');

    return res.status(200).json({
      success: true,
      message: 'Messages marked as read'
    });

  } catch (error) {
    console.error('❌ Mark as read error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// ==================== SEND QUOTATION ====================
export const sendQuotation = async (req, res) => {
  try {
    const jeweller_id = req.user?.id;
    const {
      thread_id,
      quotation_id
    } = req.body;

    console.log('💰 Send quotation');
    console.log('Thread:', thread_id);
    console.log('Quotation ID:', quotation_id);

    if (!thread_id || !jeweller_id || !quotation_id) {
      return res.status(400).json({
        success: false,
        message: 'thread_id and quotation_id are required'
      });
    }

    const { data: thread, error: threadError } = await supabase
      .from('chat_threads')
      .select('*')
      .eq('id', thread_id)
      .single();

    if (threadError || !thread) {
      return res.status(404).json({
        success: false,
        message: 'Chat thread not found'
      });
    }

    if (!isThreadParticipant(thread, jeweller_id) || jeweller_id !== thread.jeweller_id) {
      return res.status(403).json({
        success: false,
        message: 'Only the jeweller can send quotations in this thread'
      });
    }

    const { data: quotationMessage, error } = await supabase
      .from('chat_messages')
      .insert([{
        thread_id,
        sender_id: jeweller_id,
        message_text: 'Sent a quotation',
        message_type: 'quotation',
        quotation_id,
        is_read: false,
        created_at: new Date().toISOString()
      }])
      .select(`
        *,
        sender:users(id, name, business_name)
      `)
      .single();

    if (error) throw error;

    const { error: threadUpdateError } = await supabase
      .from('chat_threads')
      .update({
        last_message: 'Quotation sent',
        last_message_at: new Date().toISOString(),
        last_message_by: jeweller_id,
        updated_at: new Date().toISOString()
      })
      .eq('id', thread_id);

    if (threadUpdateError) throw threadUpdateError;

    await syncThreadUnreadCounts(thread);

    console.log('✅ Quotation sent:', quotationMessage.id);

    return res.status(201).json({
      success: true,
      message: 'Quotation sent successfully',
      data: quotationMessage
    });

  } catch (error) {
    console.error('❌ Send quotation error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// ==================== SHARE AI DESIGN ====================
export const shareAIDesign = async (req, res) => {
  try {
    const sender_id = req.user?.id;
    const {
      thread_id,
      ai_design_id
    } = req.body;

    console.log('🎨 Share AI design');
    console.log('Thread:', thread_id);
    console.log('Design ID:', ai_design_id);

    if (!thread_id || !sender_id || !ai_design_id) {
      return res.status(400).json({
        success: false,
        message: 'thread_id, sender_id, and ai_design_id are required'
      });
    }

    const { data: thread, error: threadError } = await supabase
      .from('chat_threads')
      .select('*')
      .eq('id', thread_id)
      .single();

    if (threadError || !thread) {
      return res.status(404).json({
        success: false,
        message: 'Chat thread not found'
      });
    }

    // FIX: removed duplicate/unclosed if block (isThreadMember + isThreadParticipant)
    if (!isThreadParticipant(thread, sender_id)) {
      return res.status(403).json({
        success: false,
        message: 'You are not part of this chat'
      });
    }

    const { data: designMessage, error } = await supabase
      .from('chat_messages')
      .insert([{
        thread_id,
        sender_id,
        message_text: 'Shared an AI design',
        message_type: 'ai_design',
        ai_design_id,
        is_read: false,
        created_at: new Date().toISOString()
      }])
      .select(`
        *,
        sender:users(id, name, business_name)
      `)
      .single();

    if (error) throw error;

    const updateData = {
      last_message: 'AI design shared',
      last_message_at: new Date().toISOString(),
      last_message_by: sender_id,
      updated_at: new Date().toISOString()
    };

    const { error: threadUpdateError } = await supabase
      .from('chat_threads')
      .update(updateData)
      .eq('id', thread_id);

    if (threadUpdateError) throw threadUpdateError;

    await syncThreadUnreadCounts(thread);

    console.log('✅ AI design shared:', designMessage.id);

    return res.status(201).json({
      success: true,
      message: 'AI design shared successfully',
      data: designMessage
    });

  } catch (error) {
    console.error('❌ Share AI design error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};