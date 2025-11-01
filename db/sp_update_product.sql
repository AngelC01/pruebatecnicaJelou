DELIMITER $$

CREATE PROCEDURE sp_update_product (
  IN p_id INT,
  IN p_price_cents INT,
  IN p_stock INT
)
BEGIN
  DECLARE existing INT;
  SELECT COUNT(*) INTO existing FROM products WHERE id = p_id;

  IF existing = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product not found';
  ELSE
    UPDATE products
    SET 
      price_cents = COALESCE(p_price_cents, price_cents),
      stock = COALESCE(p_stock, stock)
    WHERE id = p_id;
  END IF;
END $$

DELIMITER ;
