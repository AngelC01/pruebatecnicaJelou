import * as repo from '../repositories/customersRepo.js';

export const createCustomer = async (payload) => {
  const { name, email, phone } = payload;
  return repo.createCustomer(name, email, phone);
};

export const getCustomer = async (id) => repo.getCustomerById(id);

export const search = async (q, cursor, limit) => repo.searchCustomers(q, cursor, limit);

export const update = async (id, payload) => {
  const { name, email, phone } = payload;
  return repo.updateCustomer(id, name, email, phone);
};

export const remove = async (id) => repo.deleteCustomer(id);
