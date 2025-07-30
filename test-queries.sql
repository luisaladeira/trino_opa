-- Queries de teste para demonstrar o controle de acesso com OPA

-- 1. Query básica - deve funcionar para todos os usuários com permissão SELECT
SELECT name, department, salary FROM postgresql.public.users LIMIT 5;

-- 2. Query com colunas sensíveis - deve ser filtrada para analistas
SELECT * FROM postgresql.public.users;

-- 3. Query de JOIN - teste de performance com OPA
SELECT
    u.name,
    u.department,
    p.name as product_name,
    s.total_amount,
    s.sale_date
FROM postgresql.public.users u
JOIN postgresql.public.sales s ON u.id = s.user_id
JOIN postgresql.public.products p ON s.product_id = p.id;

-- 4. Query de agregação
SELECT
    department,
    COUNT(*) as employee_count,
    AVG(salary) as avg_salary
FROM postgresql.public.users
GROUP BY department;

-- 5. Query CREATE TABLE - só deve funcionar para engineers/admin
CREATE TABLE postgresql.public.test_table (
    id INTEGER,
    name VARCHAR(100)
);

-- 6. Query INSERT - só deve funcionar para engineers/admin
INSERT INTO postgresql.public.products (name, category, price)
VALUES ('Test Product', 'test', 9.99);

-- 7. Query com filtro por data
SELECT * FROM postgresql.public.sales
WHERE sale_date >= DATE '2024-01-17';

-- 8. Query usando memory catalog para testes
CREATE TABLE memory.default.temp_data AS
SELECT department, COUNT(*) as count
FROM postgresql.public.users
GROUP BY department;
