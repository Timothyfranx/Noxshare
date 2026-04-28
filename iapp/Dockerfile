FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production || npm install --only=production
COPY src/index.js .
ENTRYPOINT ["node", "/app/index.js"]
