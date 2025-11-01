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
