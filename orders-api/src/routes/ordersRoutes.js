import express from 'express';
import * as ctrl from '../controllers/ordersController.js';

const router = express.Router();

router.post('/', ctrl.create);
router.post('/:id/confirm', ctrl.confirmOrder);
router.get('/', ctrl.getOrders);
router.post('/:id/cancel', ctrl.cancelOrder);
router.get('/:id', ctrl.getById);

export default router;
