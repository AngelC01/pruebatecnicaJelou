import express from 'express';
import customersRouter from './routes/customers.js';
import errorHandler from './middlewares/errorHandler.js';
import { authMiddleware } from './middlewares/auth.js';
import * as repo from './repositories/customersRepo.js';
import swaggerUi from 'swagger-ui-express';
import YAML from 'yamljs';
import dotenv from 'dotenv';
import { generateToken } from './middlewares/auth.js';


dotenv.config();

const app = express();
app.use(express.json());
const swaggerDocument = YAML.load('./src/openapi.yaml');
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
// health
app.get('/health', (_, res) => res.json({ status: 'ok' }));

app.post('/auth/login', (req, res) => {
  const { username, password } = req.body;
  if (username === process.env.ADMIN_USER && password === process.env.ADMIN_PASS) {
    const token = generateToken({ username, role: 'admin' });
    return res.json({ token });
  }
  return res.status(401).json({ error: 'Invalid credentials' });
});

// customers routes
app.use('/customers', customersRouter);

// internal endpoint required by Orders service
app.get('/internal/customers/:id', authMiddleware, async (req, res) => {

  const customer = await repo.getCustomerById(Number(req.params.id));
  if (!customer) return res.status(404).json({ error: 'Customer not found' });
  return res.json(customer);
});

app.use(errorHandler);

export default app;
