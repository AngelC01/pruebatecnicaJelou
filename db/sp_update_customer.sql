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
