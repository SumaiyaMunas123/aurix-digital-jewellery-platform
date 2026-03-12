import React, { useState } from "react";
import "./index.css";
import "./AdminLogin.css";
import logoImg from "./assets/logo.jpg";

const AdminLogin = ({ onLogin }) => {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [showPassword, setShowPassword] = useState(false);

   const handleSubmit = async (e) => {
    e.preventDefault();

    try {
        const response = await fetch("http://localhost:5000/api/admin/login", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({ email, password }),
        });

        const data = await response.json();

        if (data.success) {
            alert("Login successful!");
            console.log("Admin:", data.user);

            // Call parent function to navigate dashboard
            if (onLogin) {
                onLogin(data.user);
            }
        } else {
            alert(data.message);
        }

    } catch (error) {
        console.error("Login error:", error);
        alert("Server error. Try again later.");
    }
};

    const handleSocialLogin = (provider) => {
        console.log(`Login with ${provider}`);
    };

    return (
        <div className="login-wrapper">
            <div className="login-container">
                {/* Logo and Header */}
                <div className="login-header">
                    <div className="logo">
                        <img src={logoImg} alt="Aurix Logo" className="logo-img" />
                    </div>
                    <h1>Aurix</h1>
                    <p className="subtitle">Digital Jewellery Marketplace</p>
                </div>

                {/* Login Form */}
                <form onSubmit={handleSubmit} className="login-form">
                    {/* Email Input */}
                    <div className="form-group">
                        <label>Email</label>
                        <input
                            type="text"
                            placeholder="Enter your email address"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            // required
                        />
                    </div>

                    {/* Password Input */}
                    <div className="form-group">
                        <label>Password</label>
                        <div className="password-field">
                            <input
                                type={showPassword ? "text" : "password"}
                                placeholder="Enter your password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                // required
                            />
                            <button
                                type="button"
                                className="toggle-password"
                                onClick={() => setShowPassword(!showPassword)}
                                aria-label="Toggle password visibility"
                            >
                                {showPassword ? (
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                                        <circle cx="12" cy="12" r="3"/>
                                    </svg>
                                ) : (
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/>
                                        <line x1="1" y1="1" x2="23" y2="23"/>
                                    </svg>
                                )}
                            </button>
                        </div>
                    </div>

                    {/* Login Button */}
                    <button type="submit" className="login-btn">
                        Login
                    </button>
                </form>

                {/* Sign Up Link */}
                <p className="signup-link">
                 <a href="#">Login with Google</a>
                </p>
            </div>
        </div>
    );
};

export default AdminLogin;
