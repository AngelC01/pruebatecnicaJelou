# Dockerfile para DBANGEL (opcional)
FROM mysql:8.0

# Variables por defecto (puedes sobrescribir desde docker-compose)
ENV MYSQL_ROOT_PASSWORD=admin
ENV MYSQL_DATABASE=DBANGEL
ENV MYSQL_USER=admin
ENV MYSQL_PASSWORD=admin

# Copiar scripts SQL (se ejecutan automáticamente al iniciar)
COPY ./db/schema.sql /docker-entrypoint-initdb.d/1_schema.sql
COPY ./db/seed.sql /docker-entrypoint-initdb.d/2_seed.sql

EXPOSE 3306