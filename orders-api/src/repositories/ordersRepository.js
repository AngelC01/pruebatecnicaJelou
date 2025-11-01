import db from '../config/db.js';

export const createOrder = async (customer_id, items) => {
    console.log(items);
    const [rows] = await db.query(`CALL sp_create_order(?, ?)`, [
      customer_id,
      JSON.stringify(items)
    ]);
    return { success: true };
};

export const confirmOrderSP = async (orderId, idempotencyKey) => {
  const [rows] = await db.query(
    'CALL sp_confirm_order_idempotent(?, ?)',
    [orderId, idempotencyKey]
  );
  // El SP devuelve un SELECT con alias "response"
  const result = rows[0][0]?.response || '{}';
 if (typeof result === 'object') {
    return result;
  }

  // Si es string JSON, intentar parsear
  try {
    return JSON.parse(result);
  } catch {
    return { message: result };
  }
};