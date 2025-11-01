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
