import db from '../config/db.js';

 export const  createProduct = async  (sku, name, price_cents, stock)=> {
    const [rows] = await db.query('CALL sp_create_product(?, ?, ?, ?)', [
      sku,
      name,
      price_cents,
      stock,
    ]);
     return { success: true };

  };

export const  getProductById= async  (id) => {
    const [rows] = await db.query('CALL sp_get_product_by_id(?)', [id]);
    return rows[0][0];
  };

export const searchProducts= async  (search = '', cursor = 0, limit = 10) => {
    const [rows] = await db.query('CALL sp_search_products(?, ?, ?)', [
      search,
      cursor,
      limit,
    ]);
    return rows[0];
  };

  export const updateProduct= async  (id, price_cents, stock) => {
    const [rows] = await db.query('CALL sp_update_product(?, ?, ?)', [
      id,
      price_cents,
      stock,
    ]);
    return { success: true };
  };

