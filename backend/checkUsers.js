import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

async function checkUsers() {
  try {
    console.log('\n🔍 CHECKING USERS IN DATABASE');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    const { data: users, error } = await supabase
      .from('users')
      .select('id, email, password, name, role');

    if (error) {
      console.error('❌ Error:', error.message);
      return;
    }

    if (!users || users.length === 0) {
      console.log('❌ No users found in database');
      return;
    }

    console.log(`✅ Found ${users.length} user(s):\n`);
    
    users.forEach((user, index) => {
      console.log(`${index + 1}. ${user.name} (${user.role})`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Password: ${user.password}`);
      console.log(`   Starts with $2: ${user.password.startsWith('$2')}`);
      console.log('');
    });

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

checkUsers();
