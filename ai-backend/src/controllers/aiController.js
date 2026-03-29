import { ensureSupabaseConfigured, supabase } from '../config/supabaseClient.js';
import { buildBaseJewelryPrompt, generateImageWithHuggingFace, generateImageFromSketch } from '../utils/hfClient.js';
import { toSafeFileSegment, uploadBufferToDesigns } from '../utils/storage.js';
import { sendSuccess, sendError } from '../utils/response.js';
import fs from 'fs';

const createDesignRecord = async ({ userId, userType, prompt, imageUrl, styleParams = {}, sketchUrl = null, mode = 0 }) => {
  const payload = {
    user_id: userId || null,
    user_type: userType || 'customer',
    prompt,
    style_params: styleParams,
    image_url: imageUrl,
    sketch_url: sketchUrl,
    generation_mode: mode, // 0 = text-to-image, 1 = sketch-to-image
    status: 'completed',
  };

  const { data, error } = await supabase.from('designs').insert([payload]).select('*').single();

  if (error) {
    throw new Error(`Failed to save design: ${error.message}`);
  }

  return data;
};

export const generateImage = async (req, res) => {
  let sketchFilePath = null;
  try {
    ensureSupabaseConfigured();

    const { 
      mode = 0, // 0 = Text to Image, 1 = Sketch to Image
      prompt = '', 
      category,
      weight,
      material,
      karat,
      style,
      occasion,
      budget,
      user_id: userId, 
      user_type: userType = 'customer' 
    } = req.body;

    const modeInt = parseInt(mode);

    // Additional validation (middleware should catch most)
    if (modeInt === 0) {
      if (!prompt || !prompt.trim()) {
        return sendError(res, 'Prompt is required for text-to-image mode', 400);
      }
    } else if (modeInt === 1) {
      if (!req.file) {
        return sendError(res, 'Sketch file is required for sketch-to-image mode', 400);
      }
      sketchFilePath = req.file.path;
    } else {
      return sendError(res, 'Invalid mode. Use 0 for text-to-image or 1 for sketch-to-image', 400);
    }

    // Build style context for better generation
    const styleContext = `${category || 'jewelry'} in ${material || 'gold'} (${karat || '22K'}), ${style || 'elegant'} style, ${occasion || 'daily wear'}, budget ${budget || 'varies'}`;

    let buffer, imageBase64, sketchUrl = null;

    if (modeInt === 0) {
      // Text to Image
      console.log('📝 Generating image from text prompt...');
      const cleanPrompt = prompt.trim();
      const fullPrompt = buildBaseJewelryPrompt(cleanPrompt, styleContext);

      const result = await generateImageWithHuggingFace(fullPrompt);
      buffer = result.buffer;
      imageBase64 = result.imageBase64;
    } else {
      // Sketch to Image
      console.log('🎨 Generating image from sketch...');
      const sketchBuffer = fs.readFileSync(sketchFilePath);
      const sketchBase64 = sketchBuffer.toString('base64');
      
      const sketchPrompt = buildBaseJewelryPrompt(
        `refine this sketch: ${prompt || 'professional jewelry design'}`,
        styleContext
      );

      const result = await generateImageFromSketch(sketchBase64, sketchPrompt);
      buffer = result.buffer;
      imageBase64 = result.imageBase64;
      
      // Upload sketch reference
      const sketchTimestamp = Date.now();
      const sketchUploadPath = `${toSafeFileSegment(userType)}/${toSafeFileSegment(userId || 'anonymous')}/sketch-${sketchTimestamp}.png`;
      try {
        const uploadedSketch = await uploadBufferToDesigns({ 
          path: sketchUploadPath, 
          buffer: sketchBuffer, 
          contentType: 'image/png' 
        });
        sketchUrl = uploadedSketch.publicUrl;
      } catch (err) {
        console.warn('⚠️ Supabase sketch upload skipped due to error:', err.message);
      }
    }

    const now = Date.now();
    const generatedPath = `${toSafeFileSegment(userType)}/${toSafeFileSegment(userId || 'anonymous')}/generated-${now}.png`;

    let uploaded = { publicUrl: null };
    let design = { id: 'temp_' + now, user_id: userId, prompt: prompt };
    
    try {
      uploaded = await uploadBufferToDesigns({ 
        path: generatedPath, 
        buffer, 
        contentType: 'image/png' 
      });

      design = await createDesignRecord({
        userId,
        userType,
        prompt: modeInt === 0 ? prompt.trim() : `Sketch-based: ${prompt || 'refined design'}`,
        imageUrl: uploaded.publicUrl,
        styleParams: { category, weight, material, karat, style, occasion, budget },
        sketchUrl,
        mode: modeInt,
      });
    } catch (storageErr) {
      console.warn('⚠️ Supabase storage/db skipped due to error (returning base64 only):', storageErr.message);
    }

    console.log('✅ Design generation completed successfully');
    
    // Return success using response utility
    const responseData = {
      image_url: uploaded.publicUrl || '', // fallback to empty string if no url
      image_base64: imageBase64 || null,
      sketch_url: sketchUrl || null,
      design: {
        id: design.id,
        user_id: design.user_id,
        user_type: design.user_type,
        prompt: design.prompt,
        image_url: design.image_url,
      },
      mode: modeInt,
    };
    
    return sendSuccess(res, responseData, { message: 'Image generated successfully' });
  } catch (error) {
    console.error('❌ AI generation error:', error.message);
    
    // Map specific error status codes
    let statusCode = error.statusCode || 500;
    if (error.message?.includes('Rate limit') || error.message?.includes('Too many')) {
      statusCode = 429;
    } else if (error.message?.includes('timeout')) {
      statusCode = 503;
    } else if (error.message?.includes('unauthorized') || error.message?.includes('permission')) {
      statusCode = 403;
    }
    
    // Pass error with appropriate retry metadata for client guidance
    return sendError(res, error.message || 'An error occurred during image generation', statusCode, {
      retryGuidance: statusCode === 503 ? 'Generation timeout. Try a simpler prompt or lower quality settings.' : undefined,
    });
  } finally {
    // Clean up temp file
    if (sketchFilePath && fs.existsSync(sketchFilePath)) {
      fs.unlink(sketchFilePath, (err) => {
        if (err) console.warn('⚠️ Could not delete temp sketch file:', err.message);
      });
    }
  }
};

export const healthCheck = async (req, res) => {
  return sendSuccess(res, {
    service: 'Aurix AI Backend',
    status: 'operational',
    endpoints: {
      generate: 'POST /api/ai/generate',
      health: 'GET /api/ai/health',
    },
    features: {
      hf_token_configured: !!process.env.HF_TOKEN,
      supabase_configured: !!process.env.SUPABASE_URL,
      groq_key_configured: !!process.env.GROQ_API_KEY,
    },
  }, { message: 'Service health check passed' });
};
