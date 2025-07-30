-- Criar tabela de usuários com dados sensíveis
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    ssn VARCHAR(11), -- Coluna sensível
    credit_card VARCHAR(19), -- Coluna sensível
    password VARCHAR(255), -- Coluna sensível
    department VARCHAR(50),
    salary DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inserir dados de exemplo
INSERT INTO users (name, email, ssn, credit_card, password, department, salary) VALUES
('John Doe', 'john@company.com', '123-45-6789', '4532-1234-5678-9012', 'hashed_password_1', 'engineering', 75000.00),
('Jane Smith', 'jane@company.com', '987-65-4321', '5432-9876-5432-1098', 'hashed_password_2', 'analytics', 65000.00),
('Mike Johnson', 'mike@company.com', '456-78-9012', '4111-1111-1111-1111', 'hashed_password_3', 'sales', 55000.00),
('Sarah Wilson', 'sarah@company.com', '789-01-2345', '4000-0000-0000-0002', 'hashed_password_4', 'marketing', 60000.00),
('Tom Brown', 'tom@company.com', '234-56-7890', '4444-3333-2222-1111', 'hashed_password_5', 'engineering', 80000.00);

-- Criar tabela de produtos
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2),
    description TEXT,
    in_stock BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inserir produtos de exemplo
INSERT INTO products (name, category, price, description, in_stock) VALUES
('Laptop Pro', 'electronics', 1299.99, 'High-performance laptop for professionals', true),
('Wireless Mouse', 'electronics', 29.99, 'Ergonomic wireless mouse', true),
('Office Chair', 'furniture', 249.99, 'Comfortable office chair with lumbar support', true),
('Standing Desk', 'furniture', 399.99, 'Adjustable standing desk', false),
('Monitor 4K', 'electronics', 449.99, '27-inch 4K monitor', true);

-- Criar tabela de vendas
CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER DEFAULT 1,
    total_amount DECIMAL(10,2),
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inserir vendas de exemplo
INSERT INTO sales (user_id, product_id, quantity, total_amount, sale_date) VALUES
(1, 1, 1, 1299.99, '2024-01-15 10:30:00'),
(2, 2, 2, 59.98, '2024-01-16 14:20:00'),
(3, 3, 1, 249.99, '2024-01-17 09:15:00'),
(1, 5, 1, 449.99, '2024-01-18 16:45:00'),
(4, 4, 1, 399.99, '2024-01-19 11:30:00');
