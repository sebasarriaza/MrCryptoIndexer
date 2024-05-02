FROM node:20 AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
COPY . /app
WORKDIR /app

ARG DATABASE_URL
ARG RPC_URL
ARG ADMIN_API_KEY

ENV DATABASE_URL=$DATABASE_URL
ENV RPC_URL=$RPC_URL
ENV ADMIN_API_KEY=$ADMIN_API_KEY

RUN echo "DATABASE_URL: $DATABASE_URL"
RUN echo "RPC_URL: $RPC_URL"
RUN echo "ADMIN_API_KEY: $ADMIN_API_KEY"

RUN pnpm install --frozen-lockfile

FROM base AS build
RUN pnpm run build

FROM base
COPY --from=build /app/node_modules /app/node_modules
COPY --from=build /app/dist /app/dist
EXPOSE 4000
EXPOSE 5555

RUN printf "pnpm db:push \n pnpm prisma db seed \n pnpm db:studio & \n pnpm start \n" > /app/start.sh
RUN chmod +x /app/start.sh

CMD [ "/app/start.sh" ]
