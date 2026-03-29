import bcrypt from 'bcrypt';
import nodemailer from 'nodemailer';
import { OAuth2Client } from 'google-auth-library';
import { supabase } from '../config/supabaseClient.js';
import { signAuthToken } from '../utils/jwt.js';

const sanitize = (value) => (typeof value === 'string' ? value.trim() : '');

const normalizeEmail = (value) => sanitize(value).toLowerCase();

const normalizePhone = (value) => sanitize(value).replace(/[^0-9]/g, '');

const EMAIL_CODE_TTL_MS = 10 * 60 * 1000;
const emailVerificationStore = new Map();

let mailTransporter;
let googleClient;

const getGoogleClient = () => {
  if (googleClient) {
    return googleClient;
  }

  googleClient = new OAuth2Client();
  return googleClient;
};

const verifyGoogleIdentity = async ({ idToken, email }) => {
  const configuredClientIds = [
    sanitize(process.env.GOOGLE_CLIENT_ID),
    sanitize(process.env.GOOGLE_CLIENT_ID_ANDROID),
    sanitize(process.env.GOOGLE_CLIENT_ID_IOS),
  ].filter((value) => value.length > 0);

  // Keep local/dev flexibility when GOOGLE_CLIENT_ID is not configured.
  if (configuredClientIds.length === 0) {
    return {
      email: normalizeEmail(email),
      name: null,
      emailVerified: true,
    };
  }

  if (!idToken) {
    throw new Error('Google ID token is required');
  }

  const client = getGoogleClient();
  const ticket = await client.verifyIdToken({
    idToken,
    audience: configuredClientIds,
  });

  const payload = ticket.getPayload();
  if (!payload?.email) {
    throw new Error('Google token did not contain an email');
  }

  const googleEmail = normalizeEmail(payload.email);
  const requestEmail = normalizeEmail(email);

  if (requestEmail && googleEmail !== requestEmail) {
    throw new Error('Google account email does not match request email');
  }

  if (!payload.email_verified) {
    throw new Error('Google account email is not verified');
  }

  return {
    email: googleEmail,
    name: sanitize(payload.name),
    emailVerified: true,
  };
};

const getMailTransporter = async () => {
  if (mailTransporter) {
    return mailTransporter;
  }

  const host = process.env.SMTP_HOST;
  const port = Number(process.env.SMTP_PORT || 587);
  const user = process.env.SMTP_USER;
  const pass = process.env.SMTP_PASS;

  if (!host || !port || !user || !pass) {
    console.log('⚠️ SMTP attributes missing in .env. Generating Ethereal test account...');
    const testAccount = await nodemailer.createTestAccount();
    
    mailTransporter = nodemailer.createTransport({
      host: 'smtp.ethereal.email',
      port: 587,
      secure: false, 
      auth: {
        user: testAccount.user, 
        pass: testAccount.pass, 
      },
    });
    return mailTransporter;
  }

  mailTransporter = nodemailer.createTransport({
    host,
    port,
    secure: port === 465,
    auth: {
      user,
      pass
    }
  });

  return mailTransporter;
};

const createEmailVerificationCode = (email) => {
  const code = String(Math.floor(100000 + Math.random() * 900000));
  emailVerificationStore.set(normalizeEmail(email), {
    code,
    expiresAt: Date.now() + EMAIL_CODE_TTL_MS
  });
  return code;
};

const sendVerificationCodeEmail = async (email, code) => {
  const transporter = await getMailTransporter();
  const from = process.env.SMTP_FROM || process.env.SMTP_USER || 'testing@aurix.com';

  const info = await transporter.sendMail({
    from,
    to: email,
    subject: 'Aurix email verification code',
    text: `Your Aurix verification code is ${code}. It expires in 10 minutes.`,
    html: `<p>Your Aurix verification code is <strong>${code}</strong>.</p><p>This code expires in 10 minutes.</p>`
  });
  
  const testUrl = nodemailer.getTestMessageUrl(info);
  if (testUrl) {
    console.log('\n📧 ========================================');
    console.log('📧 TEST EMAIL SENT! View your code here:');
    console.log('📧 ' + testUrl);
    console.log('📧 ========================================\n');
  }
};

const findUserByIdentifier = async (identifier) => {
  const normalizedEmail = normalizeEmail(identifier);
  const normalizedPhone = normalizePhone(identifier);

  if (normalizedEmail) {
    const { data: userByEmail, error: emailError } = await supabase
      .from('users')
      .select('*')
      .eq('email', normalizedEmail)
      .single();

    if (userByEmail && !emailError) {
      return userByEmail;
    }
  }

  if (normalizedPhone) {
    const { data: userByPhone, error: phoneError } = await supabase
      .from('users')
      .select('*')
      .eq('phone', normalizedPhone)
      .single();

    if (userByPhone && !phoneError) {
      return userByPhone;
    }
  }

  return null;
};

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
      if (!date_of_birth || !gender || !relationship_status) {        
        console.log('âŒ Missing customer required fields');
        return res.status(400).json({
          success: false,
          message: 'Customers must provide date of birth, gender, and relationship status'
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
      email: normalizeEmail(email),
      password: hashedPassword,
      name: sanitize(name),
      role: role,
      phone: normalizePhone(phone),
      created_at: new Date().toISOString()
    };

    // Add customer-specific fields
    if (role === 'customer') {
      userData.date_of_birth = date_of_birth;
      userData.gender = gender;
      userData.relationship_status = relationship_status;
      userData.verified = false;
      userData.verification_status = null;
    }

    // Add jeweller-specific fields
    if (role === 'jeweller') {
      userData.business_name = sanitize(business_name);
      userData.business_registration_number = sanitize(business_registration_number);
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
          verified: false
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
    const identifier = sanitize(req.body?.identifier || req.body?.email);
    const password = sanitize(req.body?.password);
    
    console.log('\n📧 LOGIN REQUEST');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('Identifier:', identifier);
    console.log('Password:', '***');

    // Validation
    if (!identifier || !password) {
      console.log('❌ Missing identifier or password\n');
      return res.status(400).json({
        success: false,
        message: 'Identifier and password are required'
      });
    }

    // Get user from database
    console.log('🔍 Searching database...');
    const user = await findUserByIdentifier(identifier);

    if (!user) {
      console.log('❌ User not found\n');
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    console.log('✅ User found:', user.name, `(${user.role})`);
    console.log('   Stored password type:', user.password?.startsWith('$2') ? 'bcrypt hash' : 'plain text');

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
        message: 'Invalid credentials'
      });
    }

    if (user.role === 'jeweller') {
      if (user.verification_status === 'pending') {
        return res.status(403).json({
          success: false,
          code: 'JEWELLER_PENDING',
          message: 'Your jeweller account is pending admin approval.'
        });
      }

      if (user.verification_status === 'rejected') {
        return res.status(403).json({
          success: false,
          code: 'JEWELLER_REJECTED',
          message: 'Your jeweller account has been rejected. Contact support.'
        });
      }

      if (!user.verified || user.verification_status !== 'approved') {
        return res.status(403).json({
          success: false,
          code: 'JEWELLER_NOT_APPROVED',
          message: 'Your jeweller account is not approved yet.'
        });
      }
    }

    if (user.role === 'customer' && !user.verified) {
      return res.status(403).json({
        success: false,
        code: 'EMAIL_NOT_VERIFIED',
        message: 'Please verify your email before logging in.'
      });
    }

    console.log('✅ Password match!');
    console.log('✅ LOGIN SUCCESSFUL');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Return user without password
    const { password: _, ...userWithoutPassword } = user;
    const token = signAuthToken(userWithoutPassword);

    return res.status(200).json({
      success: true,
      message: 'Login successful',
      user: userWithoutPassword,
      token
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

// ==================== GOOGLE AUTH ====================
export const googleAuth = async (req, res) => {
  try {
    const requestedEmail = normalizeEmail(req.body?.email);
    const requestedName = sanitize(req.body?.name);
    const role = sanitize(req.body?.role || 'customer').toLowerCase();
    const phone = normalizePhone(req.body?.phone);
    const googleId = sanitize(req.body?.google_id);
    const idToken = sanitize(req.body?.id_token);

    const verifiedIdentity = await verifyGoogleIdentity({
      idToken,
      email: requestedEmail,
    });

    const email = verifiedIdentity.email;
    const name = verifiedIdentity.name || requestedName || 'Google User';

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Google account email is required'
      });
    }

    if (role !== 'customer' && role !== 'jeweller') {
      return res.status(400).json({
        success: false,
        message: 'Role must be either "customer" or "jeweller"'
      });
    }

    const { data: existingUser } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single();

    if (existingUser) {
      if (existingUser.role === 'jeweller') {
        if (existingUser.verification_status === 'pending') {
          return res.status(403).json({
            success: false,
            code: 'JEWELLER_PENDING',
            message: 'Your jeweller account is pending admin approval.'
          });
        }

        if (existingUser.verification_status === 'rejected') {
          return res.status(403).json({
            success: false,
            code: 'JEWELLER_REJECTED',
            message: 'Your jeweller account has been rejected. Contact support.'
          });
        }

        if (!existingUser.verified || existingUser.verification_status !== 'approved') {
          return res.status(403).json({
            success: false,
            code: 'JEWELLER_NOT_APPROVED',
            message: 'Your jeweller account is not approved yet.'
          });
        }
      }

      const { password: _, ...userWithoutPassword } = existingUser;
      const token = signAuthToken(userWithoutPassword);

      return res.status(200).json({
        success: true,
        message: 'Google sign-in successful',
        user: userWithoutPassword,
        token
      });
    }

    const generatedPassword = await bcrypt.hash(
      `google-${googleId || email}-${Date.now()}`,
      10
    );

    const userData = {
      email,
      password: generatedPassword,
      name,
      role,
      phone: phone || null,
      created_at: new Date().toISOString()
    };

    if (role === 'customer') {
      userData.verified = true;
      userData.verification_status = null;
      userData.gender = 'Not specified';
      userData.relationship_status = 'Not specified';
      userData.date_of_birth = '2000-01-01';
    } else {
      const businessName = sanitize(req.body?.business_name);
      const businessRegistrationNumber = sanitize(req.body?.business_registration_number);
      const certificationDocumentUrl = sanitize(req.body?.certification_document_url);

      if (!businessName || !businessRegistrationNumber || !certificationDocumentUrl) {
        return res.status(400).json({
          success: false,
          message: 'Jewellers must provide business details and certification document'
        });
      }

      userData.business_name = businessName;
      userData.business_registration_number = businessRegistrationNumber;
      userData.certification_document_url = certificationDocumentUrl;
      userData.verified = false;
      userData.verification_status = 'pending';
      userData.gender = 'Not specified';
      userData.relationship_status = 'Not specified';
      userData.date_of_birth = '2000-01-01';
    }

    const { data: newUser, error } = await supabase
      .from('users')
      .insert([userData])
      .select('*')
      .single();

    if (error) {
      throw error;
    }

    const { password: _, ...userWithoutPassword } = newUser;
    const token = signAuthToken(userWithoutPassword);

    return res.status(201).json({
      success: true,
      message: role === 'jeweller'
        ? 'Jeweller registered with Google and pending admin approval.'
        : 'Google sign-up successful',
      user: userWithoutPassword,
      token,
      requires_verification: role === 'jeweller'
    });
  } catch (error) {
    console.error('❌ Google auth error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error during Google authentication',
      error: error.message
    });
  }
};

export const requestEmailVerification = async (req, res) => {
  try {
    const email = normalizeEmail(req.body?.email);

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required'
      });
    }

    const { data: user } = await supabase
      .from('users')
      .select('id, email, role, verified')
      .eq('email', email)
      .single();

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Account not found for this email'
      });
    }

    if (user.role !== 'customer') {
      return res.status(400).json({
        success: false,
        message: 'Email verification is only required for customer accounts'
      });
    }

    if (user.verified) {
      return res.status(200).json({
        success: true,
        message: 'Email is already verified'
      });
    }

    const code = createEmailVerificationCode(email);
    await sendVerificationCodeEmail(email, code);

    return res.status(200).json({
      success: true,
      message: 'Verification code sent to email'
    });
  } catch (error) {
    console.error('❌ requestEmailVerification error:', error);
    return res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

export const verifyEmailCode = async (req, res) => {
  try {
    const email = normalizeEmail(req.body?.email);
    const code = sanitize(req.body?.code);

    if (!email || !code) {
      return res.status(400).json({
        success: false,
        message: 'Email and code are required'
      });
    }

    const saved = emailVerificationStore.get(email);

    if (!saved) {
      return res.status(400).json({
        success: false,
        message: 'No verification code found. Please request a new one.'
      });
    }

    if (saved.expiresAt < Date.now()) {
      emailVerificationStore.delete(email);
      return res.status(400).json({
        success: false,
        message: 'Verification code expired. Please request a new one.'
      });
    }

    if (saved.code !== code) {
      return res.status(400).json({
        success: false,
        message: 'Invalid verification code'
      });
    }

    const { data: updatedUser, error } = await supabase
      .from('users')
      .update({ verified: true })
      .eq('email', email)
      .select('id, email, name, role, verified')
      .single();

    if (error || !updatedUser) {
      throw error || new Error('Unable to verify email');
    }

    emailVerificationStore.delete(email);

    return res.status(200).json({
      success: true,
      message: 'Email verified successfully',
      user: updatedUser
    });
  } catch (error) {
    console.error('❌ verifyEmailCode error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to verify email',
      error: error.message
    });
  }
};

export const logout = async (req, res) => {
  return res.status(200).json({
    success: true,
    message: 'Logged out successfully'
  });
};