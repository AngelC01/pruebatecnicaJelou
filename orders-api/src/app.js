import express from 'express';
import productsRouter from './routes/product.js';
import ordersRouter from './routes/ordersRoutes.js';
import errorHandler from './middlewares/errorHandler.js';
import swaggerUi from 'swagger-ui-express';
import YAML from 'yamljs';

import dotenv from 'dotenv';
dotenv.config();

const app = express();
app.use(express.json());
const swaggerDocument = YAML.load('./src/openapi.yaml');
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
// health
app.get('/health', (_, res) => res.json({ status: 'ok' }));



// products routes
app.use('/products', productsRouter);
app.use('/orders', ordersRouter);


app.use(errorHandler);

export default app;
