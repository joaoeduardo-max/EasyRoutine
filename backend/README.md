# EasyRoutine — Backend

API REST que serve o aplicativo mobile **EasyRoutine** — rotinas visuais
para pessoas autistas. Expõe autenticação por JWT e CRUD de rotinas e
tarefas, sempre escopados ao usuário autenticado.

- **Produção:** https://easyroutine-production.up.railway.app/api
- **Healthcheck:** https://easyroutine-production.up.railway.app/api/health

## Sumário

- [Stack](#stack)
- [Modelo de dados](#modelo-de-dados)
- [Como rodar localmente](#como-rodar-localmente)
- [Estrutura de pastas](#estrutura-de-pastas)
- [Convenções](#convenções)
- [Endpoints](#endpoints)
- [Códigos de status usados](#códigos-de-status-usados)
- [Scripts disponíveis](#scripts-disponíveis)
- [Deploy](#deploy)

## Stack

| Camada | Tecnologia |
|---|---|
| Runtime | Node.js 20 LTS |
| Linguagem | TypeScript 5.x (modo `strict`) |
| Framework HTTP | Express 4.x |
| ORM | Prisma 6.x |
| Banco | MySQL 8.x |
| Validação | Zod |
| Autenticação | JWT (jsonwebtoken) + BCrypt |
| Dev runtime | tsx (watch mode) |
| Hospedagem | Railway (backend + MySQL) |

## Modelo de dados

Três entidades, todas com UUID como chave primária:

```
Usuario  (1) ─── (N)  Rotina  (1) ─── (N)  Tarefa
```

| Entidade | Campos principais | Observações |
|---|---|---|
| `Usuario` | `id`, `nome`, `email` *(único)*, `senhaHash`, `criadoEm` | Senha armazenada com BCrypt (factor 10). |
| `Rotina` | `id`, `usuarioId` *(FK)*, `titulo`, `descricao?`, `cor`, `icone`, `periodo?`, `ativa`, `criadaEm`, `atualizadaEm` | `onDelete: Cascade` ao remover o usuário. `periodo` ∈ `MANHA/TARDE/NOITE` ou nulo. |
| `Tarefa` | `id`, `rotinaId` *(FK)*, `titulo`, `ordem`, `duracaoMinutos?`, `horario?`, `cor?`, `icone`, `concluida` | `onDelete: Cascade` ao remover a rotina. Ordenadas por `(rotinaId, ordem)`. |

Schema completo em [`prisma/schema.prisma`](prisma/schema.prisma).

## Como rodar localmente

### Pré-requisitos

- Node.js 20 LTS
- Docker (para subir o MySQL local) **ou** MySQL 8.x instalado
- Git

### 1. Subir o MySQL

Via Docker (recomendado):

```bash
docker run --name mysql-rotina \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=rotina_db \
  -p 3306:3306 \
  -d mysql:8
```

> Se já houver algo na porta 3306, ajuste o mapeamento `-p` e a `DATABASE_URL`.

### 2. Configurar variáveis de ambiente

```bash
cp .env.example .env
# (edite o JWT_SECRET para algo aleatório)
```

Conteúdo do `.env`:

```env
DATABASE_URL="mysql://root:root@localhost:3306/rotina_db"
JWT_SECRET="troque-isso-em-producao-use-uma-string-aleatoria-longa"
JWT_EXPIRATION="7d"
PORT=3000
NODE_ENV=development
```

### 3. Instalar dependências e rodar as migrations

```bash
npm install
npm run prisma:generate
npm run prisma:migrate -- --name init
```

### 4. Subir a API em modo desenvolvimento

```bash
npm run dev
```

A API ficará disponível em `http://localhost:3000/api`. Para checar saúde:

```bash
curl http://localhost:3000/api/health
# {"status":"ok"}
```

## Estrutura de pastas

```
backend/
├── prisma/
│   ├── schema.prisma           # modelos do banco
│   └── migrations/             # geradas pelo prisma migrate
└── src/
    ├── server.ts               # bootstrap (app.listen)
    ├── app.ts                  # configura Express + middlewares + rotas
    ├── config/                 # env (Zod) + singleton do Prisma
    ├── middlewares/            # authMiddleware, errorHandler, validate
    ├── modules/
    │   ├── auth/               # registrar, login, me
    │   ├── rotinas/            # CRUD de rotinas + reordenar
    │   └── tarefas/            # CRUD de tarefas
    ├── types/express.d.ts      # extensão do Request com req.usuario
    └── utils/                  # jwt, password, errors
```

Cada feature (`auth`, `rotinas`, `tarefas`) é um módulo independente com
**controller** (orquestra), **service** (regra de negócio + Prisma),
**routes** (Express Router) e **schemas** (Zod).

## Convenções

- Modelos no Prisma em **camelCase** mapeados para **snake_case** no MySQL via `@map`.
- IDs são UUIDs (`@default(uuid())`).
- Senhas armazenadas com BCrypt (factor 10). Nunca retornadas em respostas.
- Todas as respostas seguem `application/json`.
- Erros têm o formato:
  ```json
  { "erro": "CODIGO", "mensagem": "Texto humano", "detalhes": {...} }
  ```
- Controllers **não** consultam o Prisma diretamente — sempre via service.
- Recursos são filtrados pelo `req.usuario.id` em todo service que lida com `Rotina`/`Tarefa`.

## Endpoints

> Todas as rotas exigem o prefixo `/api`. Rotas marcadas como **protegido**
> requerem o header `Authorization: Bearer <token>`.

### `GET /api/health` *(público)*

Healthcheck para verificar se a API está no ar.

```bash
curl http://localhost:3000/api/health
```

Resposta `200`:

```json
{ "status": "ok" }
```

---

### `POST /api/auth/registrar` *(público)*

Cria uma nova conta e devolve o JWT.

**Body**

```json
{
  "nome": "Maria",
  "email": "maria@exemplo.com",
  "senha": "minhasenha123"
}
```

**Resposta `201`**

```json
{
  "token": "eyJhbGciOi...",
  "usuario": {
    "id": "8e6c...",
    "nome": "Maria",
    "email": "maria@exemplo.com",
    "criadoEm": "2026-05-12T12:34:56.000Z"
  }
}
```

**Erros possíveis**

| Status | Quando |
|---|---|
| `400` | Campos faltando ou inválidos |
| `409` | Email já cadastrado |

---

### `POST /api/auth/login` *(público)*

Autentica e devolve o JWT.

**Body**

```json
{
  "email": "maria@exemplo.com",
  "senha": "minhasenha123"
}
```

**Resposta `200`** — mesmo formato de `registrar`.

**Erros possíveis**

| Status | Quando |
|---|---|
| `400` | Campos faltando |
| `401` | Email ou senha incorretos |

---

### `GET /api/auth/me` *(protegido)*

Devolve os dados do usuário autenticado.

```bash
curl http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

**Resposta `200`**

```json
{
  "usuario": {
    "id": "8e6c...",
    "nome": "Maria",
    "email": "maria@exemplo.com",
    "criadoEm": "2026-05-12T12:34:56.000Z"
  }
}
```

**Erros possíveis**

| Status | Quando |
|---|---|
| `401` | Token ausente, inválido ou expirado |

---

### `GET /api/rotinas` *(protegido)*

Lista todas as rotinas do usuário autenticado, ordenadas da mais recente para a mais antiga.

```bash
curl http://localhost:3000/api/rotinas -H "Authorization: Bearer $TOKEN"
```

**Resposta `200`**

```json
[
  {
    "id": "0586f403-...",
    "titulo": "Antes de dormir",
    "descricao": null,
    "cor": "#7B1FA2",
    "icone": "🌙",
    "ativa": true,
    "criadaEm": "2026-05-12T21:32:12.636Z",
    "atualizadaEm": "2026-05-12T21:32:12.636Z",
    "totalTarefas": 3
  }
]
```

---

### `POST /api/rotinas` *(protegido)*

Cria uma rotina vinculada ao usuário.

**Body**

```json
{
  "titulo": "Manhã",
  "descricao": "Rotina ao acordar",
  "cor": "#4A90E2",
  "icone": "☀️"
}
```

- `titulo` — obrigatório, 1–80 caracteres
- `descricao` — opcional, máx. 500 caracteres
- `cor` — obrigatório, hex no formato `#RRGGBB`
- `icone` — obrigatório, 1–10 caracteres (emoji ou nome)

**Resposta `201`** — objeto rotina (mesmo formato de cada item em `GET /rotinas`, com `totalTarefas: 0`).

**Erros possíveis**

| Status | Quando |
|---|---|
| `400` | Validação (campo faltando, cor mal formada) |

---

### `GET /api/rotinas/:id` *(protegido)*

Detalhes da rotina, incluindo as tarefas em ordem.

```bash
curl http://localhost:3000/api/rotinas/<id> -H "Authorization: Bearer $TOKEN"
```

**Resposta `200`**

```json
{
  "id": "1d624426-...",
  "titulo": "Manhã",
  "descricao": null,
  "cor": "#EF6C00",
  "icone": "☀️",
  "ativa": true,
  "criadaEm": "...",
  "atualizadaEm": "...",
  "totalTarefas": 1,
  "tarefas": [
    {
      "id": "c0ec282f-...",
      "rotinaId": "1d624426-...",
      "titulo": "Escovar dente",
      "ordem": 0,
      "duracaoMinutos": 3,
      "icone": "🦷",
      "concluida": false
    }
  ]
}
```

**Erros possíveis**

| Status | Quando |
|---|---|
| `400` | `id` não é UUID válido |
| `404` | Rotina não existe ou pertence a outro usuário |

---

### `PUT /api/rotinas/:id` *(protegido)*

Edição parcial: envie apenas os campos que mudaram. Pelo menos 1 campo.

**Body**

```json
{
  "titulo": "Manhã nova",
  "descricao": "Versão atualizada",
  "cor": "#00838F",
  "icone": "🌅"
}
```

Para limpar a descrição, mande `"descricao": null` explicitamente.

**Resposta `200`** — objeto rotina atualizado (mesmo formato de `GET /rotinas/:id`, sem `tarefas`).

**Erros possíveis**

| Status | Quando |
|---|---|
| `400` | Body vazio, `id` mal formado, ou valores inválidos |
| `404` | Rotina não existe ou pertence a outro usuário |

---

### `DELETE /api/rotinas/:id` *(protegido)*

Remove a rotina (e suas tarefas, em cascata).

**Resposta `204`** — sem body.

**Erros possíveis**

| Status | Quando |
|---|---|
| `400` | `id` não é UUID válido |
| `404` | Rotina não existe ou pertence a outro usuário |

---

### `PUT /api/rotinas/:id/reordenar` *(protegido)*

Reordena as tarefas da rotina. A lista enviada deve conter **exatamente** os
ids de todas as tarefas atuais, na nova ordem desejada. O servidor aplica a
reordenação em uma transação.

**Body**

```json
{ "ordemIds": ["id-tarefa-1", "id-tarefa-2", "id-tarefa-3"] }
```

**Resposta `200`** — lista das tarefas já reordenadas (`ordem: 0, 1, 2, ...`).

**Erros possíveis**

| Status | Quando |
|---|---|
| `400` | Lista vazia, ids duplicados, ou lista não cobre exatamente as tarefas atuais |
| `404` | Rotina não existe ou pertence a outro usuário |

---

### `POST /api/rotinas/:rotinaId/tarefas` *(protegido)*

Adiciona uma tarefa à rotina. A `ordem` é calculada automaticamente
(`max + 1`).

**Body**

```json
{
  "titulo": "Escovar dente",
  "icone": "🦷",
  "duracaoMinutos": 3
}
```

- `titulo` — obrigatório, 1–80 caracteres
- `icone` — obrigatório, 1–10 caracteres
- `duracaoMinutos` — opcional, inteiro positivo entre 1 e 1440

**Resposta `201`**

```json
{
  "id": "c0ec282f-...",
  "rotinaId": "1d624426-...",
  "titulo": "Escovar dente",
  "ordem": 0,
  "duracaoMinutos": 3,
  "icone": "🦷",
  "concluida": false
}
```

**Erros possíveis**

| Status | Quando |
|---|---|
| `400` | Validação ou `rotinaId` não é UUID |
| `404` | Rotina não existe ou pertence a outro usuário |

---

### `PUT /api/tarefas/:id` *(protegido)*

Edição parcial: envie **apenas** os campos que mudaram.

**Body** (pelo menos 1 campo)

```json
{
  "titulo": "Café da manhã",
  "icone": "🍴",
  "duracaoMinutos": 15,
  "concluida": true
}
```

Para limpar a duração, mande `"duracaoMinutos": null` explicitamente.

**Resposta `200`** — objeto tarefa atualizado.

**Erros possíveis**

| Status | Quando |
|---|---|
| `400` | Body vazio, `id` mal formado, valores inválidos |
| `404` | Tarefa não existe ou pertence a rotina de outro usuário |

---

### `DELETE /api/tarefas/:id` *(protegido)*

Remove uma tarefa.

**Resposta `204`** — sem body.

**Erros possíveis**

| Status | Quando |
|---|---|
| `400` | `id` não é UUID válido |
| `404` | Tarefa não existe ou pertence a rotina de outro usuário |

---

## Códigos de status usados

| Status | Significado |
|---|---|
| `200` | OK (GET/PUT bem-sucedidos) |
| `201` | Created (POST bem-sucedido) |
| `204` | No Content (DELETE bem-sucedido) |
| `400` | Validação falhou |
| `401` | Não autenticado / credenciais erradas |
| `403` | Autenticado mas sem permissão |
| `404` | Recurso não encontrado |
| `409` | Conflito (ex.: email já cadastrado) |
| `500` | Erro interno do servidor |

## Scripts disponíveis

| Script | Descrição |
|---|---|
| `npm run dev` | Roda a API com `tsx watch` (hot reload no save) |
| `npm run build` | Compila TS → JS em `dist/` |
| `npm start` | Roda a versão compilada (`dist/server.js`) |
| `npm run prisma:generate` | Gera o client tipado do Prisma |
| `npm run prisma:migrate` | Cria/aplica migrations em dev |
| `npm run prisma:deploy` | Aplica migrations pendentes (uso em produção) |
| `npm run prisma:studio` | Abre o Prisma Studio para inspecionar o banco |

## Deploy

A API está hospedada no Railway em
**https://easyroutine-production.up.railway.app/api**, com um service MySQL
dedicado no mesmo projeto.

Configuração:

- **Root directory:** `backend/`
- **Build command:** `npm install && npx prisma generate && npm run build`
- **Start command:** `npx prisma migrate deploy && npm start`
- **Variáveis:** `DATABASE_URL` (injetado pelo MySQL service), `JWT_SECRET`, `JWT_EXPIRATION=7d`, `NODE_ENV=production`.
- **Migrations:** aplicadas automaticamente no start via `prisma migrate deploy`.
