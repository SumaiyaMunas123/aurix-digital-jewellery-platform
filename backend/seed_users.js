import { createClient } from '@supabase/supabase-js';
import 'dotenv/config';

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

async function seedUsers() {
  console.log('🌱 Seeding users into Supabase...');

  const usersToCreate = [
    { email: 'customer@aurix.com', password: 'password123', name: 'Aurix Customer', role: 'customer' },
    { email: 'jeweller@aurix.com', password: 'password123', name: 'Aurix Jeweller', role: 'jeweller' }
  ];

  for (const u of usersToCreate) {
    const { data, error } = await supabase.auth.signUp({
      email: u.email,
      password: u.password,
      options: {
        data: {
          name: u.name,
          role: u.role,
        }
      }
    });

    if (error) {
      if (error.message.includes('already registered')) {
        console.log(`✅ User ${u.email} already exists.`);
      } else {
        console.error(`❌ Failed to create ${u.email}:`, error.message);
      }
    } else {
      console.log(`✅ Successfully created ${u.email}`);
    }
  }
}

seedUsers();
