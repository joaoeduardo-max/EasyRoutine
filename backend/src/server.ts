import { env } from "./config/env";
import { criarApp } from "./app";

const app = criarApp();

app.listen(env.PORT, () => {

  console.log(`🚀 API rodando em http://localhost:${env.PORT}/api (${env.NODE_ENV})`);
});
