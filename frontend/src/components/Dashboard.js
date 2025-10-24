import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

const Dashboard = () => {
  const [user, setUser] = useState(null);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const BACKEND_SERVICE_URL = process.env.REACT_APP_BACKEND_SERVICE_URL || 'http://localhost:5000';

  useEffect(() => {
    fetchUserProfile();
  }, []);

  const fetchUserProfile = async () => {
    try {
      const token = localStorage.getItem('accessToken');
      const response = await axios.get(`${BACKEND_SERVICE_URL}/profile`, {
        headers: {
          Authorization: `Bearer ${token}`
        }
      });
      setUser(response.data);
    } catch (err) {
      setError('Failed to fetch profile. Please login again.');
      setTimeout(() => handleLogout(), 2000);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    navigate('/login');
  };

  if (error) {
    return (
      <div className="dashboard">
        <div className="error-message">{error}</div>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="dashboard">
        <p>Loading...</p>
      </div>
    );
  }

  return (
    <div className="dashboard">
      <h2>Welcome to Dashboard</h2>
      <div className="user-info">
        <p><strong>Name:</strong> {user.name}</p>
        <p><strong>Email:</strong> {user.email}</p>
        <p><strong>User ID:</strong> {user.id}</p>
        <p><strong>Created At:</strong> {new Date(user.created_at).toLocaleString()}</p>
      </div>
      <button onClick={handleLogout} className="btn btn-logout">
        Logout
      </button>
    </div>
  );
};

export default Dashboard;

