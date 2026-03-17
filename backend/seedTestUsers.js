import bcrypt from 'bcrypt';
import { supabase } from './src/config/supabaseClient.js';

const seedTestUsers = async () => {
  try {
    console.log('🌱 Starting to seed test users...\n');

    // Test passwords
    const customerPassword = 'customer123';
    const jewellerPassword = 'jeweller123';

    // Hash passwords
    const customerHashedPassword = await bcrypt.hash(customerPassword, 10);
    const jewellerHashedPassword = await bcrypt.hash(jewellerPassword, 10);

    // Delete existing test users if they exist
    console.log('🗑️  Removing existing test users...');
    await supabase
      .from('users')
      .delete()
      .in('email', ['customer@test.com', 'jeweller@test.com']);

    // Create customer account
    console.log('👤 Creating customer account...');
    const { data: customerData, error: customerError } = await supabase
      .from('users')
      .insert([
        {
          email: 'customer@test.com',
          password: customerHashedPassword,
          name: 'Test Customer',
          role: 'customer',
          phone: '+94701234567',
          date_of_birth: '1990-01-15',
          gender: 'male',
          relationship_status: 'single',
          created_at: new Date().toISOString()
        }
      ])
      .select();

    if (customerError) {
      console.error('❌ Customer creation error:', customerError.message);
    } else {
      console.log('✅ Customer created successfully');
      console.log('   📧 Email: customer@test.com');
      console.log('   🔑 Password: ' + customerPassword);
    }

    // Create jeweller account
    console.log('\n💎 Creating jeweller account...');
    const { data: jewellerData, error: jewellerError } = await supabase
      .from('users')
      .insert([
        {
          email: 'jeweller@test.com',
          password: jewellerHashedPassword,
          name: 'Test Jeweller',
          role: 'jeweller',
          phone: '+94701234568',
          business_name: 'Test Jewelry Store',
          business_registration_number: 'BRN123456',
          certification_document_url: 'https://example.com/cert.pdf',
          created_at: new Date().toISOString()
        }
      ])
      .select();

    if (jewellerError) {
      console.error('❌ Jeweller creation error:', jewellerError.message);
    } else {
      console.log('✅ Jeweller created successfully');
      console.log('   📧 Email: jeweller@test.com');
      console.log('   🔑 Password: ' + jewellerPassword);
    }

    console.log('\n✨ Test users seeded successfully!\n');
    console.log('═══════════════════════════════════════');
    console.log('🧪 TEST CREDENTIALS');
    console.log('═══════════════════════════════════════');
    console.log('\n👤 CUSTOMER:');
    console.log('   Email: customer@test.com');
    console.log('   Password: customer123');
    console.log('\n💎 JEWELLER:');
    console.log('   Email: jeweller@test.com');
    console.log('   Password: jeweller123');
    console.log('\n═══════════════════════════════════════\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding test users:', error.message);
    process.exit(1);
  }
};

seedTestUsers();
