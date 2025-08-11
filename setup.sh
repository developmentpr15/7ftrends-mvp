#!/bin/bash

# Stop on the first sign of error
set -e

# Print a welcome message
echo "Setting up your development environment..."

# Navigate to the project directory
cd "$(dirname "$0")"

# Clone the repository if it doesn't exist
if [ ! -d "$(pwd)" ]; then
  git clone https://github.com/your-username/7ftrends-mvp.git
fi

# Create a .env file with environment variables
if [ ! -f .env ]; then
  touch .env
fi

# Add environment variables to .env
echo "AUTH_URL=localhost" >> .env
echo "GRAPHQL_ADMIN_SECRET=your-secret-key" >> .env
echo "POSTGRES_PASSWORD=your-db-password" >> .env
echo "JWT_SECRET=your-jwt-secret" >> .env

# Download docker-compose.yml
curl -L https://raw.githubusercontent.com/nhost/nhost/main/examples/docker-compose/docker-compose.yaml > docker-compose.yml

# Start Docker Compose
docker-compose up -d

# Create a Flutter app
flutter create app --org com.sevenftrends

# Print a success message
echo "Setup complete!"