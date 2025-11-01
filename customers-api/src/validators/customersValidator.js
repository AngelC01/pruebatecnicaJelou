import { z } from 'zod';

export const createCustomerSchema = z.object({
  name: z
    .string({ required_error: "Name is required" })
    .min(1, "Name cannot be empty"),
  email: z
    .string({ required_error: "Email is required" })
    .email("Invalid email format"),
  phone: z
    .string()
    .optional(),
});

export const updateCustomerSchema = z.object({
  name: z
    .string()
    .min(1, "Name cannot be empty")
    .optional(),
  email: z
    .string({ required_error: "Email is required" })
    .email("Invalid email format"),
  phone: z
    .string()
    .optional(),
});
