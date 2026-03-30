import { createClient } from '@supabase/supabase-js';
import 'dotenv/config';

const supabaseUrl = process.env.SUPABASE_URL;

// Use Service Role Key if it's a valid JWT (starts with ey), else use Anon Key
let supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!supabaseKey || !supabaseKey.startsWith('ey')) {
  supabaseKey = process.env.SUPABASE_ANON_KEY;
}

export const hasSupabaseConfig = Boolean(supabaseUrl && supabaseKey);

if (!hasSupabaseConfig) {
  console.warn('⚠️ Supabase not configured. Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY (or SUPABASE_ANON_KEY).');
}

export const supabase = hasSupabaseConfig ? createClient(supabaseUrl, supabaseKey) : null;

export const ensureSupabaseConfigured = () => {
  if (!hasSupabaseConfig || !supabase) {
    const error = new Error('Supabase is not configured. Please set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY (or SUPABASE_ANON_KEY).');
    error.statusCode = 500;
    throw error;
  }
};
