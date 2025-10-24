-- Database initialization script
-- Creates users table with all necessary fields for authentication

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    reset_token VARCHAR(255),
    reset_token_expiry TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Create index on reset_token for password reset flow
CREATE INDEX IF NOT EXISTS idx_users_reset_token ON users(reset_token);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample user for testing (password: Test123!)
-- Password hash for 'Test123!' using bcrypt with 10 rounds
INSERT INTO users (name, email, password) VALUES 
('Demo User', 'demo@example.com', '$2a$10$rGPXvGOHqvYH9rJYhJEfaOqP8KZxKlYKqZQ8KkN0XKpQFzKZH5XmK')
ON CONFLICT (email) DO NOTHING;

-- Display success message
SELECT 'Database initialized successfully!' AS status;

