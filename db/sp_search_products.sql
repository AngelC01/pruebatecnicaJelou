DELIMITER $$

CREATE PROCEDURE sp_search_products (
  IN p_search VARCHAR(200),
  IN p_cursor INT,
  IN p_limit INT
)
BEGIN
  IF p_cursor IS NULL THEN
    SET p_cursor = 0;
  END IF;
  IF p_limit IS NULL THEN
    SET p_limit = 10;
  END IF;

  SELECT id, sku, name, price_cents, stock, created_at
  FROM products
  WHERE name LIKE CONCAT('%', p_search, '%') or sku LIKE CONCAT('%', p_search, '%')
  AND id > p_cursor
  ORDER BY id ASC
  LIMIT p_limit;
END $$

DELIMITER ;
