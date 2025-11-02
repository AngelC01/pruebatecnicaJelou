import * as repo from "../repositories/ordersRepository.js";
import * as customersApi from "../integrations/customersApi.js";


export const createOrder = async (payload) => {
  const { customer_id, items } = payload;

  const customer = await customersApi.getCustomerById(customer_id);
  if (!customer || !customer.id) {
    throw new Error(`Customer with ID ${customer_id} not found`);
  }

  if (!items || items.length === 0) {
    throw new Error("Order must contain at least one item");
  }

    return  repo.createOrder(customer_id, items);


};

export  const confirmOrder= async (orderId, idempotencyKey) =>{
  if (!idempotencyKey) {
    throw new Error('Missing X-Idempotency-Key header');
  }
  const result =  repo.confirmOrderSP(orderId, idempotencyKey);
  return result;
}

export const getOrders = async (filters) => {
  return await repo.getOrdersSP(filters);
};