# Deployment Guide for Coolify

This guide explains how to deploy the Plasma Next.js template using Coolify.

## Overview

Plasma Next.js Template can be deployed to Coolify in two ways:
1. **Static Site** (Recommended) - Pre-built static files served via Nginx/Caddy
2. **Node.js Application** - Dynamic server-side rendering with Node.js runtime

## Option 1: Static Site Deployment (Recommended)

This is the recommended approach as the template is configured for static export by default.

### Prerequisites

- Coolify instance running
- GitHub repository connected (https://github.com/alphaciso/plasma)
- Domain name (optional)

### Steps

1. **In Coolify Dashboard:**
   - Click "Add New Resource" → "Application"
   - Select your GitHub repository: `alphaciso/plasma`
   - Choose the `main` branch

2. **Build Configuration:**
   - **Build Pack:** Static Site
   - **Install Command:** `pnpm install`
   - **Build Command:** `pnpm build`
   - **Publish Directory:** `out`
   - **Node Version:** 18 or higher

3. **Environment Variables:**
   No environment variables required for basic deployment.

4. **Advanced Settings:**
   - **Base Directory:** Leave empty (root)
   - **Port:** Not needed for static sites
   - **Health Check Path:** `/`

5. **Deploy:**
   Click "Deploy" and Coolify will:
   - Clone the repository
   - Install dependencies with pnpm
   - Run the build command
   - Serve the `out` directory as static files

### Note on Static Export

The template uses static search by default (compatible with static export). The search indexes are generated at build time and work entirely on the client side.

## Option 2: Node.js Application Deployment

If you need server-side features or want to disable static export:

### Prerequisites

Same as Option 1

### Steps

1. **Update next.config.ts** (if not using static export):
   Remove or comment out any `output: 'export'` configuration if present.

2. **In Coolify Dashboard:**
   - Click "Add New Resource" → "Application"
   - Select your GitHub repository: `alphaciso/plasma`
   - Choose the `main` branch

3. **Build Configuration:**
   - **Build Pack:** Node.js
   - **Install Command:** `pnpm install`
   - **Build Command:** `pnpm build`
   - **Start Command:** `pnpm start`
   - **Node Version:** 18 or higher
   - **Port:** 3000

4. **Environment Variables:**
   ```
   NODE_ENV=production
   ```

5. **Health Check:**
   - **Path:** `/`
   - **Port:** 3000

6. **Deploy:**
   Click "Deploy"

## Using Docker (Alternative)

If you prefer Docker deployment, create a `Dockerfile`:

```dockerfile
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build application
RUN pnpm build

# Production stage for static export
FROM nginx:alpine AS static

COPY --from=builder /app/out /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### For Node.js Runtime (Alternative Dockerfile)

```dockerfile
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

RUN npm install -g pnpm

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm build

# Production stage
FROM node:18-alpine

WORKDIR /app

RUN npm install -g pnpm

COPY --from=builder /app/package.json ./
COPY --from=builder /app/pnpm-lock.yaml ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.ts ./

RUN pnpm install --prod --frozen-lockfile

EXPOSE 3000

CMD ["pnpm", "start"]
```

### Deploy with Docker in Coolify

1. Add the Dockerfile to your repository
2. In Coolify, select "Dockerfile" as the build pack
3. Set the Dockerfile path
4. Deploy

## Post-Deployment

### Custom Domain

1. In Coolify, go to your application settings
2. Click "Domains"
3. Add your domain name
4. Coolify will automatically configure SSL with Let's Encrypt

### Verify Deployment

1. Visit your deployment URL
2. Check that:
   - Homepage loads correctly
   - Documentation pages work (`/docs`)
   - Search functionality works (Cmd/Ctrl+K)
   - Static assets load (images, fonts)

### Monitoring

Coolify provides built-in monitoring:
- View logs in real-time
- Check resource usage (CPU, memory)
- Monitor uptime

## Troubleshooting

### Build Fails with "fumadocs-mdx" Error

**Solution:** Ensure the `postinstall` script runs. It's defined in `package.json` and generates the `.source` directory needed for documentation.

### Search Not Working

**Solution:** Verify that:
1. The build completed successfully
2. The `out/api/search` directory exists
3. Static search indexes were generated

### Images Not Loading

**Solution:** Check that the `public` directory is included in the build output.

### pnpm Not Found

**Solution:** Add pnpm installation to build command:
```bash
npm install -g pnpm && pnpm install && pnpm build
```

Or use the Docker approach which includes pnpm installation.

## Performance Optimization

### Enable Caching

In Coolify, enable build caching to speed up deployments:
- Cache `node_modules`
- Cache `.next/cache` for Next.js builds

### CDN Integration

For static deployments, consider:
- Using Cloudflare in front of Coolify
- Enabling Coolify's built-in CDN features (if available)

### Compression

Coolify's Nginx/Caddy automatically handles gzip/brotli compression for static sites.

## Recommended Deployment Method

**For this template, use Option 1 (Static Site Deployment):**

- ✅ Faster page loads
- ✅ Lower resource usage
- ✅ Better scalability
- ✅ Search works client-side
- ✅ No server required

The template is optimized for static export with client-side search powered by Orama.
