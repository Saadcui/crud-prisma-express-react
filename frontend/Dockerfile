# Use lightweight Node.js image
FROM node:lts-alpine

# Set working directory
WORKDIR /usr/src/app

# Copy dependency files and install packages
COPY package*.json ./
RUN npm install

# Copy the rest of the app source code
COPY . .

# 🧩 Build the React app (this creates the /build folder)
RUN npm run build

# Expose the port your Express server uses
EXPOSE 3001

# Start Express server that serves the build
CMD ["node", "server.js"]
