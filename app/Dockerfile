FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# Copy only package.json first for better caching
COPY package.json ./

# Clear npm cache and install dependencies
RUN npm cache clean --force && \
    npm install --production --no-audit --no-fund && \
    npm cache clean --force

# Copy app source
COPY . .

# Expose port
EXPOSE 3000

# Run as non-root user
USER node

# Start the application
CMD [ "node", "server.js" ]
