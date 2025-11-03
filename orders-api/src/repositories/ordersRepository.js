import db from '../config/db.js';
import { OrderStatusNames } from '../enums/orderStatusEnum.js'
export const createOrder = async (customer_id, items) => {
  console.log(items);
  const [rows] = await db.query(`CALL sp_create_order(?, ?)`, [
    customer_id,
    JSON.stringify(items)
  ]);
  const orderId = rows?.[0]?.[0]?.order_id || null;

  return {
    success: true,
    order_id: orderId,
  };
};

export const confirmOrderSP = async (orderId, idempotencyKey) => {
  const [rows] = await db.query(
    'CALL sp_confirm_order_idempotent(?, ?)',
    [orderId, idempotencyKey]
  );

  const result = rows[0][0]?.response || '{}';
  if (typeof result === 'object') {
    return result;
  }


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

  return rows[0];
};


export const cancelOrderSP = async (orderId) => {
  const [rows] = await db.query('CALL sp_cancel_order(?)', [orderId]);
  return rows[0][0];
};

export const getOrderById = async (orderId) => {
  const [results] = await db.query('CALL sp_get_order_by_id(?)', [orderId]);

  const order = results[0]?.[0];
  const items = results[1] || [];

  return {
    ...order,
    items
  };
};