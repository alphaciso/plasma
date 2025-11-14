# Multi-stage Dockerfile for Plasma Next.js Template
# Optimized for static export deployment with Coolify

# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm@8

# Copy package files first
COPY package.json ./
COPY pnpm-lock.yaml ./

# Copy configuration files needed by postinstall script
COPY source.config.ts ./
COPY tsconfig.json ./
COPY content ./content

# Install dependencies (postinstall will run fumadocs-mdx)
RUN pnpm self-update
RUN pnpm install --frozen-lockfile

# Copy remaining source code
COPY . .

# Build application (generates static export in 'out' directory)
RUN pnpm build

# Production stage - Nginx for serving static files
FROM nginx:alpine AS production

# Copy built static files from builder
COPY --from=builder /app/out /usr/share/nginx/html

# Copy custom nginx configuration (optional)
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
