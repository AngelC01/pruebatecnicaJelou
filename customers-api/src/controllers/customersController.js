import { createCustomerSchema, updateCustomerSchema } from '../validators/customersValidator.js';
import * as service from '../services/customersService.js';
import { ZodError } from 'zod';

export const create = async (req, res, next) => {
  try {
    const parsed = createCustomerSchema.parse(req.body);
    const result = await service.createCustomer(parsed);
    return res.status(200).json(result);
  } catch (err) {
    if (err instanceof ZodError) {
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
    const customer = await service.getCustomer(id);
    if (!customer) return res.status(404).json({ error: 'Customer not found' });
    return res.json(customer);
  } catch (err) {
    next(err);
  }
};

export const search = async (req, res, next) => {
  try {
    const { search, cursor, limit } = req.query;
    const results = await service.search(search, cursor, limit);
    res.json({ items: results });
  } catch (err) { next(err); }
};

export const update = async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    const parsed = updateCustomerSchema.parse(req.body);
    await service.update(id, parsed);
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

export const remove = async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    await service.remove(id);
    res.json({ success: true });
  } catch (err) { next(err); }
};
