FROM node:18-alpine
WORKDIR /usr/src/app
COPY package*.json ./

# Install dependencies based on environment
ARG NODE_ENV=production
RUN if [ "$NODE_ENV" = "production" ]; then npm install --production; else npm install --include=dev; fi

COPY . .
EXPOSE 3000
CMD ["node", "src/app.js"]