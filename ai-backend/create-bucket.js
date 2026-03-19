import { createClient } from '@supabase/supabase-js';
import 'dotenv/config';

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY / SUPABASE_ANON_KEY');
  process.exit(1);
}

console.log('📦 Connecting to Supabase...');
console.log(`URL: ${supabaseUrl}`);

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function createDesignsBucket() {
  try {
    console.log('\n🔍 Checking for existing buckets...');
    const { data: buckets, error: listError } = await supabase.storage.listBuckets();
    
    if (listError) {
      console.error('❌ Error listing buckets:', listError.message);
      console.log('\n💡 This might be because:');
      console.log('   1. You need SUPABASE_SERVICE_ROLE_KEY in .env (not just ANON_KEY)');
      console.log('   2. Or manually create "designs" bucket in Supabase dashboard');
      process.exit(1);
    }

    console.log('\n📋 Existing buckets:');
    if (buckets && buckets.length > 0) {
      buckets.forEach(b => console.log(`   - ${b.name} (${b.public ? 'public' : 'private'})`));
    } else {
      console.log('   (no buckets found)');
    }

    // Check if 'designs' bucket exists
    const designsBucketExists = buckets && buckets.some(b => b.name === 'designs');

    if (designsBucketExists) {
      console.log('\n✅ "designs" bucket already exists');
      return;
    }

    // Try to create the bucket
    console.log('\n🚀 Creating "designs" bucket...');
    const { data, error } = await supabase.storage.createBucket('designs', {
      public: true,
    });

    if (error) {
      console.error('❌ Error creating bucket:', error.message);
      console.log('\n💡 Fallback: Create the bucket manually:');
      console.log('   1. Go to https://app.supabase.com');
      console.log('   2. Select your project');
      console.log('   3. Go to Storage → Buckets');
      console.log('   4. Click "New bucket"');
      console.log('   5. Name it "designs"');
      console.log('   6. Make it public');
      process.exit(1);
    }

    console.log('✅ "designs" bucket created successfully!');
    console.log(`   Bucket: ${data.name}`);
    console.log(`   Public: ${data.public}`);

  } catch (err) {
    console.error('❌ Unexpected error:', err.message);
    process.exit(1);
  }
}

createDesignsBucket();
