# Security Guide for ZygoSMP Website

## Overview

This document outlines security best practices for deploying and maintaining the ZygoSMP website.

## Environment Variables

### Required Secure Configuration

```env
# Database - Use strong passwords
DB_PASSWORD=UseAComplexPassword123!@#

# JWT Secret - Minimum 32 characters, randomly generated
JWT_SECRET=YourSuperSecretRandomStringHereMin32Chars

# Admin Password - Strong, unique password
ADMIN_PASSWORD=AdminStrongPassword456!@#
```

### Generating Secure Secrets

```bash
# Generate JWT secret (32+ chars)
openssl rand -base64 48

# Generate bcrypt hash for admin password
node -e "const bcrypt = require('bcryptjs'); console.log(bcrypt.hashSync('your_password', 10));"
```

## File Permissions

```bash
# Set secure permissions
chmod 600 backend/.env
chmod -R 755 backend/uploads
chmod -R 644 dist/*

# Ownership (on Linux servers)
chown -R www-data:www-data /var/www/zygosmp
```

## HTTPS Configuration

### Nginx SSL Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;
    
    # HSTS
    add_header Strict-Transport-Security "max-age=63072000" always;
}
```

## Input Validation

The application validates:
- **Minecraft IGN**: 1-16 alphanumeric characters + underscores
- **Discord Username**: 2-32 characters
- **File Uploads**: Images only (JPG, PNG, WebP), max 5MB
- **Order Amounts**: Must match rank price exactly

## SQL Injection Prevention

- All database queries use parameterized statements
- User input is never directly concatenated into SQL

## XSS Prevention

- User input is sanitized before display
- Content Security Policy headers recommended

## Rate Limiting Recommendation

Add to backend for production:

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});

app.use('/api/', limiter);
```

## Backup Strategy

### Database Backup

```bash
#!/bin/bash
# backup.sh - Run daily via cron

DATE=$(date +%Y%m%d)
mysqldump -u root -p zygosmp > /backups/zygosmp_$DATE.sql
# Keep only last 7 days
find /backups -name "zygosmp_*.sql" -mtime +7 -delete
```

### File Backup

```bash
# Backup uploads directory
tar -czf /backups/uploads_$DATE.tar.gz /var/www/zygosmp/backend/uploads/
```

## Security Checklist

- [ ] Change all default passwords
- [ ] Enable HTTPS
- [ ] Set secure file permissions
- [ ] Configure firewall (allow only 80, 443, 22)
- [ ] Disable MySQL remote root access
- [ ] Enable automatic security updates
- [ ] Setup monitoring and alerts
- [ ] Regular backup verification
- [ ] Keep dependencies updated

## Incident Response

If security breach suspected:

1. **Immediate Actions**:
   - Change all passwords
   - Revoke all JWT tokens
   - Check access logs

2. **Investigation**:
   - Review database for unauthorized changes
   - Check file integrity
   - Analyze server logs

3. **Recovery**:
   - Restore from clean backup if needed
   - Apply security patches
   - Update all credentials

## Contact

For security issues, contact the server administrator immediately.