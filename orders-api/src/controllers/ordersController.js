import { createOrderSchema, getOrdersSchema } from '../validators/ordersValidator.js';
import { ZodError } from 'zod';

import * as service from '../services/ordersService.js';

export const create = async (req, res, next) => {
  try {
    const parsed = createOrderSchema.parse(req.body);
    const result = await service.createOrder(parsed);
    return res.status(200).json(result);
  } catch (err) {
    if (err instanceof ZodError) {
      const messages = err.errors.map(e => ({
        field: e.path.join('.'),
        message: e.message
      }));
      return res.status(400).json({ errors: messages });
    }
    next(err);

  }
};

export const confirmOrder = async (req, res, next) => {
  try {
    const orderId = Number(req.params.id);
    const idempotencyKey = req.headers['x-idempotency-key'];

    const result = await service.confirmOrder(orderId, idempotencyKey);
    console.log(result);

    return res.status(200).json({
      success: true,
      data: result
    });
  } catch (err) {
    console.error('Error confirming order:', err);
    return res.status(400).json({
      success: false,
      error: err.message
    });
  }
}


export const getOrders = async (req, res, next) => {
  try {
    const parsed = getOrdersSchema.parse(req.query);

    const orders = await service.getOrders(parsed);

    return res.json({ success: true, data: orders });
  } catch (err) {
    if (err instanceof ZodError) {
      const messages = err.errors.map(e => ({
        field: e.path.join('.'),
        message: e.message
      }));
      return res.status(400).json({ errors: messages });
    }
    next(err);
  }
};


export const cancelOrder = async (req, res, next) => {
  try {
    const orderId = Number(req.params.id);
    const result = await service.cancelOrder(orderId);
    return res.status(200).json({
      success: Boolean(result.success),
      message: result.message
    });
  } catch (err) {
    next(err);
  }
};


export const getById = async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    if (isNaN(id) || id <= 0) {
      return res.status(400).json({ success: false, message: 'Invalid order ID' });
    }

    const order = await service.getOrderById(id);
    return res.json({ success: true, order });
  } catch (err) {
    next(err);
  }
};
