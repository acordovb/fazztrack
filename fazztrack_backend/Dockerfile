######################################################################
# Etapa 1: Build
FROM node:22-alpine AS builder

WORKDIR /app

# Copiar archivos de configuración
COPY package.json yarn.lock ./
COPY prisma ./prisma/

# Instalar dependencias y generar Prisma client
RUN yarn install --frozen-lockfile --production=false && \
    yarn prisma generate

# Copiar código fuente
COPY . .

# Build de la aplicación
RUN yarn run build

######################################################################
# Etapa 2: Dependencias de producción
FROM node:22-alpine AS deps

WORKDIR /app

# Copiar archivos de configuración
COPY package.json yarn.lock ./
COPY prisma ./prisma/

# Instalar solo dependencias de producción y generar Prisma client
RUN yarn install --frozen-lockfile --production=true && \
    yarn prisma generate && \
    yarn cache clean --force

######################################################################
# Etapa 3: Runtime
FROM node:22-alpine AS runner

# Configurar variables de entorno
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=256 --max-http-header-size=8192 --no-warnings"

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001

WORKDIR /app

# Copiar solo archivos necesarios
COPY --from=deps --chown=nestjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nestjs:nodejs /app/dist ./dist
COPY --from=deps --chown=nestjs:nodejs /app/prisma ./prisma
COPY --chown=nestjs:nodejs package.json ./

# Cambiar a usuario no-root
USER nestjs

EXPOSE 3000

# Comando simplificado sin dumb-init
CMD ["node", "dist/main"]