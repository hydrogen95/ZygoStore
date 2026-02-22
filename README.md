# ZygoSMP - Minecraft Server Website

A production-ready website for the ZygoSMP Minecraft server featuring a complete manual-payment shop system with GCash integration.

![ZygoSMP Logo](public/images/logo.png)

## Features

### 🎮 Server Information
- Live server status with player count
- Server IP with copy-to-clipboard
- Supported Minecraft versions
- Discord integration

### 🛒 Shop System
- Rank purchases (BLOODLORD, DOUGH, DOUGH+)
- Shopping cart functionality
- GCash manual payment
- Payment proof upload
- Order tracking

### 👨‍💼 Admin Panel
- Secure authentication
- Order management (approve/reject)
- Rank and price editing
- GCash settings configuration
- Sales statistics dashboard

### 📄 Information Pages
- Features overview
- Server rules
- Staff list
- FAQ section

## Tech Stack

- **Frontend**: React + TypeScript + Tailwind CSS + shadcn/ui
- **Backend**: Node.js + Express
- **Database**: MySQL
- **Authentication**: JWT
- **File Uploads**: Multer

## Quick Start

### Prerequisites
- Node.js 18+
- MySQL 5.7+

### Installation

1. **Clone and setup**:
```bash
git clone <repo-url>
cd zygosmp
./setup.sh
```

2. **Configure environment**:
```bash
cp backend/.env.example backend/.env
# Edit backend/.env with your settings
```

3. **Setup database**:
```bash
mysql -u root -p < backend/src/config/schema.sql
```

4. **Start development**:
```bash
# Terminal 1 - Backend
cd backend
npm start

# Terminal 2 - Frontend
npm run dev
```

5. **Access the site**:
- Frontend: http://localhost:5173
- Admin Panel: http://localhost:5173/admin
- API: http://localhost:3001

## Default Credentials

**Admin Login**:
- Username: `admin`
- Password: Set in `backend/.env` (ADMIN_PASSWORD)

## Project Structure

```
zygosmp/
├── backend/              # Node.js API
│   ├── server.js         # Entry point
│   ├── src/
│   │   ├── config/       # Database & settings
│   │   ├── controllers/  # Business logic
│   │   ├── middleware/   # Auth & uploads
│   │   ├── routes/       # API endpoints
│   │   └── utils/        # Helpers
│   └── uploads/          # File storage
├── src/                  # React frontend
│   ├── App.tsx           # Main app
│   ├── AdminPanel.tsx    # Admin interface
│   └── ...
└── public/               # Static assets
```

## API Endpoints

### Public Endpoints
- `GET /api/health` - Health check
- `GET /api/server-status` - Minecraft server status
- `GET /api/ranks` - List all ranks
- `GET /api/settings/public` - Public settings
- `POST /api/orders` - Create order (with file upload)
- `GET /api/orders/track/:orderId` - Track order

### Admin Endpoints (Require Authentication)
- `POST /api/admin/login` - Admin login
- `GET /api/admin/verify` - Verify token
- `GET /api/orders` - List all orders
- `PUT /api/orders/:id/approve` - Approve order
- `PUT /api/orders/:id/reject` - Reject order
- `GET /api/orders/stats/summary` - Order statistics
- `PUT /api/ranks/:id` - Update rank
- `PUT /api/settings` - Update settings
- `PUT /api/settings/qr-code` - Update GCash QR

## Environment Variables

### Backend (.env)
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=zygosmp
JWT_SECRET=your_secret_key
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your_password
PORT=3001
NODE_ENV=production
DISCORD_WEBHOOK_URL=optional
FRONTEND_URL=https://yourdomain.com
```

### Frontend (.env)
```env
VITE_API_URL=http://localhost:3001/api
```

## Available Ranks

| Rank | Price (PHP) | Perks |
|------|-------------|-------|
| BLOODLORD | ₱200 | /fly, Colored chat, Priority support |
| DOUGH | ₱400 | All BLOODLORD perks + /hat, Particles, Double XP |
| DOUGH+ | ₱600 | All DOUGH perks + /nick, Vanish, WorldEdit |

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions for:
- cPanel/Shared Hosting
- VPS/Dedicated Server
- Docker

## Security Notes

1. **Change default passwords** before going live
2. **Use HTTPS** in production
3. **Set strong JWT secret** (32+ characters)
4. **Regular backups** of database and uploads
5. **Keep dependencies updated**

## Customization

### Changing Colors
Edit `src/index.css` to modify the color scheme:
```css
:root {
  --primary: #dc2626;  /* Change this */
  /* ... */
}
```

### Adding New Ranks
1. Add to database via admin panel
2. Or insert directly into `ranks` table

### Modifying Pages
Edit the respective components in `src/App.tsx`:
- HeroSection - Homepage hero
- FeaturesSection - Features page
- RulesSection - Rules page
- etc.

## Troubleshooting

### Common Issues

**Backend won't connect to database**:
- Check MySQL is running
- Verify credentials in .env
- Ensure database exists

**File uploads not working**:
- Check `backend/uploads` permissions (755)
- Verify multer configuration

**CORS errors**:
- Update FRONTEND_URL in backend .env
- Check CORS configuration in server.js

## License

This project is proprietary software for ZygoSMP.

## Credits

- Built for ZygoSMP Minecraft Server
- Design inspired by modern Minecraft server websites
- Icons by Lucide React