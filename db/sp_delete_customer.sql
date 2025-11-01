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
