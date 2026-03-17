import { supabase } from '../config/supabaseClient.js';
import { buildBaseJewelryPrompt, generateImageWithHuggingFace } from '../utils/hfClient.js';
import { toSafeFileSegment, uploadBufferToDesigns } from '../utils/storage.js';

const createDesignRecord = async ({ userId, userType, prompt, imageUrl, styleParams = {}, sketchUrl = null }) => {
  const payload = {
    user_id: userId || null,
    user_type: userType || 'customer',
    prompt,
    style_params: styleParams,
    image_url: imageUrl,
    sketch_url: sketchUrl,
    status: 'completed',
  };

  const { data, error } = await supabase.from('designs').insert([payload]).select('*').single();

  if (error) {
    throw new Error(`Failed to save design: ${error.message}`);
  }

  return data;
};

export const generateImage = async (req, res) => {
  try {
    const { prompt, user_id: userId, user_type: userType = 'customer' } = req.body;

    if (!prompt || !prompt.trim()) {
      return res.status(400).json({ success: false, error: 'prompt is required' });
    }

    const cleanPrompt = prompt.trim();
    const fullPrompt = buildBaseJewelryPrompt(cleanPrompt);

    const { buffer, imageBase64 } = await generateImageWithHuggingFace(fullPrompt);

    const now = Date.now();
    const path = `${toSafeFileSegment(userType)}/${toSafeFileSegment(userId || 'anonymous')}/generated-${now}.png`;

    const uploaded = await uploadBufferToDesigns({ path, buffer, contentType: 'image/png' });
    const design = await createDesignRecord({
      userId,
      userType,
      prompt: cleanPrompt,
      imageUrl: uploaded.publicUrl,
      styleParams: {},
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
    console.error('❌ AI generation error:', error.message);
    return res.status(error.statusCode || 500).json({
      success: false,
      error: error.message,
    });
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
