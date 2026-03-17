import { supabase } from '../config/supabaseClient.js';
import { generateImageWithHuggingFace } from '../utils/hfClient.js';
import { parseBase64Image, removeDesignObjects, toSafeFileSegment, uploadBufferToDesigns } from '../utils/storage.js';

const getPagination = (query) => {
  const limit = Math.max(1, Math.min(parseInt(query.limit || '20', 10), 100));
  const offset = Math.max(0, parseInt(query.offset || '0', 10));
  return { limit, offset };
};

const buildStyledPrompt = (prompt, style = {}) => {
  const parts = [
    'professional jewelry photography',
    prompt,
    style.material && style.jewelry_type ? `${style.material} ${style.jewelry_type}` : null,
    style.gemstone ? `with ${style.gemstone}` : null,
    style.style ? `${style.style} style` : null,
    style.finish ? `${style.finish} finish` : null,
    'studio lighting',
    'white background',
    '8k',
    'photorealistic',
  ].filter(Boolean);

  return parts.join(', ');
};

const saveDesign = async ({ userId, userType, prompt, styleParams, imageUrl, sketchUrl = null }) => {
  const payload = {
    user_id: userId || null,
    user_type: userType || 'customer',
    prompt,
    style_params: styleParams || {},
    image_url: imageUrl,
    sketch_url: sketchUrl,
    status: 'completed',
  };

  const { data, error } = await supabase.from('designs').insert([payload]).select('*').single();
  if (error) throw new Error(`Failed to save design: ${error.message}`);
  return data;
};

export const getUserDesigns = async (req, res) => {
  try {
    const { user_id: userId, user_type: userType } = req.query;
    const { limit, offset } = getPagination(req.query);

    if (!userId) {
      return res.status(400).json({ success: false, error: 'user_id query param is required' });
    }

    let query = supabase
      .from('designs')
      .select('*', { count: 'exact' })
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (userType) {
      query = query.eq('user_type', userType);
    }

    const { data, error, count } = await query;
    if (error) throw new Error(error.message);

    return res.status(200).json({
      success: true,
      data: {
        items: data || [],
        pagination: { limit, offset, total: count || 0 },
      },
    });
  } catch (error) {
    console.error('❌ getUserDesigns error:', error.message);
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getDesignById = async (req, res) => {
  try {
    const { id } = req.params;

    const { data, error } = await supabase.from('designs').select('*').eq('id', id).single();

    if (error) {
      if (error.code === 'PGRST116') {
        return res.status(404).json({ success: false, error: 'Design not found' });
      }
      throw new Error(error.message);
    }

    return res.status(200).json({ success: true, data });
  } catch (error) {
    console.error('❌ getDesignById error:', error.message);
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const deleteDesign = async (req, res) => {
  try {
    const { id } = req.params;

    const { data: design, error: fetchError } = await supabase
      .from('designs')
      .select('*')
      .eq('id', id)
      .single();

    if (fetchError) {
      if (fetchError.code === 'PGRST116') {
        return res.status(404).json({ success: false, error: 'Design not found' });
      }
      throw new Error(fetchError.message);
    }

    await removeDesignObjects([design.image_url, design.sketch_url]);

    const { error: deleteError } = await supabase.from('designs').delete().eq('id', id);
    if (deleteError) throw new Error(deleteError.message);

    return res.status(200).json({ success: true, data: { id, deleted: true } });
  } catch (error) {
    console.error('❌ deleteDesign error:', error.message);
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const toggleFavorite = async (req, res) => {
  try {
    const { id } = req.params;

    const { data: design, error: fetchError } = await supabase
      .from('designs')
      .select('id, is_favorite')
      .eq('id', id)
      .single();

    if (fetchError) {
      if (fetchError.code === 'PGRST116') {
        return res.status(404).json({ success: false, error: 'Design not found' });
      }
      throw new Error(fetchError.message);
    }

    const { data, error } = await supabase
      .from('designs')
      .update({ is_favorite: !design.is_favorite })
      .eq('id', id)
      .select('*')
      .single();

    if (error) throw new Error(error.message);

    return res.status(200).json({ success: true, data });
  } catch (error) {
    console.error('❌ toggleFavorite error:', error.message);
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const generateWithStyle = async (req, res) => {
  try {
    const { prompt, user_id: userId, user_type: userType = 'customer', style = {} } = req.body;

    if (!prompt || !prompt.trim()) {
      return res.status(400).json({ success: false, error: 'prompt is required' });
    }

    const cleanPrompt = prompt.trim();
    const enhancedPrompt = buildStyledPrompt(cleanPrompt, style);

    const { buffer, imageBase64 } = await generateImageWithHuggingFace(enhancedPrompt);

    const now = Date.now();
    const imagePath = `${toSafeFileSegment(userType)}/${toSafeFileSegment(userId || 'anonymous')}/styled-${now}.png`;
    const uploaded = await uploadBufferToDesigns({ path: imagePath, buffer, contentType: 'image/png' });

    const design = await saveDesign({
      userId,
      userType,
      prompt: cleanPrompt,
      styleParams: style,
      imageUrl: uploaded.publicUrl,
    });

    return res.status(200).json({
      success: true,
      data: {
        image_base64: imageBase64,
        image_url: uploaded.publicUrl,
        design,
      },
    });
  } catch (error) {
    console.error('❌ generateWithStyle error:', error.message);
    return res.status(error.statusCode || 500).json({ success: false, error: error.message });
  }
};

export const uploadSketch = async (req, res) => {
  try {
    const {
      prompt,
      sketch_base64: sketchBase64,
      user_id: userId,
      user_type: userType = 'customer',
    } = req.body;

    if (!prompt || !prompt.trim()) {
      return res.status(400).json({ success: false, error: 'prompt is required' });
    }

    if (!sketchBase64) {
      return res.status(400).json({ success: false, error: 'sketch_base64 is required' });
    }

    const sketchBuffer = parseBase64Image(sketchBase64);
    if (!sketchBuffer) {
      return res.status(400).json({ success: false, error: 'Invalid sketch_base64 value' });
    }

    const now = Date.now();
    const folder = `${toSafeFileSegment(userType)}/${toSafeFileSegment(userId || 'anonymous')}`;

    const sketchPath = `${folder}/sketch-${now}.png`;
    const sketchUpload = await uploadBufferToDesigns({ path: sketchPath, buffer: sketchBuffer, contentType: 'image/png' });

    const enhancedPrompt = `based on hand-drawn sketch, professional jewelry design, ${prompt.trim()}`;
    const { buffer, imageBase64 } = await generateImageWithHuggingFace(enhancedPrompt);

    const generatedPath = `${folder}/sketch-result-${now}.png`;
    const generatedUpload = await uploadBufferToDesigns({ path: generatedPath, buffer, contentType: 'image/png' });

    const design = await saveDesign({
      userId,
      userType,
      prompt: prompt.trim(),
      styleParams: { source: 'sketch' },
      imageUrl: generatedUpload.publicUrl,
      sketchUrl: sketchUpload.publicUrl,
    });

    return res.status(200).json({
      success: true,
      data: {
        image_base64: imageBase64,
        image_url: generatedUpload.publicUrl,
        sketch_url: sketchUpload.publicUrl,
        design,
      },
    });
  } catch (error) {
    console.error('❌ uploadSketch error:', error.message);
    return res.status(error.statusCode || 500).json({ success: false, error: error.message });
  }
};
