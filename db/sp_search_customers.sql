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
