# ─── Stage 1: Build ──────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copy manifests + Prisma schema first → better layer caching
COPY package*.json ./
COPY prisma ./prisma/

# Install deps without running postinstall (prisma generate needs the schema
# to already be in place and doesn't need DATABASE_URL at build time, but
# the postinstall may fail if env isn't set — so we run it explicitly below)
RUN npm ci --ignore-scripts && npx prisma generate

# Copy source and compile
COPY . .
RUN npm run build

# ─── Stage 2: Production ─────────────────────────────────────────────────────
FROM node:20-alpine AS production

WORKDIR /app

ENV NODE_ENV=production

COPY package*.json ./
COPY prisma ./prisma/

# Install prod deps only; skip postinstall (prisma generate already done in builder).
# Add the Prisma CLI separately so `prisma migrate deploy` works at startup.
RUN npm ci --omit=dev --ignore-scripts && \
    npm install prisma --no-save --ignore-scripts

# Copy generated Prisma client from builder (avoids re-running generate)
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

# Copy compiled NestJS output
COPY --from=builder /app/dist ./dist

# Drop to non-root user
RUN chown -R node:node /app
USER node

EXPOSE 3000

# Run pending migrations then start the app
CMD ["sh", "-c", "node_modules/.bin/prisma migrate deploy && node dist/main"]
