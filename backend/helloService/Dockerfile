# Use official Node.js Alpine image as a base image
FROM node:16-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package.json package-lock.json /app/

# Install dependencies
RUN npm install

# Copy the rest of the backend files (including .env)
COPY . /app/

# Expose port 3001 (hello-service uses port 3001)
EXPOSE 3001

# Run the application with sudo (since it's required in your case)
USER root

# Command to run the application with sudo
CMD ["node", "index.js"]

