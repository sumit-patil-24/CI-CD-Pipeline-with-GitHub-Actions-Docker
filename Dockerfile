FROM node:18-alpine
WORKDIR /usr/src/app

# Install dependencies separately for caching
COPY package*.json ./

# Install both production and dev dependencies
RUN npm install --include=dev

COPY . .
EXPOSE 3000
CMD ["node", "src/app.js"]