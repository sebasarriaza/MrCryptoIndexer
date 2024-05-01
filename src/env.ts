import { createEnv } from "@t3-oss/env-core";
import { z } from "zod";

export const env = createEnv({
  server: {
    DATABASE_URL: z.string().url().startsWith("postgres://"),
    RPC_URL: z.string().url(),
    ADMIN_API_KEY: z.string().min(10),
  },
  runtimeEnv: process.env,
  emptyStringAsUndefined: true,
  skipValidation: !!process.env.CI,
});
