-- PostgreSQL Schema for SentinelSync
-- This file defines the database schema for the AI-Driven Centralized Operations Platform

-- Create file_metadata table for backup status tracking
CREATE TABLE IF NOT EXISTS file_metadata (
    id SERIAL PRIMARY KEY,
    file_path VARCHAR(500) NOT NULL,
    file_hash VARCHAR(64) NOT NULL,
    backup_status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create agent_assets table for asset information and metadata
CREATE TABLE IF NOT EXISTS agent_assets (
    id SERIAL PRIMARY KEY,
    hostname VARCHAR(255) NOT NULL UNIQUE,
    ip_address VARCHAR(45),
    last_seen TIMESTAMP,
    agent_version VARCHAR(50),
    assets_info JSONB
);

-- Create agent_config table for remote configuration management
CREATE TABLE IF NOT EXISTS agent_config (
    id SERIAL PRIMARY KEY,
    agent_id INT REFERENCES agent_assets(id),
    config_key VARCHAR(255) NOT NULL,
    config_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create system_logs table for aggregated system events
CREATE TABLE IF NOT EXISTS system_logs (
    id SERIAL PRIMARY KEY,
    agent_id INT REFERENCES agent_assets(id),
    log_level VARCHAR(50),
    message TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create ai_insights table for AI analysis results and predictions
CREATE TABLE IF NOT EXISTS ai_insights (
    id SERIAL PRIMARY KEY,
    insight_type VARCHAR(100),
    analysis_data JSONB,
    confidence_score DECIMAL(5,4),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- User Authentication and Authorization Tables
-- ==========================================

-- Create users table for user authentication and basic information
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    real_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    user_type VARCHAR(20) NOT NULL DEFAULT 'USER',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    avatar VARCHAR(255),
    remark TEXT,
    password_changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id)
);

-- Create roles table for role-based access control
CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    role_code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id)
);

-- Create permissions table for fine-grained permissions
CREATE TABLE IF NOT EXISTS permissions (
    id SERIAL PRIMARY KEY,
    permission_name VARCHAR(100) NOT NULL,
    permission_code VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    category VARCHAR(50) DEFAULT 'GENERAL',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create user_roles table for user-role relationships
CREATE TABLE IF NOT EXISTS user_roles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id),
    UNIQUE(user_id, role_id)
);

-- Create role_permissions table for role-permission relationships
CREATE TABLE IF NOT EXISTS role_permissions (
    id SERIAL PRIMARY KEY,
    role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INTEGER NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id),
    UNIQUE(role_id, permission_id)
);

-- Create user_tokens table for JWT token management
CREATE TABLE IF NOT EXISTS user_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_type VARCHAR(20) NOT NULL,
    access_token VARCHAR(255) NOT NULL UNIQUE,
    refresh_token VARCHAR(255) UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    device_info JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    last_used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create user_sessions table for active session tracking
CREATE TABLE IF NOT EXISTS user_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id VARCHAR(255) NOT NULL UNIQUE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL
);

-- Insert default roles
INSERT INTO roles (role_name, role_code, description) VALUES
('超级管理员', 'SUPER_ADMIN', '系统超级管理员，拥有所有权限'),
('管理员', 'ADMIN', '系统管理员，拥有大部分管理权限'),
('普通用户', 'USER', '普通用户，基本操作权限'),
('访客', 'GUEST', '访客用户，只读权限')
ON CONFLICT (role_code) DO NOTHING;

-- Insert default permissions
INSERT INTO permissions (permission_name, permission_code, description, category) VALUES
('全部权限', '*:*:*', '系统所有权限', 'SYSTEM'),
('用户管理', 'system:user:*', '用户增删改查权限', 'USER'),
('角色管理', 'system:role:*', '角色增删改查权限', 'ROLE'),
('权限管理', 'system:permission:*', '权限配置权限', 'PERMISSION'),
('系统配置', 'system:config:*', '系统配置权限', 'SYSTEM'),
('日志查看', 'system:log:view', '查看系统日志', 'LOG'),
('资产管理', 'asset:*:*', '资产管理权限', 'ASSET'),
('备份管理', 'backup:*:*', '备份管理权限', 'BACKUP'),
('监控查看', 'monitor:*:view', '监控数据查看权限', 'MONITOR')
ON CONFLICT (permission_code) DO NOTHING;

-- Assign permissions to roles
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.role_code = 'SUPER_ADMIN'
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Create default admin user (password: admin123)
INSERT INTO users (username, password_hash, real_name, email, user_type, status) VALUES
('admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj6hsLGmUKk2', '系统管理员', 'admin@sentinel-sync.local', 'SUPER_ADMIN', 'ACTIVE')
ON CONFLICT (username) DO NOTHING;

-- Assign admin role to default admin user
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.username = 'admin' AND r.role_code = 'SUPER_ADMIN'
ON CONFLICT (user_id, role_id) DO NOTHING;

-- Create indexes for authentication tables
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_user_tokens_user_id ON user_tokens(user_id);
CREATE INDEX idx_user_tokens_access_token ON user_tokens(access_token);
CREATE INDEX idx_user_tokens_refresh_token ON user_tokens(refresh_token);
CREATE INDEX idx_user_tokens_expires_at ON user_tokens(expires_at);
CREATE INDEX idx_user_tokens_is_revoked ON user_tokens(is_revoked);
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_session_id ON user_sessions(session_id);
CREATE INDEX idx_user_sessions_is_active ON user_sessions(is_active);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);

-- Create indexes for performance
CREATE INDEX idx_file_metadata_path ON file_metadata(file_path);
CREATE INDEX idx_agent_assets_hostname ON agent_assets(hostname);
CREATE INDEX idx_system_logs_timestamp ON system_logs(timestamp);
CREATE INDEX idx_system_logs_agent ON system_logs(agent_id);

-- Table comments
COMMENT ON TABLE users IS '用户认证和基本信息表';
COMMENT ON TABLE roles IS '角色定义表';
COMMENT ON TABLE permissions IS '权限定义表';
COMMENT ON TABLE user_roles IS '用户角色关联表';
COMMENT ON TABLE role_permissions IS '角色权限关联表';
COMMENT ON TABLE user_tokens IS '用户Token管理表';
COMMENT ON TABLE user_sessions IS '用户会话记录表';

COMMENT ON TABLE file_metadata IS 'Backup status tracking and file encoding data';
COMMENT ON TABLE agent_assets IS 'Asset information and monitoring metadata';
COMMENT ON TABLE agent_config IS 'Remote configuration management for agents';
COMMENT ON TABLE system_logs IS 'Aggregated system events from all agents';
COMMENT ON TABLE ai_insights IS 'AI analysis results and predictions';
