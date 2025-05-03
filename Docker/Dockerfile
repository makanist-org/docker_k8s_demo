FROM node:alpine

WORKDIR /src

# Copy package files first to leverage Docker cache
COPY ./src/package.json .

# Install dependencies
RUN npm install

# Copy rest of the application
COPY ./src/ .

EXPOSE 3000

CMD ["node", "server.js"]