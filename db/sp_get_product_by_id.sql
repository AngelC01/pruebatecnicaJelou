DELIMITER $$

CREATE PROCEDURE sp_get_product_by_id (
  IN p_id INT
)
BEGIN
  SELECT id, sku, name, price_cents, stock, created_at
  FROM products
  WHERE id = p_id;
END $$

DELIMITER ;
