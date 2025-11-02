export const OrderStatus = Object.freeze({
    ALL: 0,
    CREATED: 1,
    CONFIRMED: 2,
    CANCELED: 3
});

export const OrderStatusNames = Object.freeze({
    [OrderStatus.ALL]: null,
    [OrderStatus.CREATED]: 'CREATED',
    [OrderStatus.CONFIRMED]: 'CONFIRMED',
    [OrderStatus.CANCELED]: 'CANCELED'
});

export const validOrderStatusValues = Object.values(OrderStatus);
