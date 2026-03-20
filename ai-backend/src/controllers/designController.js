import { ensureSupabaseConfigured, supabase } from '../config/supabaseClient.js';
import { generateImageWithHuggingFace } from '../utils/hfClient.js';
import { parseBase64Image, removeDesignObjects, toSafeFileSegment, uploadBufferToDesigns } from '../utils/storage.js';
import { sendSuccess, sendError } from '../utils/response.js';
import { validateUserScoping, validateBase64Image } from '../utils/validators.js';

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
    ensureSupabaseConfigured();

    const { user_id: userId, user_type: userType } = req.query;
    const { limit, offset } = getPagination(req.query);

    if (!userId) {
      return sendError(res, 'user_id query parameter is required', 400);
    }

    // User scoping: Only allow access to own designs or admin access
    if (req.user?.id && req.user.id !== userId && req.user.type !== 'admin') {
      return sendError(res, 'Cannot access designs for other users', 403);
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

    return sendSuccess(res, {
      items: data || [],
      pagination: { limit, offset, total: count || 0 },
    }, { message: 'Designs retrieved successfully' });
  } catch (error) {
    console.error('❌ getUserDesigns error:', error.message);
    return sendError(res, error.message || 'Failed to retrieve designs', 500);
  }
};

export const getDesignById = async (req, res) => {
  try {
    ensureSupabaseConfigured();

    const { id } = req.params;

    const { data, error } = await supabase.from('designs').select('*').eq('id', id).single();

    if (error) {
      if (error.code === 'PGRST116') {
        return sendError(res, 'Design not found', 404);
      }
      throw new Error(error.message);
    }

    // User scoping: Only allow access to own designs or admin access
    if (req.user?.id && req.user.id !== data.user_id && req.user.type !== 'admin') {
      return sendError(res, 'Cannot access this design', 403);
    }

    return sendSuccess(res, data, { message: 'Design retrieved successfully' });
  } catch (error) {
    console.error('❌ getDesignById error:', error.message);
    return sendError(res, error.message || 'Failed to retrieve design', 500);
  }
};

export const deleteDesign = async (req, res) => {
  try {
    ensureSupabaseConfigured();

    const { id } = req.params;

    const { data: design, error: fetchError } = await supabase
      .from('designs')
      .select('*')
      .eq('id', id)
      .single();

    if (fetchError) {
      if (fetchError.code === 'PGRST116') {
        return sendError(res, 'Design not found', 404);
      }
      throw new Error(fetchError.message);
    }

    // User scoping: Only allow user to delete their own designs
    if (req.user?.id && req.user.id !== design.user_id && req.user.type !== 'admin') {
      return sendError(res, 'Cannot delete designs created by other users', 403);
    }

    await removeDesignObjects([design.image_url, design.sketch_url]);

    const { error: deleteError } = await supabase.from('designs').delete().eq('id', id);
    if (deleteError) throw new Error(deleteError.message);

    return sendSuccess(res, { id, deleted: true }, { message: 'Design deleted successfully' });
  } catch (error) {
    console.error('❌ deleteDesign error:', error.message);
    return sendError(res, error.message || 'Failed to delete design', 500);
  }
};

export const toggleFavorite = async (req, res) => {
  try {
    ensureSupabaseConfigured();

    const { id } = req.params;

    const { data: design, error: fetchError } = await supabase
      .from('designs')
      .select('id, user_id, is_favorite')
      .eq('id', id)
      .single();

    if (fetchError) {
      if (fetchError.code === 'PGRST116') {
        return sendError(res, 'Design not found', 404);
      }
      throw new Error(fetchError.message);
    }

    // User scoping: Only allow user to update their own designs
    if (req.user?.id && req.user.id !== design.user_id && req.user.type !== 'admin') {
      return sendError(res, 'Cannot toggle favorite for designs created by other users', 403);
    }

    const { data, error } = await supabase
      .from('designs')
      .update({ is_favorite: !design.is_favorite })
      .eq('id', id)
      .select('*')
      .single();

    if (error) throw new Error(error.message);

    return sendSuccess(res, data, { message: 'Design favorite status updated' });
  } catch (error) {
    console.error('❌ toggleFavorite error:', error.message);
    return sendError(res, error.message || 'Failed to update favorite status', 500);
  }
};

export const generateWithStyle = async (req, res) => {
  try {
    ensureSupabaseConfigured();

    const { prompt, user_id: userId, user_type: userType = 'customer', style = {} } = req.body;

    if (!prompt || !prompt.trim()) {
      return sendError(res, 'Prompt is required', 400);
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

    return sendSuccess(res, {
      image_base64: imageBase64,
      image_url: uploaded.publicUrl,
      design,
    }, { message: 'Styled image generated successfully' });
  } catch (error) {
    console.error('❌ generateWithStyle error:', error.message);
    const statusCode = error.statusCode === 429 ? 429 : (error.statusCode === 503 ? 503 : 500);
    return sendError(res, error.message || 'Failed to generate styled image', statusCode, {
      retryGuidance: statusCode === 503 ? 'Generation timeout. Please try a simpler prompt.' : undefined,
    });
  }
};

export const uploadSketch = async (req, res) => {
  try {
    ensureSupabaseConfigured();

    const {
      prompt,
      sketch_base64: sketchBase64,
      user_id: userId,
      user_type: userType = 'customer',
    } = req.body;

    if (!prompt || !prompt.trim()) {
      return sendError(res, 'Prompt is required', 400);
    }

    if (!sketchBase64) {
      return sendError(res, 'sketch_base64 is required', 400);
    }

    // Validate base64 format
    const base64ValidationResult = validateBase64Image(sketchBase64);
    if (!base64ValidationResult.valid) {
      return sendError(res, base64ValidationResult.error, 400);
    }

    const sketchBuffer = parseBase64Image(sketchBase64);
    if (!sketchBuffer) {
      return sendError(res, 'Invalid or corrupted base64 image data', 400);
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

    return sendSuccess(res, {
      image_base64: imageBase64,
      image_url: generatedUpload.publicUrl,
      sketch_url: sketchUpload.publicUrl,
      design,
    }, { message: 'Sketch processed and design generated successfully' });
  } catch (error) {
    console.error('❌ uploadSketch error:', error.message);
    const statusCode = error.statusCode === 429 ? 429 : (error.statusCode === 503 ? 503 : 500);
    return sendError(res, error.message || 'Failed to process sketch', statusCode, {
      retryGuidance: statusCode === 503 ? 'Generation timeout. Please try a simpler prompt.' : undefined,
    });
  }
};
