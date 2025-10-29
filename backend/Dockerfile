# Use a stable lightweight Node image
FROM node:lts-alpine

# Set working directory inside container
WORKDIR /usr/src/app

# Copy only essential files first (for better caching)
COPY package*.json ./
COPY prisma ./prisma/
COPY .env ./
COPY jsconfig.json ./

# Install dependencies
RUN npm install

# Copy the rest of your backend code
COPY . .

# Generate Prisma client
RUN npx prisma generate

# Expose backend port
EXPOSE 5000

# Start the backend server
CMD ["npm", "start"]
