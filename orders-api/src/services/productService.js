import * as repo  from '../repositories/productRepository.js';


export const  createProduct= async (payload) =>{
    const  { sku, name, price_cents, stock } =payload;
    return repo.createProduct(sku, name, price_cents, stock);
  };


export const getProductById=async (id) => repo.getProductById(id);

export const search = async (q, cursor, limit) => repo.searchProducts(q, cursor, limit);


export const updateProduct= async  (id, payload) => {
    const { price_cents, stock } = payload;

    return repo.updateProduct(id, price_cents, stock);
  };

