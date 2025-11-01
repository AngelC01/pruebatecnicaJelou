import { createOrderSchema } from '../validators/ordersValidator.js';
import { ZodError } from 'zod';

import * as service from '../services/ordersService.js';

export const create = async (req, res, next) => {
  try {
    const parsed = createOrderSchema.parse(req.body);
    await service.createOrder(parsed);
    return res.status(201).json({ success: true });
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

export  const  confirmOrder= async(req, res, next) =>{
  try {
    const orderId = Number(req.params.id);
    const idempotencyKey = req.headers['x-idempotency-key'];

    const result = await  service.confirmOrder(orderId, idempotencyKey);
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