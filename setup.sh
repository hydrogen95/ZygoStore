#!/bin/bash

# ZygoSMP Website Setup Script
# This script sets up the complete ZygoSMP website with backend and frontend

echo "🚀 ZygoSMP Website Setup"
echo "========================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js 18+ first.${NC}"
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo -e "${RED}❌ Node.js version 18+ is required. Current version: $(node -v)${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Node.js $(node -v) detected${NC}"

# Check if MySQL is installed
if ! command -v mysql &> /dev/null; then
    echo -e "${YELLOW}⚠️  MySQL is not detected. Please ensure MySQL is installed and running.${NC}"
    echo -e "${YELLOW}   You can still proceed, but database features won't work.${NC}"
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p backend/uploads/payment_proofs
mkdir -p backend/uploads/qr_code
mkdir -p public/images
chmod -R 755 backend/uploads

# Install frontend dependencies
echo "📦 Installing frontend dependencies..."
npm install

# Install backend dependencies
echo "📦 Installing backend dependencies..."
cd backend
npm install
cd ..

# Create .env file if it doesn't exist
if [ ! -f backend/.env ]; then
    echo "📝 Creating backend .env file..."
    cp backend/.env.example backend/.env
    echo -e "${YELLOW}⚠️  Please edit backend/.env with your database credentials${NC}"
fi

# Build frontend
echo "🔨 Building frontend..."
npm run build

# Setup complete
echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Edit backend/.env with your database credentials"
echo "2. Import the database schema: mysql -u root -p < backend/src/config/schema.sql"
echo "3. Start the backend: cd backend && npm start"
echo "4. The frontend is built in the dist/ folder"
echo ""
echo "For production deployment:"
echo "- Upload dist/ folder to your web server"
echo "- Upload backend/ folder to your server"
echo "- Configure your web server to serve the backend API"
echo "- Set up SSL certificate for HTTPS"