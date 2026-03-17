import Groq from 'groq-sdk';
import { supabase } from '../config/supabaseClient.js';

// Initialize Groq client
const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

// System prompt for jewelry AI assistant
const JEWELRY_SYSTEM_PROMPT = `You are Aurix AI, an expert jewelry consultant for the Aurix digital jewellery marketplace. You help customers with:

1. **Jewelry Knowledge**: Materials (gold karats, platinum, silver), gemstones (diamonds, rubies, sapphires, emeralds), craftsmanship techniques.
2. **Design Advice**: Style recommendations based on occasions, personal preferences, body type, and skin tone.
3. **Price Guidance**: General pricing factors, what affects jewelry value, how to assess fair pricing.
4. **Care & Maintenance**: How to clean, store, and maintain different types of jewelry.
5. **Cultural Significance**: Traditional jewelry styles from Sri Lanka and South Asia, bridal jewelry, auspicious designs.
6. **Trend Awareness**: Current jewelry trends, popular styles, modern vs traditional choices.

Guidelines:
- Be warm, professional, and knowledgeable.
- Give concise but helpful answers (2-4 paragraphs max unless the user asks for detail).
- When recommending products, suggest the user browse the Aurix marketplace.
- If asked about specific pricing, remind them prices vary by jeweller and suggest contacting verified Aurix jewellers.
- Never provide financial or investment advice.
- If asked something unrelated to jewelry, politely redirect to jewelry topics.
- Use relevant emoji sparingly to keep responses engaging (💎, ✨, 💍, etc).`;

// ==================== AI CHAT COMPLETION ====================
export const aiChat = async (req, res) => {
  try {
    const { message, conversation_history = [], user_id } = req.body;

    console.log('🤖 AI Chat request from user:', user_id || 'anonymous');
    console.log('📝 Message:', message?.substring(0, 100));

    if (!message || !message.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Message is required',
      });
    }

    // Build messages array for Groq
    const messages = [
      { role: 'system', content: JEWELRY_SYSTEM_PROMPT },
    ];

    // Add conversation history (last 10 exchanges to stay within context limits)
    const recentHistory = conversation_history.slice(-20);
    for (const entry of recentHistory) {
      messages.push({
        role: entry.role === 'user' ? 'user' : 'assistant',
        content: entry.content,
      });
    }

    // Add current message
    messages.push({ role: 'user', content: message.trim() });

    // Call Groq API
    const chatCompletion = await groq.chat.completions.create({
      messages,
      model: 'llama-3.3-70b-versatile',
      temperature: 0.7,
      max_completion_tokens: 1024,
      top_p: 1,
      stream: false,
    });

    const aiResponse = chatCompletion.choices[0]?.message?.content;

    if (!aiResponse) {
      throw new Error('No response from AI model');
    }

    console.log('✅ AI response generated, length:', aiResponse.length);

    // Optionally save to Supabase for analytics
    if (user_id) {
      try {
        await supabase.from('ai_chat_logs').insert([
          {
            user_id,
            user_message: message.trim(),
            ai_response: aiResponse,
            model: 'llama-3.3-70b-versatile',
            created_at: new Date().toISOString(),
          },
        ]);
      } catch (logError) {
        // Don't fail the request if logging fails (table might not exist yet)
        console.warn('⚠️ AI chat log save failed (table may not exist):', logError.message);
      }
    }

    return res.status(200).json({
      success: true,
      message: 'AI response generated',
      data: {
        response: aiResponse,
        model: 'llama-3.3-70b-versatile',
        usage: chatCompletion.usage,
      },
    });
  } catch (error) {
    console.error('❌ AI Chat error:', error.message);

    // Handle specific Groq errors
    if (error.status === 429) {
      return res.status(429).json({
        success: false,
        message: 'AI service is busy. Please try again in a moment.',
      });
    }

    if (error.status === 401) {
      return res.status(500).json({
        success: false,
        message: 'AI service configuration error.',
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Failed to get AI response',
      error: error.message,
    });
  }
};

// ==================== AI JEWELRY SUGGESTIONS ====================
export const aiSuggestions = async (req, res) => {
  try {
    const { occasion, budget, material_preference, style_preference } = req.body;

    console.log('💡 AI Suggestions request');

    const prompt = `Based on the following preferences, suggest 3-5 jewelry pieces with brief descriptions:
- Occasion: ${occasion || 'Not specified'}
- Budget range: ${budget || 'Not specified'}
- Preferred material: ${material_preference || 'Any'}
- Style preference: ${style_preference || 'Any'}

For each suggestion, include: name, description, estimated price range, and why it suits the occasion. Format as a numbered list.`;

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

    const suggestions = chatCompletion.choices[0]?.message?.content;

    console.log('✅ Suggestions generated');

    return res.status(200).json({
      success: true,
      data: {
        suggestions,
        model: 'llama-3.3-70b-versatile',
        usage: chatCompletion.usage,
      },
    });
  } catch (error) {
    console.error('❌ AI Suggestions error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to generate suggestions',
      error: error.message,
    });
  }
};

// ==================== AI HEALTH CHECK ====================
export const aiHealthCheck = async (req, res) => {
  try {
    const chatCompletion = await groq.chat.completions.create({
      messages: [
        { role: 'user', content: 'Say "Aurix AI is online" in exactly those words.' },
      ],
      model: 'llama-3.3-70b-versatile',
      temperature: 0,
      max_completion_tokens: 20,
    });

    const response = chatCompletion.choices[0]?.message?.content;

    return res.status(200).json({
      success: true,
      message: 'AI service is healthy',
      data: {
        status: 'online',
        model: 'llama-3.3-70b-versatile',
        test_response: response,
      },
    });
  } catch (error) {
    console.error('❌ AI Health check failed:', error.message);
    return res.status(503).json({
      success: false,
      message: 'AI service is unavailable',
      error: error.message,
    });
  }
};