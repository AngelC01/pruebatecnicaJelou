import { z } from 'zod';

export const createProductSchema  = z.object({
  sku: z.string().min(5, "SKU must be at least 5 characters"),
  name: z.string().min(5, "Name must be at least 5 characters"),
  price_cents: z.number({ required_error: "price_cents is required" })
    .gt(0, "price_cents must be greater than 0"),
  stock: z.number({ required_error: "stock is required" })
    .min(0, "stock cannot be negative"),
});

export const updateProductSchema  = z.object({
  price_cents: z.number({ required_error: "price_cents is required" })
    .gt(0, "price_cents must be greater than 0"),
  stock: z.number({ required_error: "stock is required" })
    .min(0, "stock cannot be negative"),
});
