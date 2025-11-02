import { z } from "zod";
import { validOrderStatusValues } from '../enums/orderStatusEnum.js';

export const createOrderSchema = z.object({
  customer_id: z.number().int().positive(),
  items: z.array(
    z.object({
      product_id: z.number().int().positive(),
      qty: z.number().int().positive(),
    })
  ).nonempty(),
});



export const getOrdersSchema = z.object({
  status: z
    .string({
      required_error: 'Status is required'
    })
    .transform((val) => Number(val))
    .refine((n) => validOrderStatusValues.includes(n), 'Invalid status value'),

  from: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid from date format (expected YYYY-MM-DD)')
    .optional(),

  to: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid to date format (expected YYYY-MM-DD)')
    .optional(),

  cursor: z
    .string({
      required_error: 'Cursor is required'
    })
    .transform((val) => Number(val))
    .refine((n) => n >= 0, 'Cursor must be a positive number'),

  limit: z
    .string({
      required_error: 'Limit is required'
    })
    .transform((val) => Number(val))
    .refine((n) => n > 0 && n <= 100, 'Limit must be between 1 and 100')
});
