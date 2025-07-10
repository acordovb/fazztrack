# Etapa 1: Build
FROM node:22-alpine AS builder

WORKDIR /app

COPY package.json ./
COPY yarn.lock ./
COPY prisma ./prisma/

# Instalar dependencias de build
RUN yarn install --frozen-lockfile --production=false && \
    yarn prisma generate

COPY . .

# Build de la aplicación
RUN yarn run build && \
    yarn install --frozen-lockfile --production --ignore-scripts && \
    yarn cache clean

# Etapa 2: Deploy
FROM node:22-alpine AS runner

# Instalar dumb-init para mejor manejo de señales
RUN apk add --no-cache dumb-init

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001

WORKDIR /app

# Copiar solo lo necesario desde builder
COPY --from=builder --chown=nestjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nestjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nestjs:nodejs /app/prisma ./prisma
COPY --from=builder --chown=nestjs:nodejs /app/package.json ./package.json

# Cambiar a usuario no-root
USER nestjs

COPY --from=builder /app/dist ./dist

EXPOSE 3000

# Usar dumb-init para mejor manejo de procesos
CMD ["dumb-init", "node", "dist/main"]