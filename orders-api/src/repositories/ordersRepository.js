import db from '../config/db.js';
import { OrderStatusNames } from '../enums/orderStatusEnum.js'
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

export const getOrdersSP = async ({ status, from, to, cursor, limit }) => {
  const lim = Number(limit) || 20;
  const dbStatus = status ? OrderStatusNames[status] : null;

  const [rows] = await db.query(
    'CALL sp_get_orders_with_items(?, ?, ?, ?, ?)',
    [dbStatus, from || null, to || null, cursor, lim]
  );

  // El resultado del SP está en la primera posición
  return rows[0];
};