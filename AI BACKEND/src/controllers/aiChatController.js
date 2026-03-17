import Groq from 'groq-sdk';
import { supabase } from '../config/supabaseClient.js';

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

const JEWELRY_SYSTEM_PROMPT = `You are Aurix AI, an expert jewelry consultant for the Aurix digital jewellery marketplace. You help customers with materials, gemstones, style guidance, care advice, and occasion-based recommendations. Keep responses concise, practical, and friendly.`;

export const aiChat = async (req, res) => {
  try {
    const { message, conversation_history = [], user_id } = req.body;

    if (!message || !message.trim()) {
      return res.status(400).json({ success: false, error: 'message is required' });
    }

    const messages = [{ role: 'system', content: JEWELRY_SYSTEM_PROMPT }];
    const recentHistory = conversation_history.slice(-20);

    for (const entry of recentHistory) {
      messages.push({
        role: entry.role === 'user' ? 'user' : 'assistant',
        content: entry.content,
      });
    }

    messages.push({ role: 'user', content: message.trim() });

    const chatCompletion = await groq.chat.completions.create({
      messages,
      model: 'llama-3.3-70b-versatile',
      temperature: 0.7,
      max_completion_tokens: 1024,
      top_p: 1,
      stream: false,
    });

    const responseText = chatCompletion.choices[0]?.message?.content;

    if (!responseText) {
      throw new Error('No response from AI model');
    }

    if (user_id) {
      await supabase.from('ai_chat_logs').insert([
        {
          user_id,
          user_message: message.trim(),
          ai_response: responseText,
          model: 'llama-3.3-70b-versatile',
          created_at: new Date().toISOString(),
        },
      ]).catch(() => null);
    }

    return res.status(200).json({
      success: true,
      data: {
        response: responseText,
        model: 'llama-3.3-70b-versatile',
        usage: chatCompletion.usage,
      },
    });
  } catch (error) {
    console.error('❌ AI chat error:', error.message);
    return res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};

export const aiSuggestions = async (req, res) => {
  try {
    const { occasion, budget, material_preference, style_preference } = req.body;

    const prompt = `Suggest 3-5 jewelry ideas for:\n- Occasion: ${occasion || 'Not specified'}\n- Budget: ${budget || 'Not specified'}\n- Material: ${material_preference || 'Any'}\n- Style: ${style_preference || 'Any'}\n\nInclude title, short reason, and rough price range.`;

    const chatCompletion = await groq.chat.completions.create({
      messages: [
        { role: 'system', content: JEWELRY_SYSTEM_PROMPT },
        { role: 'user', content: prompt },
      ],
      model: 'llama-3.3-70b-versatile',
      temperature: 0.8,
      max_completion_tokens: 1024,
      top_p: 1,
      stream: false,
    });

    return res.status(200).json({
      success: true,
      data: {
        suggestions: chatCompletion.choices[0]?.message?.content,
        model: 'llama-3.3-70b-versatile',
        usage: chatCompletion.usage,
      },
    });
  } catch (error) {
    console.error('❌ AI suggestions error:', error.message);
    return res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};
