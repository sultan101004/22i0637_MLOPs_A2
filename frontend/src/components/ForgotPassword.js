import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

const ForgotPassword = () => {
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  const AUTH_SERVICE_URL = process.env.REACT_APP_AUTH_SERVICE_URL || 'http://localhost:3001';

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setMessage('');

    try {
      const response = await axios.post(`${AUTH_SERVICE_URL}/forgot-password`, {
        email
      });

      setMessage(response.data.message || 'Password reset token sent! Check the console for the token (in production, this would be emailed).');
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to process request. Please try again.');
    }
  };

  return (
    <div className="auth-container">
      <h2>Forgot Password</h2>
      {error && <div className="error-message">{error}</div>}
      {message && <div className="success-message">{message}</div>}
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label>Email</label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            placeholder="Enter your email"
          />
        </div>
        <button type="submit" className="btn">Send Reset Link</button>
      </form>
      <div className="link-text">
        Remember your password?<Link to="/login">Login</Link>
      </div>
    </div>
  );
};

export default ForgotPassword;

