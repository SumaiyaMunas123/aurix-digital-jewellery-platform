import bcrypt from 'bcrypt';
import { supabase } from '../config/supabase.js';

// ==================== SIGNUP ====================
export const signup = async (req, res) => {
  try {
    console.log('📝 Signup request received');
    console.log('Request body:', JSON.stringify(req.body, null, 2));
    
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
    console.log('🔐 Login request received');
    
    // Get data from request body
    const { email, password } = req.body;

    // Step 1: Check if email and password provided
    if (!email || !password) {
      console.log('❌ Missing email or password');
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password'
      });
    }

    // Step 2: Find user in database
    console.log('🔍 Looking for user:', email);
    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email.toLowerCase().trim())
      .single();

    if (error || !user) {
      console.log('❌ User not found:', email);
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    // Step 3: Compare password with hashed password
    console.log('🔐 Checking password...');
    const passwordMatch = await bcrypt.compare(password, user.password);

    if (!passwordMatch) {
      console.log('❌ Password incorrect for:', email);
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    // Step 4: Check if jeweller is verified
    if (user.role === 'jeweller') {
      if (user.verification_status === 'pending') {
        console.log('⚠️ Jeweller account pending approval:', email);
        return res.status(403).json({
          success: false,
          message: 'Your account is pending admin approval',
          verification_status: 'pending',
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
            verified: false
          }
        });
      }
      
      if (user.verification_status === 'rejected') {
        console.log('❌ Jeweller account rejected:', email);
        return res.status(403).json({
          success: false,
          message: 'Your account was rejected by admin',
          verification_status: 'rejected',
          rejection_reason: user.rejection_reason,
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
            verified: false
          }
        });
      }

      if (!user.verified) {
        console.log('❌ Jeweller not verified:', email);
        return res.status(403).json({
          success: false,
          message: 'Your account is not verified'
        });
      }
    }

    console.log('✅ Login successful:', user.email, '| Role:', user.role);

    // Step 5: Send success response (don't send password!)
    res.status(200).json({
      success: true,
      message: 'Login successful',
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        verified: user.verified,
        phone: user.phone,
        business_name: user.business_name || null,
        verification_status: user.verification_status || null
      },
      token: 'dummy_token_' + user.id  // TODO: Replace with real JWT token later
    });

  } catch (error) {
    console.error('❌ Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during login',
      error: error.message
    });
  }
};