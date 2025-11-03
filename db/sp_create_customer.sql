
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
