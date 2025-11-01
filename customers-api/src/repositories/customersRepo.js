import db from '../config/db.js';

export const createCustomer = async (name, email, phone) => {
  const [rows] = await db.query('CALL sp_create_customer(?,?,?)', [name, email, phone]);
  // MySQL returns array of results; stored proc insert no result — return insertId via select? For simplicity return ok
  return { success: true };
};

export const getCustomerById = async (id) => {
  const [rows] = await db.query('CALL sp_get_customer_by_id(?)', [id]);
  // rows is an array: rows[0] contains selected rows
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
