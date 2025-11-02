import express from 'express';
import * as ctrl from '../controllers/ordersController.js';

const router = express.Router();

router.post('/', ctrl.create);
router.post('/:id/confirm', ctrl.confirmOrder);
router.get('/', ctrl.getOrders);


export default router;
