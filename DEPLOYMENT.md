# ZygoSMP Website - Deployment Guide

## Overview

This guide covers deploying the ZygoSMP Minecraft server website to production environments including cPanel, shared hosting, VPS, and dedicated servers.

## System Requirements

- **Node.js**: 18.x or higher
- **MySQL**: 5.7+ or MariaDB 10.3+
- **Web Server**: Apache/Nginx (for static files)
- **SSL Certificate**: Required for HTTPS

## Project Structure

```
zygosmp/
├── backend/              # Node.js/Express API
│   ├── server.js         # Main server file
│   ├── src/
│   │   ├── config/       # Database config
│   │   ├── controllers/  # API controllers
│   │   ├── middleware/   # Auth & upload middleware
│   │   ├── routes/       # API routes
│   │   └── utils/        # Helper functions
│   ├── uploads/          # File uploads directory
│   └── .env              # Environment variables
├── dist/                 # Built frontend (after npm run build)
├── src/                  # Frontend source code
├── public/               # Static assets
└── setup.sh              # Setup script
```

## Database Setup

### 1. Create Database

```sql
CREATE DATABASE zygosmp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'zygosmp_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON zygosmp.* TO 'zygosmp_user'@'localhost';
FLUSH PRIVILEGES;
```

### 2. Import Schema

```bash
mysql -u zygosmp_user -p zygosmp < backend/src/config/schema.sql
```

## Configuration

### Backend Environment Variables (backend/.env)

```env
# Database Configuration
DB_HOST=localhost
DB_USER=zygosmp_user
DB_PASSWORD=your_secure_password
DB_NAME=zygosmp
DB_PORT=3306

# JWT Secret (generate a strong random string)
JWT_SECRET=your_super_secret_jwt_key_min_32_chars

# Admin Credentials
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your_secure_admin_password

# Server Configuration
PORT=3001
NODE_ENV=production

# Discord Webhook (Optional)
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...

# Frontend URL (for CORS)
FRONTEND_URL=https://yourdomain.com
```

### Generate Secure Password Hash

To generate a secure bcrypt hash for the admin password:

```bash
node -e "const bcrypt = require('bcryptjs'); console.log(bcrypt.hashSync('your_password', 10));"
```

## Deployment Options

### Option 1: cPanel/Shared Hosting

1. **Upload Files**:
   - Upload `dist/` contents to `public_html/`
   - Upload `backend/` to a separate directory (e.g., `~/backend/`)

2. **Setup Node.js App**:
   - In cPanel, go to "Setup Node.js App"
   - Create new application pointing to `backend/` directory
   - Set application URL to `yourdomain.com/api`
   - Start the application

3. **Configure .htaccess**:
   ```apache
   # public_html/.htaccess
   RewriteEngine On
   RewriteBase /
   
   # API requests go to Node.js
   RewriteRule ^api/(.*)$ http://localhost:3001/$1 [P,L]
   
   # Static assets
   RewriteCond %{REQUEST_FILENAME} -f
   RewriteRule ^ - [L]
   
   # Everything else to index.html (SPA)
   RewriteRule ^ index.html [L]
   ```

4. **Update API URL**:
   - Edit `dist/assets/index-*.js` to point to your API URL
   - Or rebuild with correct `VITE_API_URL`

### Option 2: VPS/Dedicated Server

1. **Install Dependencies**:
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install nodejs npm mysql-server nginx
   
   # Configure MySQL
   sudo mysql_secure_installation
   ```

2. **Setup Project**:
   ```bash
   git clone <your-repo> /var/www/zygosmp
   cd /var/www/zygosmp
   ./setup.sh
   ```

3. **Configure Nginx**:
   ```nginx
   # /etc/nginx/sites-available/zygosmp
   server {
       listen 80;
       server_name yourdomain.com;
       return 301 https://$server_name$request_uri;
   }
   
   server {
       listen 443 ssl http2;
       server_name yourdomain.com;
       
       ssl_certificate /path/to/cert.pem;
       ssl_certificate_key /path/to/key.pem;
       
       # Frontend
       location / {
           root /var/www/zygosmp/dist;
           try_files $uri $uri/ /index.html;
       }
       
       # API
       location /api/ {
           proxy_pass http://localhost:3001/;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
       
       # Uploads
       location /uploads/ {
           alias /var/www/zygosmp/backend/uploads/;
       }
   }
   ```

4. **Setup PM2**:
   ```bash
   sudo npm install -g pm2
   cd /var/www/zygosmp/backend
   pm2 start server.js --name zygosmp-api
   pm2 startup
   pm2 save
   ```

5. **Enable Site**:
   ```bash
   sudo ln -s /etc/nginx/sites-available/zygosmp /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

### Option 3: Docker Deployment

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY backend/package*.json ./backend/

# Install dependencies
RUN npm ci --only=production
RUN cd backend && npm ci --only=production

# Copy source
COPY . .

# Build frontend
RUN npm run build

# Expose ports
EXPOSE 3001

# Start command
CMD ["node", "backend/server.js"]
```

## Security Checklist

- [ ] Change default admin password
- [ ] Use strong JWT secret (32+ characters)
- [ ] Enable HTTPS
- [ ] Set secure database passwords
- [ ] Configure firewall (allow only 80, 443, 22)
- [ ] Set proper file permissions (uploads: 755)
- [ ] Enable MySQL remote access only if needed
- [ ] Regular backups
- [ ] Update dependencies regularly

## File Permissions

```bash
# Set proper permissions
chmod -R 755 backend/uploads
chmod 600 backend/.env
chown -R www-data:www-data /var/www/zygosmp
```

## Troubleshooting

### Backend won't start
- Check if port 3001 is available
- Verify database connection
- Check .env file exists and is correct

### Frontend can't connect to API
- Verify API URL in frontend build
- Check CORS settings in backend
- Ensure API is running

### File uploads not working
- Check uploads directory permissions
- Verify PHP upload limits (if using PHP proxy)
- Check Node.js memory limits

### Database connection errors
- Verify MySQL is running
- Check credentials in .env
- Ensure database exists

## Maintenance

### Update Application
```bash
cd /var/www/zygosmp
git pull
npm install
cd backend && npm install
cd ..
npm run build
pm2 restart zygosmp-api
```

### Backup Database
```bash
mysqldump -u root -p zygosmp > backup_$(date +%Y%m%d).sql
```

### View Logs
```bash
# Backend logs
pm2 logs zygosmp-api

# Nginx logs
sudo tail -f /var/log/nginx/error.log
```

## Support

For issues or questions:
1. Check the logs
2. Verify configuration
3. Test database connection
4. Check file permissions