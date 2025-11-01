import { createProductSchema, updateProductSchema } from '../validators/productValidator.js';
import { ZodError } from 'zod';

import * as service from '../services/productService.js';

export const create = async (req, res, next) => {
    try {
      const parsed = createProductSchema.parse(req.body);      
      await service.createProduct(parsed);
      return res.status(201).json({ success: true });
    } catch (err) {
      if (err instanceof ZodError) {
      // Devuelve solo los mensajes de error
      const messages = err.errors.map(e => ({
        field: e.path.join('.'),
        message: e.message
      }));
      return res.status(400).json({ errors: messages });
    }

    return next(err);
    }
  };

export const getById = async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    const product = await service.getProductById(id);
    if (!product) return res.status(404).json({ error: 'Product not found' });
    return res.json(product);
  } catch (err) {
    next(err);
  }
};

export const search = async (req, res, next) => {
  try {
      const { search = '', cursor = 0, limit = 10 } = req.query;
    const results = await service.search(search, cursor, limit);
    res.json({ items: results });
  } catch (err) { next(err); }
};

export const update = async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    const parsed = updateProductSchema.parse(req.body);
    await service.updateProduct(id, parsed);
    res.json({ success: true });
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


