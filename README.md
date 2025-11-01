# 🧩 Products–Orders–Customers Microservices

Este proyecto contiene un entorno **Docker Compose** que levanta tres servicios conectados entre sí:

- **db** → Base de datos MySQL con procedimientos almacenados y datos iniciales (`seed.sql`)  
- **customers-api** → API REST para gestión de clientes  
- **orders-api** → API REST para gestión de órdenes, comunicación con `customers-api` y validaciones  

---

## ⚙️ Estructura del proyecto

```
/
├── docker-compose.yml
├── seed.sql
├── customers-api/
│   ├── src/
│   ├── package.json
│   ├── .gitignore
│   └── ...
└── orders-api/
    ├── src/
    ├── package.json
    ├── .gitignore
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

---

### 2️⃣ Verificar servicios

| Servicio       | Puerto | URL Local                      |
|----------------|--------|--------------------------------|
| MySQL (db)     | 3306   | `localhost:3306`               |
| Customers API  | 3001   | `http://localhost:3001`        |
| Orders API     | 3002   | `http://localhost:3002`        |

---

### 3️⃣ Reiniciar o recargar datos

Si realizas cambios en `seed.sql` y deseas que Docker lo ejecute nuevamente:

```bash
docker compose down -v
docker compose up --build
```

Esto eliminará los volúmenes (`db_data`) y recargará toda la base de datos desde cero.

---

## 🧪 Endpoints principales

### 🧍 Customers API (`http://localhost:3001`)

| Método | Endpoint | Descripción |
|--------|-----------|-------------|
| `POST` | `/customers` | Crea un nuevo cliente |
| `GET`  | `/customers/:id` | Obtiene cliente por ID |
| `POST` | `/auth/login` | Autenticación (admin) |

**Ejemplo login**
```json
POST /auth/login
{
  "username": "admin@example.com",
  "password": "admin123"
}
```

---

### 📦 Orders API (`http://localhost:3002`)

| Método | Endpoint | Descripción |
|--------|-----------|-------------|
| `POST` | `/orders` | Crea una nueva orden |
| `POST` | `/orders/:id/confirm` | Confirma una orden (idempotente) |


**Ejemplo crear orden**
```json
POST /orders
{
  "customer_id": 1,
  "items": [
    { "product_id": 1, "qty": 2 },
    { "product_id": 2, "qty": 1 }
  ]
}
```

**Ejemplo confirmar orden**
```
POST /orders/100/confirm
Headers:
  X-Idempotency-Key: 12345-abcde
```

---

## 🧰 Tecnologías utilizadas

- Node.js (Express)
- MySQL 8
- Docker Compose
- Clean Architecture
- Zod para validaciones
- JWT para autenticación

---

## 🧼 Comandos útiles

### Detener los contenedores
```bash
docker compose down
```

### Eliminar contenedores y volúmenes (reset total)
```bash
docker compose down -v
```

---

## 📂 Archivos importantes

| Archivo | Descripción |
|----------|-------------|
| `docker-compose.yml` | Define los servicios y puertos del proyecto |
| `seed.sql` | Script de inicialización de la base con tablas, SP y datos |
| `.gitignore` | Ignora dependencias y archivos innecesarios en el repo |
| `customers-api/` | Código fuente del microservicio de clientes |
| `orders-api/` | Código fuente del microservicio de órdenes |

---

## 🧪 Probar con Postman

1. Inicia todos los contenedores (`docker compose up --build`)
2. Abre Postman y crea un nuevo request:

**Login**
```
POST http://localhost:3001/auth/login
Body (raw JSON):
{
  "username": "admin@example.com",
  "password": "admin123"
}
```

Copia el token del login.

**Crear orden**
```
POST http://localhost:3002/orders
Body:
{
  "customer_id": 1,
  "items": [
    { "product_id": 1, "qty": 2 },
    { "product_id": 2, "qty": 1 }
  ]
}
```


## 👨‍💻 Autor

**Ángel Cevallos**  
Desarrollador Full Stack (.NET / Node.js / Flutter)  
📧 [angelcevallosvillacis@gmail.com](mailto:angelcevallosvillacis@gmail.com)

---

## ✅ Estado del proyecto

> Proyecto funcional con Docker Compose, APIs conectadas y base de datos inicializada automáticamente con SP y datos de ejemplo.
