# 前端构建阶段
FROM node:20-alpine as builder

WORKDIR /app
COPY package*.json ./
RUN npm install --legacy-peer-deps && npm cache clean --force
COPY . .  
RUN npm run build
RUN npm prune --production

# 第二阶段：仅复制构建产物和运行时依赖
FROM node:20-alpine

# 显式声明环境变量
ENV UPTIME_KUMA_DB_NAME
ENV UPTIME_KUMA_DB_HOSTNAME
ENV UPTIME_KUMA_DB_USERNAME
ENV UPTIME_KUMA_DB_TYPE
ENV UPTIME_KUMA_DB_PORT
ENV UPTIME_KUMA_DB_PASSWORD

WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/server ./server
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/src ./src
COPY --from=builder /app/db ./db

EXPOSE 3001
CMD ["node", "server/server.js"]
