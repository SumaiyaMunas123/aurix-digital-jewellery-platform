import { supabase } from './src/config/supabaseClient.js';

const setupTestUsers = async () => {
  try {
    console.log('\n🔧 SETTING UP TEST USERS');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Delete existing test users
    console.log('🗑️  Removing existing test accounts...');
    const { data: deleted } = await supabase
      .from('users')
      .delete()
      .in('email', ['customer@test.com', 'jeweller@test.com']);

    // Create customer
    console.log('👤 Creating customer account...');
    const { data: customer, error: customerError } = await supabase
      .from('users')
      .insert([
        {
          email: 'customer@test.com',
          password: 'customer123',
          name: 'Test Customer',
          role: 'customer',
          phone: '+94701234567',
          date_of_birth: '1990-01-15',
          gender: 'male',
          relationship_status: 'single',
          verified: true,
          verification_status: null
        }
      ])
      .select();

    if (customerError) {
      console.error('❌ Error:', customerError.message);
    } else {
      console.log('✅ Customer created');
    }

    // Create jeweller
    console.log('💎 Creating jeweller account...');
    const { data: jeweller, error: jewellerError } = await supabase
      .from('users')
      .insert([
        {
          email: 'jeweller@test.com',
          password: 'jeweller123',
          name: 'Test Jeweller',
          role: 'jeweller',
          phone: '+94701234568',
          business_name: 'Test Jewelry Store',
          business_registration_number: 'BRN123456',
          certification_document_url: 'https://example.com/cert.pdf',
          verified: false,
          verification_status: 'pending'
        }
      ])
      .select();

    if (jewellerError) {
      console.error('❌ Error:', jewellerError.message);
    } else {
      console.log('✅ Jeweller created');
    }

    console.log('\n✨ TEST ACCOUNTS READY');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('\n👤 CUSTOMER:');
    console.log('   Email: customer@test.com');
    console.log('   Password: customer123');
    console.log('\n💎 JEWELLER:');
    console.log('   Email: jeweller@test.com');
    console.log('   Password: jeweller123');
    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
};

setupTestUsers();
