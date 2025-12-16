CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    transaction_id VARCHAR(255) UNIQUE NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    merchant_id VARCHAR(255) NOT NULL,
    customer_id VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transaction_id ON transactions(transaction_id);
CREATE INDEX idx_merchant_id ON transactions(merchant_id);
CREATE INDEX idx_timestamp ON transactions(timestamp);

-- Insert sample data for testing
INSERT INTO transactions (transaction_id, amount, currency, merchant_id, customer_id, timestamp, status)
VALUES
    ('TXN001', 150.00, 'USD', 'MERCHANT001', 'CUST001', NOW(), 'approved'),
    ('TXN002', 2500.00, 'USD', 'MERCHANT002', 'CUST002', NOW(), 'approved'),
    ('TXN003', 75000.00, 'USD', 'MERCHANT003', 'CUST003', NOW(), 'rejected');