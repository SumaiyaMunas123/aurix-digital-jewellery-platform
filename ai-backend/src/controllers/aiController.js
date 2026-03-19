import { ensureSupabaseConfigured, supabase } from '../config/supabaseClient.js';
import { buildBaseJewelryPrompt, generateImageWithHuggingFace, generateImageFromSketch } from '../utils/hfClient.js';
import { toSafeFileSegment, uploadBufferToDesigns } from '../utils/storage.js';
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

    // Validate based on mode
    if (modeInt === 0) {
      // Text to Image mode
      if (!prompt || !prompt.trim()) {
        return res.status(400).json({ success: false, error: 'prompt is required for text-to-image mode' });
      }
    } else if (modeInt === 1) {
      // Sketch to Image mode
      if (!req.file) {
        return res.status(400).json({ success: false, error: 'sketch file is required for sketch-to-image mode' });
      }
      sketchFilePath = req.file.path;
    } else {
      return res.status(400).json({ success: false, error: 'Invalid mode. Use 0 for text-to-image or 1 for sketch-to-image' });
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
      const uploadedSketch = await uploadBufferToDesigns({ 
        path: sketchUploadPath, 
        buffer: sketchBuffer, 
        contentType: 'image/png' 
      });
      sketchUrl = uploadedSketch.publicUrl;
    }

    const now = Date.now();
    const generatedPath = `${toSafeFileSegment(userType)}/${toSafeFileSegment(userId || 'anonymous')}/generated-${now}.png`;

    const uploaded = await uploadBufferToDesigns({ 
      path: generatedPath, 
      buffer, 
      contentType: 'image/png' 
    });

    const design = await createDesignRecord({
      userId,
      userType,
      prompt: modeInt === 0 ? prompt.trim() : `Sketch-based: ${prompt || 'refined design'}`,
      imageUrl: uploaded.publicUrl,
      styleParams: { category, weight, material, karat, style, occasion, budget },
      sketchUrl,
      mode: modeInt,
    });

    console.log('✅ Design generation completed successfully');
    return res.status(200).json({
      success: true,
      data: {
        image_base64: imageBase64,
        image_url: uploaded.publicUrl,
        sketch_url: sketchUrl,
        design,
        mode: modeInt,
      },
    });
  } catch (error) {
    console.error('❌ AI generation error:', error.message);
    return res.status(error.statusCode || 500).json({
      success: false,
      error: error.message,
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
  return res.status(200).json({
    success: true,
    data: {
      service: 'Aurix AI Backend',
      model: 'stabilityai/stable-diffusion-xl-base-1.0',
      hf_token_set: !!process.env.HF_TOKEN,
      groq_key_set: !!process.env.GROQ_API_KEY,
    },
  });
};
