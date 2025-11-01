
USE DBANGEL;

INSERT IGNORE INTO customers (id, name, email, phone, created_at,is_active)
VALUES
  (1, 'Angel', 'angelcevallosvillacis@gmail.com', '+59390000001', NOW(),TRUE),
  (2, 'Cevallos', 'contact@globex.com', '+59390000002', NOW(),TRUE);

INSERT IGNORE INTO products (id, sku, name, price_cents, stock, created_at)
VALUES
  (1, 'COD-DEMO-01', 'Producto 1234', 129900, 10, NOW()),
  (2, 'COD-ACME-02', 'Producto 2211', 49900, 50, NOW()),
  (3, 'COD-GLBX-04', 'Producto21', 85900, 5, NOW());

INSERT IGNORE INTO orders (id, customer_id, status, total_cents, created_at)
VALUES (100, 1, 'CREATED', 259800, NOW());

INSERT IGNORE INTO order_items (order_id, product_id, qty, unit_price_cents, subtotal_cents)
VALUES (100, 1, 2, 129900, 259800);



