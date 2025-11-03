FROM node:22-alpine

WORKDIR /usr/src/app

COPY package*.json ./

# Instala todas las dependencias (producción + desarrollo)
RUN npm install

COPY . .

EXPOSE 3002

ENV NODE_ENV=development

CMD ["npm", "start"]
