-- schema.sql
-- Crear DB y tablas mínimas requeridas por el enunciado

CREATE DATABASE IF NOT EXISTS DBANGEL CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE DBANGEL;

-- CUSTOMERS
CREATE TABLE IF NOT EXISTS customers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(50),
  deleted_at DATETIME DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE
);

-- PRODUCTS
CREATE TABLE IF NOT EXISTS products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(100) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  price_cents BIGINT NOT NULL DEFAULT 0,
  stock INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ORDERS
CREATE TABLE IF NOT EXISTS orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  status ENUM('CREATED','CONFIRMED','CANCELED') NOT NULL DEFAULT 'CREATED',
  total_cents BIGINT NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- ORDER ITEMS
CREATE TABLE IF NOT EXISTS order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  qty INT NOT NULL,
  unit_price_cents BIGINT NOT NULL,
  subtotal_cents BIGINT NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
);

-- IDEMPOTENCY KEYS
CREATE TABLE IF NOT EXISTS idempotency_keys (
  `key` VARCHAR(191) NOT NULL PRIMARY KEY,
  target_type VARCHAR(100) NOT NULL,    -- e.g. "order:create"
  target_id INT DEFAULT NULL,            -- order id when applicable
  status VARCHAR(50) NOT NULL,           -- e.g. "IN_PROGRESS","COMPLETED"
  response_body JSON DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at DATETIME DEFAULT NULL
);

-- Indexes (si hace falta)
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order ON order_items(order_id);


DELIMITER //

CREATE PROCEDURE sp_confirm_order_idempotent (
    IN p_order_id INT,
    IN p_idempotency_key VARCHAR(255)
)
main_block: BEGIN
    DECLARE v_existing_response JSON;
    DECLARE v_order_status VARCHAR(50);

    SELECT response_body INTO v_existing_response
    FROM idempotency_keys
    WHERE `key` = p_idempotency_key
      AND target_type = 'ORDER_CONFIRM'
    LIMIT 1;

    IF v_existing_response IS NOT NULL THEN
        SELECT v_existing_response AS response;
        LEAVE main_block;
    END IF;

    SELECT status INTO v_order_status
    FROM orders
    WHERE id = p_order_id;

    IF v_order_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Order not found';
    END IF;

    IF v_order_status = 'CONFIRMED' THEN
        SET v_existing_response = JSON_OBJECT(
            'message', CONCAT('Order ', p_order_id, ' already confirmed'),
            'status', 'CONFIRMED'
        );

        INSERT INTO idempotency_keys (`key`, target_type, target_id, status, response_body, expires_at)
        VALUES (p_idempotency_key, 'ORDER_CONFIRM', p_order_id, 'SUCCESS', v_existing_response, NOW() + INTERVAL 1 DAY);

        SELECT v_existing_response AS response;
        LEAVE main_block;
    END IF;

    UPDATE orders
    SET status = 'CONFIRMED'
    WHERE id = p_order_id
      AND status = 'CREATED';

    SET v_existing_response = JSON_OBJECT(
        'message', CONCAT('Order ', p_order_id, ' confirmed successfully'),
        'status', 'CONFIRMED'
    );

    INSERT INTO idempotency_keys (`key`, target_type, target_id, status, response_body, expires_at)
    VALUES (p_idempotency_key, 'ORDER_CONFIRM', p_order_id, 'SUCCESS', v_existing_response, NOW() + INTERVAL 1 DAY);

    SELECT v_existing_response AS response;
END //

DELIMITER ;


DELIMITER $$
CREATE PROCEDURE sp_create_customer (
    IN p_name VARCHAR(200),
    IN p_email VARCHAR(255),
    IN p_phone VARCHAR(50)
)
BEGIN
    DECLARE v_exists INT;
    DECLARE v_customer_id INT;

    SELECT COUNT(*) INTO v_exists
    FROM customers
    WHERE email = p_email;

    IF v_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email already exists.';
    ELSE
        INSERT INTO customers (name, email, phone)
        VALUES (p_name, p_email, p_phone);

        SET v_customer_id = LAST_INSERT_ID();

        SELECT v_customer_id AS customer_id;
    END IF;
END$$

DELIMITER ;


DELIMITER $$


CREATE PROCEDURE sp_create_order(
    IN p_customer_id INT,
    IN p_items JSON
)
BEGIN
    DECLARE v_order_id INT;
    DECLARE v_product_id INT;
    DECLARE v_qty INT;
    DECLARE v_stock INT;
    DECLARE v_price_cents INT;
    DECLARE v_subtotal INT;
    DECLARE v_total INT DEFAULT 0;
    DECLARE done INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT JSON_EXTRACT(j.value, '$.product_id'),
               JSON_EXTRACT(j.value, '$.qty')
        FROM JSON_TABLE(p_items, '$[*]' COLUMNS (
            value JSON PATH '$'
        )) AS j;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    START TRANSACTION;

    -- Crear la orden base
    INSERT INTO orders (customer_id, status, created_at, total_cents)
    VALUES (p_customer_id, 'CREATED', NOW(), 0);

    SET v_order_id = LAST_INSERT_ID();

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_product_id, v_qty;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Verificar existencia del producto y stock suficiente
        SELECT stock, price_cents
        INTO v_stock, v_price_cents
        FROM products
        WHERE id = v_product_id
        FOR UPDATE;

        IF v_stock IS NULL THEN
            SET @msg = CONCAT('Product not found (product_id = ', v_product_id, ')');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
        END IF;

        IF v_stock < v_qty THEN
            SET @msg = CONCAT('Insufficient stock for product_id = ', v_product_id);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
        END IF;

        -- Calcular subtotal
        SET v_subtotal = v_qty * v_price_cents;

        -- Insertar detalle de la orden
        INSERT INTO order_items (order_id, product_id, qty, unit_price_cents, subtotal_cents)
        VALUES (v_order_id, v_product_id, v_qty, v_price_cents, v_subtotal);

        -- Actualizar stock
        UPDATE products
        SET stock = stock - v_qty
        WHERE id = v_product_id;

        -- Acumular total
        SET v_total = v_total + v_subtotal;
    END LOOP;

    CLOSE cur;

    -- Actualizar total en la tabla de órdenes
    UPDATE orders
    SET total_cents = v_total
    WHERE id = v_order_id;

    COMMIT;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE sp_create_product (
  IN p_sku VARCHAR(100),
  IN p_name VARCHAR(200),
  IN p_price_cents INT,
  IN p_stock INT
)
BEGIN
  DECLARE existing INT;
  DECLARE v_product_id INT;

  SELECT COUNT(*) INTO existing FROM products WHERE sku = p_sku;

  IF existing > 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Product SKU already exists';
  ELSE
    INSERT INTO products (sku, name, price_cents, stock)
    VALUES (p_sku, p_name, p_price_cents, p_stock);

    SET v_product_id = LAST_INSERT_ID();


    SELECT v_product_id AS product_id;
  END IF;
END$$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE sp_delete_customer (
    IN p_id INT
)
BEGIN
    UPDATE customers
    SET deleted_at = NOW(),
        is_active = FALSE
    WHERE id = p_id AND deleted_at IS NULL;
END$$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE sp_get_customer_by_id (
    IN p_id INT
)
BEGIN
    SELECT id, name, email, phone, created_at, is_active
    FROM customers
    WHERE id = p_id AND deleted_at IS NULL;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE sp_get_orders_with_items(
    IN p_status VARCHAR(20),
    IN p_from VARCHAR(10),   -- formato esperado: 'YYYY-MM-DD'
    IN p_to VARCHAR(10),     -- formato esperado: 'YYYY-MM-DD'
    IN p_cursor INT,
    IN p_limit INT
)
BEGIN
    DECLARE v_limit INT DEFAULT 20;
    DECLARE v_cursor INT DEFAULT 0;	
    DECLARE v_from_dt DATETIME;
    DECLARE v_to_dt DATETIME;

    -- Convertir fechas si no son NULL (p_from -> inicio del día, p_to -> fin del día)
    IF p_from IS NOT NULL AND p_from != '' THEN
        SET v_from_dt = STR_TO_DATE(CONCAT(p_from, ' 00:00:00'), '%Y-%m-%d %H:%i:%s');
    ELSE
        SET v_from_dt = NULL;
    END IF;

    IF p_to IS NOT NULL AND p_to != '' THEN
        SET v_to_dt = STR_TO_DATE(CONCAT(p_to, ' 23:59:59'), '%Y-%m-%d %H:%i:%s');
    ELSE
        SET v_to_dt = NULL;
    END IF;

    -- Valores por defecto para cursor y limit
    SET v_limit = IFNULL(p_limit, 20);
    SET v_cursor = IFNULL(p_cursor, 0);

    SELECT 
        o.id,
        o.customer_id,
        o.status,
        o.total_cents,
        o.created_at,
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'item_id', i.id,
                'product_id', i.product_id,
                'qty', i.qty,
                'unit_price_cents', i.unit_price_cents,
                'subtotal_cents', i.subtotal_cents
            )
        ) AS items
    FROM orders o
    LEFT JOIN order_items i ON o.id = i.order_id
    WHERE 
        (p_status IS NULL OR p_status = '' OR o.status = p_status)
        AND (v_from_dt IS NULL OR o.created_at >= v_from_dt)
        AND (v_to_dt IS NULL OR o.created_at <= v_to_dt)
        AND o.id > v_cursor
    GROUP BY o.id
    ORDER BY o.id ASC
    LIMIT v_limit;
END$$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE sp_get_product_by_id (
  IN p_id INT
)
BEGIN
  SELECT id, sku, name, price_cents, stock, created_at
  FROM products
  WHERE id = p_id;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE sp_search_customers (
    IN p_search VARCHAR(100),
    IN p_cursor INT,
    IN p_limit INT
)
BEGIN
    IF p_search IS NULL OR p_search = '' THEN
        SET p_search = '%';
    ELSE
        SET p_search = CONCAT('%', p_search, '%');
    END IF;

    SELECT id, name, email, phone, created_at
    FROM customers
    WHERE (name LIKE p_search OR email LIKE p_search)
      AND (p_cursor IS NULL OR id > p_cursor)
      AND deleted_at IS NULL
    ORDER BY id ASC
    LIMIT p_limit;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE sp_search_products (
  IN p_search VARCHAR(200),
  IN p_cursor INT,
  IN p_limit INT
)
BEGIN
  IF p_cursor IS NULL THEN
    SET p_cursor = 0;
  END IF;
  IF p_limit IS NULL THEN
    SET p_limit = 10;
  END IF;

  SELECT id, sku, name, price_cents, stock, created_at
  FROM products
  WHERE name LIKE CONCAT('%', p_search, '%') or sku LIKE CONCAT('%', p_search, '%')
  AND id > p_cursor
  ORDER BY id ASC
  LIMIT p_limit;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE sp_update_customer (
    IN p_id INT,
    IN p_name VARCHAR(200),
    IN p_email VARCHAR(255),
    IN p_phone VARCHAR(50)
)
BEGIN
    DECLARE v_exists INT;

    SELECT COUNT(*) INTO v_exists
    FROM customers
    WHERE email = p_email AND id <> p_id AND deleted_at IS NULL;

    IF v_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email is already in use by another customer.';
    ELSE
        UPDATE customers
        SET name = p_name,
            email = p_email,
            phone = p_phone
        WHERE id = p_id AND deleted_at IS NULL;
    END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE sp_update_product (
  IN p_id INT,
  IN p_price_cents INT,
  IN p_stock INT
)
BEGIN
  DECLARE existing INT;
  SELECT COUNT(*) INTO existing FROM products WHERE id = p_id;

  IF existing = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product not found';
  ELSE
    UPDATE products
    SET 
      price_cents = COALESCE(p_price_cents, price_cents),
      stock = COALESCE(p_stock, stock)
    WHERE id = p_id;
  END IF;
END $$

DELIMITER ;
