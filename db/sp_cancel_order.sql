DELIMITER $$

CREATE PROCEDURE sp_cancel_order(
    IN p_order_id INT
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_created_at DATETIME;
    DECLARE v_success TINYINT DEFAULT 0;
    DECLARE v_message VARCHAR(255);

    START TRANSACTION;

    -- Obtener estado y fecha de creación (bloqueo)
    SELECT status, created_at
    INTO v_status, v_created_at
    FROM orders
    WHERE id = p_order_id
    FOR UPDATE;

    
    IF v_status IS NULL THEN
        SET v_success = 0;
        SET v_message = CONCAT('Order not found (id = ', p_order_id, ')');
        ROLLBACK;
        SELECT v_success AS success, v_message AS message;
    ELSEIF v_status = 'CANCELED' THEN
       
        SET v_success = 1;
        SET v_message = CONCAT('Order ', p_order_id, ' already canceled');
        COMMIT;
        SELECT v_success AS success, v_message AS message;
    ELSEIF v_status = 'CREATED' THEN
        
        UPDATE products p
        JOIN order_items i ON p.id = i.product_id
        SET p.stock = p.stock + i.qty
        WHERE i.order_id = p_order_id;

        UPDATE orders
        SET status = 'CANCELED'
        WHERE id = p_order_id;

        SET v_success = 1;
        SET v_message = CONCAT('Order ', p_order_id, ' canceled successfully');
        COMMIT;
        SELECT v_success AS success, v_message AS message;
    ELSEIF v_status = 'CONFIRMED' THEN
        IF TIMESTAMPDIFF(MINUTE, v_created_at, NOW()) <= 10 THEN
            -- Cancelar y restaurar stock
            UPDATE products p
            JOIN order_items i ON p.id = i.product_id
            SET p.stock = p.stock + i.qty
            WHERE i.order_id = p_order_id;

            UPDATE orders
            SET status = 'CANCELED'
            WHERE id = p_order_id;

            SET v_success = 1;
            SET v_message = CONCAT('Order ', p_order_id, ' canceled successfully (within 10 min)');
            COMMIT;
            SELECT v_success AS success, v_message AS message;
        ELSE
            SET v_success = 0;
            SET v_message = CONCAT('Cannot cancel order ', p_order_id, ': confirmed more than 10 minutes ago');
            ROLLBACK;
            SELECT v_success AS success, v_message AS message;
        END IF;
    ELSE
        SET v_success = 0;
        SET v_message = CONCAT('Cannot cancel order ', p_order_id, ': unsupported status (', v_status, ')');
        ROLLBACK;
        SELECT v_success AS success, v_message AS message;
    END IF;
END$$

DELIMITER ;
