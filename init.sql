-- Resetar senha
ALTER USER bookstore_dev WITH PASSWORD 'bookstore_dev';

-- Garantir que o usuário tem permissões
GRANT ALL PRIVILEGES ON DATABASE bookstore_dev_db TO bookstore_dev;