FROM node:20 AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
COPY . /app
WORKDIR /app

FROM base AS prod-deps
# Asegúrate de definir un ID único y descriptivo para el montaje de caché
RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store pnpm install --frozen-lockfile

FROM base AS build
# Utiliza el mismo ID para la caché en el ambiente de construcción
RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run build

FROM base
COPY --from=prod-deps /app/node_modules /app/node_modules
COPY --from=build /app/dist /app/dist
EXPOSE 4000
EXPOSE 5555

RUN printf "pnpm db:push \n pnpm prisma db seed \n pnpm db:studio & \n pnpm start \n" > /app/start.sh
RUN chmod +x /app/start.sh

CMD [ "/app/start.sh" ]
