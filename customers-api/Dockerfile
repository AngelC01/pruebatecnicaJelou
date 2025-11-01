FROM node:22-alpine

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm ci --production

COPY . .

EXPOSE 3001

ENV NODE_ENV=production

CMD ["node", "src/index.js"]
