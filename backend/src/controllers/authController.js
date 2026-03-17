import bcrypt from 'bcrypt';
import { supabase } from '../config/supabaseClient.js';

// ==================== SIGNUP ====================
export const signup = async (req, res) => {
  try {
    console.log('\n📝 SIGNUP REQUEST');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    // Get data from request body
    const { 
      email, 
      password, 
      name, 
      role,
      phone,
      date_of_birth,
      gender,
      relationship_status,
      // Jeweller-specific fields (optional)
      business_name,
      business_registration_number,
      certification_document_url
    } = req.body;

    // ========== VALIDATION ==========
    
    // Step 1: Check required fields for all users
    if (!email || !password || !name || !role) {
      console.log('❌ Missing required fields');
      return res.status(400).json({
        success: false,
        message: 'Please provide email, password, name, and role'
      });
    }

    // Step 2: Validate role
    if (role !== 'customer' && role !== 'jeweller') {
      console.log('❌ Invalid role:', role);
      return res.status(400).json({
        success: false,
        message: 'Role must be either "customer" or "jeweller"'
      });
    }

    // Step 3: Customer-specific validation
    if (role === 'customer') {
      if (!phone || !date_of_birth || !gender || !relationship_status) {
        console.log('❌ Missing customer required fields');
        return res.status(400).json({
          success: false,
          message: 'Customers must provide phone, date of birth, gender, and relationship status'
        });
      }
    }

    // Step 4: Jeweller-specific validation
    if (role === 'jeweller') {
      if (!phone || !business_name || !business_registration_number || !certification_document_url) {
        console.log('❌ Missing jeweller required fields');
        return res.status(400).json({
          success: false,
          message: 'Jewellers must provide phone, business name, registration number, and certification document'
        });
      }
    }

    // Step 5: Check if email already exists
    const { data: existingUser } = await supabase
      .from('users')
      .select('email')
      .eq('email', email)
      .single();

    if (existingUser) {
      console.log('❌ Email already exists:', email);
      return res.status(400).json({
        success: false,
        message: 'Email already registered. Please login or use a different email.'
      });
    }

    // ========== PASSWORD HASHING ==========
    
    console.log('🔐 Hashing password...');
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // ========== PREPARE USER DATA ==========
    
    const userData = {
      email: email.toLowerCase().trim(),
      password: hashedPassword,
      name: name.trim(),
      role: role,
      phone: phone.trim(),
      created_at: new Date().toISOString()
    };

    // Add customer-specific fields
    if (role === 'customer') {
      userData.date_of_birth = date_of_birth;
      userData.gender = gender;
      userData.relationship_status = relationship_status;
      userData.verified = true; // Customers are auto-verified
      userData.verification_status = null; // NULL for customers
    }

    // Add jeweller-specific fields
    if (role === 'jeweller') {
      userData.business_name = business_name.trim();
      userData.business_registration_number = business_registration_number.trim();
      userData.certification_document_url = certification_document_url;
      userData.date_of_birth = date_of_birth || '2000-01-01'; // Optional
      userData.gender = gender || 'Not specified';
      userData.relationship_status = relationship_status || 'Not specified';
      userData.verified = false; // Jewellers need admin approval
      userData.verification_status = 'pending'; // Set to pending
    }

    // ========== SAVE TO DATABASE ==========
    
    console.log('💾 Saving user to database...');
    const { data: newUser, error } = await supabase
      .from('users')
      .insert([userData])
      .select()
      .single();

    if (error) {
      console.error('❌ Database error:', error);
      throw error;
    }

    console.log('✅ User created successfully:', newUser.email, '| Role:', newUser.role);

    // ========== SEND RESPONSE ==========
    
    // Different response based on role
    if (role === 'jeweller') {
      return res.status(201).json({
        success: true,
        message: 'Jeweller registered successfully. Your application is pending admin approval.',
        user: {
          id: newUser.id,
          email: newUser.email,
          name: newUser.name,
          role: newUser.role,
          business_name: newUser.business_name,
          verification_status: 'pending',
          verified: false
        },
        requires_verification: true
      });
    } else {
      return res.status(201).json({
        success: true,
        message: 'Customer registered successfully',
        user: {
          id: newUser.id,
          email: newUser.email,
          name: newUser.name,
          role: newUser.role,
          verified: true
        }
      });
    }

  } catch (error) {
    console.error('❌ Signup error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during signup',
      error: error.message
    });
  }
};

// ==================== LOGIN ====================
export const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    console.log('\n📧 LOGIN REQUEST');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('Email:', email);
    console.log('Password:', '***');

    // Validation
    if (!email || !password) {
      console.log('❌ Missing email or password\n');
      return res.status(400).json({
        success: false,
        message: 'Email and password are required'
      });
    }

    // Get user from database
    console.log('🔍 Searching database...');
    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email.toLowerCase().trim())
      .single();

    if (error || !user) {
      console.log('❌ User not found\n');
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    console.log('✅ User found:', user.name, `(${user.role})`);
    console.log('   Stored password type:', user.password.startsWith('$2') ? 'bcrypt hash' : 'plain text');

    // Compare password
    console.log('🔐 Comparing passwords...');
    let isPasswordValid = false;

    try {
      // Check if password is hashed (starts with $2)
      if (user.password && user.password.startsWith('$2')) {
        console.log('   → Using bcrypt.compare()');
        isPasswordValid = await bcrypt.compare(password, user.password);
      } else {
        console.log('   → Using plain text comparison');
        isPasswordValid = password === user.password;
      }
    } catch (bcryptError) {
      console.log('   → Bcrypt error, falling back to plain text');
      isPasswordValid = password === user.password;
    }

    if (!isPasswordValid) {
      console.log('❌ Password mismatch\n');
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    console.log('✅ Password match!');
    console.log('✅ LOGIN SUCCESSFUL');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Return user without password
    const { password: _, ...userWithoutPassword } = user;

    return res.status(200).json({
      success: true,
      message: 'Login successful',
      user: userWithoutPassword
    });

  } catch (error) {
    console.error('❌ LOGIN ERROR:', error.message);
    console.error('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    return res.status(500).json({
      success: false,
      message: 'Server error: ' + error.message
    });
  }
};