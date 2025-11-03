DELIMITER $$

CREATE PROCEDURE sp_create_product (
  IN p_sku VARCHAR(100),
  IN p_name VARCHAR(200),
  IN p_price_cents INT,
  IN p_stock INT
)
BEGIN
  DECLARE existing INT;
  DECLARE v_product_id INT;

  SELECT COUNT(*) INTO existing FROM products WHERE sku = p_sku;

  IF existing > 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Product SKU already exists';
  ELSE
    INSERT INTO products (sku, name, price_cents, stock)
    VALUES (p_sku, p_name, p_price_cents, p_stock);

    SET v_product_id = LAST_INSERT_ID();


    SELECT v_product_id AS product_id;
  END IF;
END$$

DELIMITER ;
