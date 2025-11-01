import express from 'express';
import * as ctrl from '../controllers/customersController.js';
import { authMiddleware } from '../middlewares/auth.js';

const router = express.Router();

// Protected resource endpoints (require JWT)
router.post('/',  ctrl.create);
router.get('/', ctrl.search);
router.get('/:id', ctrl.getById);
router.put('/:id', ctrl.update);
router.delete('/:id', ctrl.remove);

export default router;
