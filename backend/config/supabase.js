// backend/config/supabase.js
import { createClient } from '@supabase/supabase-js';
import 'dotenv/config'; //make .env available

// These values come from your Supabase project (Project Settings → API)
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing Supabase credentials in .env file');
  process.exit(1);
}

// Create the Supabase client
export const supabase = createClient(supabaseUrl, supabaseKey);