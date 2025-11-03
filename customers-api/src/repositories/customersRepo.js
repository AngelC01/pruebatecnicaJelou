import db from '../config/db.js';

export const createCustomer = async (name, email, phone) => {
  const [rows] = await db.query('CALL sp_create_customer(?,?,?)', [name, email, phone]);
  const customerId = rows?.[0]?.[0]?.customer_id || null;

  return {
    success: true,
    customer_id: customerId
  };
};

export const getCustomerById = async (id) => {
  const [rows] = await db.query('CALL sp_get_customer_by_id(?)', [id]);
  return rows[0][0] ?? null;
};

export const searchCustomers = async (search, cursor, limit) => {
  const lim = Number(limit) || 20;
  const cur = cursor ? Number(cursor) : null;
  const [rows] = await db.query('CALL sp_search_customers(?,?,?)', [search || '', cur, lim]);
  return rows[0] || [];
};

export const updateCustomer = async (id, name, email, phone) => {
  await db.query('CALL sp_update_customer(?,?,?,?)', [id, name, email, phone]);
  return { success: true };
};

export const deleteCustomer = async (id) => {
  await db.query('CALL sp_delete_customer(?)', [id]);
  return { success: true };
};
