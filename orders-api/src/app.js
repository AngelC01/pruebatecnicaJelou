import express from 'express';
import productsRouter from './routes/product.js';
import ordersRouter from './routes/ordersRoutes.js';

import errorHandler from './middlewares/errorHandler.js';


import dotenv from 'dotenv';
dotenv.config();

const app = express();
app.use(express.json());

// health
app.get('/health', (_, res) => res.json({ status: 'ok' }));



// products routes
app.use('/products', productsRouter);
app.use('/orders', ordersRouter);


app.use(errorHandler);

export default app;
