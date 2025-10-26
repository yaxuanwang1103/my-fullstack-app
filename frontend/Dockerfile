# ---- Build stage ----
FROM node:20-alpine AS build
WORKDIR /app

# Install deps first (better cache)
COPY package*.json ./
RUN npm ci

# Copy source
COPY . .

# Build-time API base for Vite
ARG VITE_API_URL
ENV VITE_API_URL=${VITE_API_URL}

# Build static assets
RUN npm run build

# ---- Runtime stage ----
FROM nginx:alpine

# SPA routing + basic gzip/static headers
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Static site
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
