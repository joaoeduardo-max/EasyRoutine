export class AppError extends Error {
  readonly status: number;
  readonly codigo: string;
  readonly detalhes?: unknown;

  constructor(mensagem: string, status: number, codigo: string, detalhes?: unknown) {
    super(mensagem);
    this.name = this.constructor.name;
    this.status = status;
    this.codigo = codigo;
    this.detalhes = detalhes;
  }
}

export class BadRequestError extends AppError {
  constructor(mensagem = "Requisição inválida", detalhes?: unknown) {
    super(mensagem, 400, "BAD_REQUEST", detalhes);
  }
}

export class UnauthorizedError extends AppError {
  constructor(mensagem = "Não autenticado") {
    super(mensagem, 401, "UNAUTHORIZED");
  }
}

export class ForbiddenError extends AppError {
  constructor(mensagem = "Acesso negado") {
    super(mensagem, 403, "FORBIDDEN");
  }
}

export class NotFoundError extends AppError {
  constructor(mensagem = "Recurso não encontrado") {
    super(mensagem, 404, "NOT_FOUND");
  }
}

export class ConflictError extends AppError {
  constructor(mensagem = "Conflito de dados") {
    super(mensagem, 409, "CONFLICT");
  }
}
