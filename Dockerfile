# 1. Builder Stage: 앱 빌드
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

# 2. Runner Stage: 실제 앱 실행 (수정된 부분)
FROM node:20-alpine AS runner
WORKDIR /app

# Standalone 모드는 필요한 모든 서버 파일(next.config.mjs, package.json 포함)을
# .next/standalone 폴더 안에 자동으로 모아줍니다.
# 따라서 이 폴더만 복사하면 됩니다.
COPY --from=builder /app/.next/standalone ./

# 정적 파일(이미지, CSS 등)을 위한 .next/static 폴더와
# public 폴더를 복사합니다.
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

EXPOSE 3000
ENV PORT 3000

# 앱 실행
CMD ["node", "server.js"]