#Stage 1: Install deps
FROM node:lts-alpine AS base
WORKDIR /app

RUN corepack enable
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile

#Stage 2: Compile project
FROM node:lts-alpine AS builder
WORKDIR /app

RUN corepack enable
COPY --from=base /app/node_modules ./node_modules
COPY . .

RUN pnpm build

#Stage 3: Run the project as static files
FROM node:lts-alpine AS runner
WORKDIR /app

COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
 
EXPOSE 3000

CMD ["node", "server.js"]