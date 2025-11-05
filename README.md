# 🧩 Products–Orders–Customers Microservicios

Este proyecto contiene un entorno **Docker Compose** que levanta tres servicios conectados entre sí:

- **db** → Base de datos MySQL con procedimientos almacenados y datos iniciales (`seed.sql`)  
- **customers-api** → API REST para gestión de clientes y autenticación  
- **orders-api** → API REST para gestión de órdenes y productos, comunicación con `customers-api` y validaciones  

---

## ⚙️ Estructura del proyecto

```
/
├── docker-compose.yml
├── db
|   ├── schema.sql
|   ├── seed.sql
├── customers-api/
│   ├── src/
│   ├── package.json
│   ├── openapi.yaml
│   └── ...
├── lambda-orchestrator/
│   ├── src/
|   └── ...
└── orders-api/
    ├── src/
    ├── package.json
    ├── openapi.yaml
    └── ...
```

---

## 🧱 Configuración de entorno

### 🗄️ Base de datos

- **Motor:** MySQL 8.0  
- **Nombre:** `DBANGEL`  
- **Usuario:** `admin`  
- **Contraseña:** `admin`  
- **Puerto expuesto:** `3306`  

El archivo `seed.sql` crea las tablas, procedimientos almacenados (SP) y carga datos iniciales de ejemplo.

---

## 🌐 Variables de entorno

### customers-api

```env
DB_HOST=db
DB_USER=admin
DB_PASSWORD=admin
DB_NAME=DBANGEL
JWT_SECRET=xyz
ADMIN_USER=admin@example.com
ADMIN_PASS=admin123
```

### orders-api

```env
DB_HOST=db
DB_USER=admin
DB_PASSWORD=admin
DB_NAME=DBANGEL
JWT_SECRET=xyz
CUSTOMERS_API_BASE=http://customers-api:3001
CUSTOMERS_API_USER=admin@example.com
CUSTOMERS_API_PASSWORD=admin123
```

---

## 🐳 Cómo ejecutar el proyecto

### 1️⃣ Levantar los contenedores

Desde la raíz del proyecto, ejecuta:

```bash
docker compose up --build
```

> 🔹 La primera vez que corras este comando, se crearán automáticamente las tablas, SP y datos iniciales desde `seed.sql`.

### 2️⃣ Verificar servicios

| Servicio       | Puerto | URL Local                      |
|----------------|--------|--------------------------------|
| MySQL (db)     | 3306   | `localhost:3306`               |
| Customers API  | 3001   | `http://localhost:3001`        |
| Orders API     | 3002   | `http://localhost:3002`        |

---

## 🧪 OpenAPI / Swagger UI

- **Customers API (Swagger UI):** `http://localhost:3001/api-docs`  
- **Orders & Products API (Swagger UI):** `http://localhost:3002/docs`  

> Asegúrate de que los servicios estén levantados antes de abrir estas URLs.

---

## 🧪 Endpoints principales

### 🧍 Customers API (`http://localhost:3001`)

#### Autenticación
```bash
curl -X POST http://localhost:3001/auth/login   -H "Content-Type: application/json"   -d '{"username": "admin@example.com", "password": "admin123"}'
```

**Response:**
```json
{
  "token": "<jwt_token>"
}
```

#### Crear cliente
```bash
curl -X POST http://localhost:3001/customers   -H "Content-Type: application/json"   -d '{"name":"Juan Pérez","email":"juan@example.com","phone":"+593999999999"}'
```

**Response**
```json
{
  "success": true,
  "customer_id": 7
}
```

#### Obtener cliente
```bash
curl -X GET http://localhost:3001/customers/2
```

**Response:**
```json
{
  "id": 2,
  "name": "AngelE Cevallos dd",
  "email": "angel.villacis@example.com",
  "phone": "+593799699497",
  "created_at": "2025-11-02T19:17:20.000Z",
  "is_active": 1
}
```

#### Buscar clientes (search + pagination)
```bash
curl -X GET "http://localhost:3001/customers?search=angel&cursor=0&limit=10"
```

**Response example:**
```json
{
  "items": [
    {
      "id": 2,
      "name": "AngelE Cevallos dd",
      "email": "angel.villacis@example.com",
      "phone": "+593799699497",
      "created_at": "2025-11-02T19:17:20.000Z"
    },
    {
      "id": 3,
      "name": "Angel Cevallos",
      "email": "angel.cevallos@example.com",
      "phone": "+593999999999",
      "created_at": "2025-11-02T19:28:36.000Z"
    }
  ]
}
```

> Parámetros:
> - `search` : texto a buscar en `name` o `email`.
> - `cursor` : id desde el cual paginar (ej. 0).
> - `limit` : máximo de resultados por página (ej. 10).

#### Eliminar cliente
```bash
curl -X DELETE http://localhost:3001/customers/5
```

**Response:**
```json
{ "success": true }
```

---

### 📦 Products API (`http://localhost:3002`)

#### Crear producto
```bash
curl -X POST http://localhost:3002/products   -H "Content-Type: application/json"   -d '{"sku":"PROD-0951","name":"Teclado 2 mecánico RGB","price_cents":6000,"stock":80}'
```

**Response:**
```json
{ "success": true, "product_id": 7 }
```

#### Obtener producto
```bash
curl -X GET http://localhost:3002/products/4
```

**Response:**
```json
{
  "id": 4,
  "sku": "PROD-0951",
  "name": "Teclado mecánico RGB",
  "price_cents": 6000,
  "stock": 80
}
```

#### Buscar productos (search + pagination)
```bash
curl -X GET "http://localhost:3002/products?search=teclado&cursor=0&limit=10"
```

**Response example:**
```json
{
  "items": [
    {
      "id": 4,
      "sku": "PROD-0951",
      "name": "Teclado mecánico RGB",
      "price_cents": 6000,
      "stock": 80,
      "created_at": "2025-11-02T19:17:20.000Z"
    },
    {
      "id": 5,
      "sku": "PROD-0952",
      "name": "Mouse inalámbrico",
      "price_cents": 4500,
      "stock": 100,
      "created_at": "2025-11-02T20:45:10.000Z"
    }
  ]
}
```

> Parámetros: `search` , `cursor` , `limit` .

#### Actualizar producto
```bash
curl -X PATCH http://localhost:3002/products/4   -H "Content-Type: application/json"   -d '{"price_cents":129900,"stock":102}'
```

**Response:**
```json
{ "success": true }
```

---

### 🧾 Orders API (`http://localhost:3002`)

#### Crear orden
```bash
curl -X POST http://localhost:3002/orders   -H "Content-Type: application/json"   -d '{"customer_id":2,"items":[{"product_id":5,"qty":3},{"product_id":6,"qty":2}]}'
```

**Response:**
```json
{ "success": true, "order_id": 116 }
```

#### Confirmar orden (idempotente)
```bash
curl -X POST http://localhost:3002/orders/103/confirm   -H "x-idempotency-key: 1234"
```

**Response:**
```json
{
  "success": true,
  "data": {
    "status": "CONFIRMED",
    "message": "Order 103 confirmed successfully"
  }
}
```

#### Cancelar orden
```bash
curl -X POST http://localhost:3002/orders/116/cancel
```

**Response:**
```json
{ "success": true, "message": "Order 116 canceled successfully" }
```

#### Obtener orden
```bash
curl -X GET http://localhost:3002/orders/105
```

**Response:** (ejemplo)
```json
{
  "success": true,
  "order": {
    "order_id": 105,
    "customer_id": 2,
    "customer_name": "AngelE Cevallos dd",
    "status": "CREATED",
    "created_at": "2025-11-02T22:20:19.000Z",
    "total_cents": 649500,
    "items": [
      { "product_id": 1, "product_name": "Producto 1234", "qty": 3, "unit_price_cents": 129900, "subtotal_cents": 389700 },
      { "product_id": 4, "product_name": "Teclado mecánico RGB", "qty": 2, "unit_price_cents": 129900, "subtotal_cents": 259800 }
    ]
  }
}
```

#### Buscar órdenes (filtros)
```bash
curl -X GET "http://localhost:3002/orders?status=2&from=2025-11-01&to=2025-11-02&cursor=0&limit=30"
```

> **Status enum:**  
> 0 = ALL, 1 = CREATED, 2 = CONFIRMED, 3 = CANCELED

**Response example:**
```json
{
  "items": [
    {
      "order_id": 103,
      "customer_name": "Angel Cevallos",
      "status": "CONFIRMED",
      "total_cents": 50000
    }
  ]
}
```

---
## 🤪 Lambda Orchestrator

### 🔹 Pasos para ejecutar el **lambda-orchestrator**

1. Dirígete a la carpeta del proyecto:

   ```bash
   cd lambda-orchestrator
   ```

2. Instala las dependencias:

   ```bash
   npm install
   ```

3. Crea un archivo `.env` dentro de `lambda-orchestrator` con el siguiente contenido:

   ```env
   CUSTOMERS_API_BASE=http://localhost:3001
   ORDERS_API_BASE=http://localhost:3002

   CUSTOMERS_API_USER=admin@example.com
   CUSTOMERS_API_PASSWORD=admin123
   PORT=3003
   ```

4. Inicia el servicio Lambda localmente:

   ```bash
   npx serverless offline
   ```

   Esto levantará el Lambda en `http://localhost:3003`.

---

## 🔗 Integración con Ngrok

Para exponer tu Lambda de forma pública y probar desde servicios externos:

1. Regístrate en [https://ngrok.com](https://ngrok.com) y genera tu token de autenticación.
2. Ejecuta en la línea de comandos:

   ```bash
   ngrok config add-authtoken 1nXXXXXXIbDKZ3cKHBjHVK_2GXX
   ```

3. Luego inicia Ngrok apuntando al puerto de tu Lambda:

   ```bash
   ngrok http 3003
   ```

   Obtendrás una URL similar a:

   ```text
   https://yourngrokurl.ngrok.io
   ```

4. Usa el siguiente endpoint POST para probar la orquestación:

   ```bash
   POST https://yourngrokurl.ngrok.io/dev/orchestrator/create-and-confirm-order
   ```

---

## 🔢 Ejemplo de Request / Response del Lambda

### Request
```json
{
  "customer_id": 6,
  "items": [
    { "product_id": 4, "qty": 3 },
    { "product_id": 5, "qty": 4 }
  ],
  "idempotency_key": "abc-123tfeaweqwwwwqeq",
  "correlation_id": "req-789"
}
```

### Response
```json
{
  "success": true,
  "correlationId": "req-789",
  "data": {
    "customer": {
      "id": 6,
      "name": "Angel EDUARD2O Cevallos",
      "email": "angel.ceval3lo3222s@example.com",
      "phone": "+593949999999",
      "created_at": "2025-11-03T00:18:19.000Z",
      "is_active": 1
    },
    "order": {
      "success": true,
      "order": {
        "order_id": 120,
        "customer_id": 6,
        "customer_name": "Angel EDUARD2O Cevallos",
        "status": "CONFIRMED",
        "created_at": "2025-11-03T03:22:25.000Z",
        "total_cents": 413700,
        "items": [
          { "product_id": 4, "product_name": "Teclado mecánico RGB", "qty": 3, "unit_price_cents": 129900, "subtotal_cents": 389700 },
          { "product_id": 5, "product_name": "Teclado 2 mecánico RGB", "qty": 4, "unit_price_cents": 6000, "subtotal_cents": 24000 }
        ]
      }
    }
  }
}
```
---

## 👨‍💻 Autor

**Ángel Cevallos**  
Desarrollador Full Stack (.NET / Node.js / Flutter)  
📧 [angelcevallosvillacis@gmail.com](mailto:angelcevallosvillacis@gmail.com)

---

## ✅ Estado del proyecto

> Proyecto funcional con Docker Compose, APIs conectadas y base de datos inicializada automáticamente con SP y datos de ejemplo.
