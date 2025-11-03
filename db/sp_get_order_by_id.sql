DELIMITER $$
CREATE PROCEDURE sp_get_order_by_id(
    IN p_order_id INT
)
proc: BEGIN
    DECLARE v_exists INT DEFAULT 0;


    SELECT COUNT(*) INTO v_exists
    FROM orders
    WHERE id = p_order_id;

    IF v_exists = 0 THEN
 
        SELECT 0 AS success, CONCAT('Order not found (order_id = ', p_order_id, ')') AS message;
        LEAVE proc;
    END IF;


    SELECT 
        o.id AS order_id,
        o.customer_id,
        c.name AS customer_name,
        o.status,
        o.created_at,
        o.total_cents
    FROM orders o
    LEFT JOIN customers c ON c.id = o.customer_id
    WHERE o.id = p_order_id;


    SELECT 
        oi.product_id,
        p.name AS product_name,
        oi.qty,
        oi.unit_price_cents,
        oi.subtotal_cents
    FROM order_items oi
    INNER JOIN products p ON p.id = oi.product_id
    WHERE oi.order_id = p_order_id;
END$$

DELIMITER ;
