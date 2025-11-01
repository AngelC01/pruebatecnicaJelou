DELIMITER $$

CREATE PROCEDURE sp_get_orders_with_items(
    IN p_status VARCHAR(20),
    IN p_from DATETIME,
    IN p_to DATETIME,
    IN p_cursor INT,
    IN p_limit INT
)
BEGIN
    DECLARE v_limit INT;

    -- Si p_limit es NULL, usar 20 como valor por defecto
    SET v_limit = IFNULL(p_limit, 20);

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
        (p_status IS NULL OR o.status = p_status)
        AND (p_from IS NULL OR o.created_at >= p_from)
        AND (p_to IS NULL OR o.created_at <= p_to)
        AND (p_cursor IS NULL OR o.id > p_cursor)
    GROUP BY o.id
    ORDER BY o.id ASC
    LIMIT v_limit;
END$$

DELIMITER ;
