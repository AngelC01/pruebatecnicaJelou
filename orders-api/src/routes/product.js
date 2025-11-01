import express from 'express';
import * as ctrl from '../controllers/productController.js';

const router = express.Router();

router.post('/',  ctrl.create);
router.get('/', ctrl.search);
router.get('/:id', ctrl.getById);
router.patch('/:id', ctrl.update);


export default router;
