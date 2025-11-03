import axios from "axios";

export const createAndConfirmOrder = async (body) => {
    const { customer_id, items, idempotency_key, correlation_id } = body;

    if (!customer_id || !Array.isArray(items) || items.length === 0) {
        throw new Error("Invalid request body");
    }

    const loginResp = await axios.post(`${process.env.CUSTOMERS_API_BASE}/auth/login`, {
        username: process.env.CUSTOMERS_API_USER,
        password: process.env.CUSTOMERS_API_PASSWORD,
    });

    const token = loginResp.data.token;
    if (!token) {
        throw new Error("Failed to get authentication token from Customers API");
    }

    const customerResp = await axios.get(
        `${process.env.CUSTOMERS_API_BASE}/internal/customers/${customer_id}`,
        { headers: { Authorization: `Bearer ${token}` } }
    );

    console.log(customerResp);

    const customer = customerResp.data;

    const orderResp = await axios.post(`${process.env.ORDERS_API_BASE}/orders`, {
        customer_id,
        items,
    });

    const orderId = orderResp.data.order_id;


    const confirmResp = await axios.post(
        `${process.env.ORDERS_API_BASE}/orders/${orderId}/confirm`,
        {},
        { headers: { "X-Idempotency-Key": idempotency_key } }
    );

    const getOrder = await axios.get(
        `${process.env.ORDERS_API_BASE}/orders/${orderId}`,
        {}
    );


    return {
        success: true,
        correlationId: correlation_id || null,
        data: {
            customer: customer,
            order: getOrder.data,
        },
    };
};
