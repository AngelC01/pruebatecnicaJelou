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
