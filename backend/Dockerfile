FROM public.ecr.aws/lambda/nodejs:20 AS builder

WORKDIR /var/task

COPY package*.json ./
RUN npm ci --only=production

FROM public.ecr.aws/lambda/nodejs:20

WORKDIR /var/task

COPY --from=builder /var/task/node_modules ./node_modules
COPY src/ ./src/
COPY lambda.js ./

CMD ["lambda.handler"]
