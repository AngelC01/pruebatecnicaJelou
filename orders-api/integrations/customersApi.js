import axios from "axios";

const CUSTOMERS_API_BASE = process.env.CUSTOMERS_API_BASE || "http://localhost:3001";
const CUSTOMERS_API_USER = process.env.CUSTOMERS_API_USER || "admin@example.com";
const CUSTOMERS_API_PASSWORD = process.env.CUSTOMERS_API_PASSWORD || "admin123";

let cachedToken = null;
let tokenExpiration = null;

const getAuthToken = async () => {
  const now = Date.now();

  // reutiliza token si aún es válido (por ejemplo 10 minutos)
  if (cachedToken && tokenExpiration && now < tokenExpiration) {
    return cachedToken;
  }

  const credentials = {
    username: CUSTOMERS_API_USER,
    password: CUSTOMERS_API_PASSWORD,
  };

  const { data } = await axios.post(`${CUSTOMERS_API_BASE}/auth/login`, credentials);

  cachedToken = data.token;
  tokenExpiration = now + 10 * 60 * 1000; // 10 minutos

  return cachedToken;
};

export const getCustomerById = async (id) => {
  const token = await getAuthToken();
  const { data } = await axios.get(`${CUSTOMERS_API_BASE}/internal/customers/${id}`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });
  return data;
};
