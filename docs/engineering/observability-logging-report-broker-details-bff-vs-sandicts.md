# Relatorio de observabilidade e logs - Broker Details BFF vs Sandicts

## Resumo executivo

- Status geral: o padrao do BFF tem uma boa intencao, porque transporta contexto junto da excecao e pode permitir logging centralizado. A implementacao mostrada, porem, repete muitos campos manualmente e mistura falhas do provider com falhas de cache e autenticacao em um `catch` amplo.
- Principal conclusao para o Sandicts: nao copiar o bloco completo de `metadata`. O Sandicts ja possui o equivalente estrutural em `AppError` (`code`, `cause` e `details`) e um filtro global.
- Campos do exemplo que mais ajudam: `event_name`, `provider_name`, `operation`, `error_code`, `http_status_code` e `cause`.
- Campos que devem ser derivados ou medidos pela infraestrutura: `http_method`, `url_path`, `duration_ms`, `error_type` e `outcome`.
- Risco principal no Sandicts: uma falha pode gerar o log estruturado do filtro global e o log HTTP automatico do `pino-http`. A politica precisa definir se esses sao eventos diferentes ou se deve existir um unico log enriquecido.
- Proximo passo recomendado: testar uma requisicao real que termine em `AppError` e outra em erro inesperado, contando as linhas emitidas e comparando o conteudo delas.

## Completude das evidencias

- Tipo de fonte:
  - BFF: dois arquivos colados no chat, sem o repositorio e sem as classes que consomem `metadata`.
  - Sandicts: repositorio local, codigo, documentacao e testes focados de logging/error handling.
- Cobertura: media.
- Alta confianca: estrutura atual do Sandicts e problemas locais visiveis no provider colado.
- Media/baixa confianca: formato final do log do BFF, redacao de dados, severidade final e eventual duplicidade, pois `ApplicationException`, `SpringBootApiException`, `LoggerService` e o filtro/interceptor global nao foram fornecidos.

## Escopo

- BFF analisado: nome real desconhecido; identificado neste relatorio como `broker-details-bff`.
- Projeto de comparacao: `nodejs-sandicts-api`.
- Data: 2026-08-04.
- Artefato do BFF: `C:/Users/devel/.codex/attachments/bf361dca-6e15-4034-afa2-c6f3a33cba96/pasted-text.txt`.
- Arquivo local do artefato: pendente; o codigo permanece apenas no anexo desta conversa.
- Comandos executados: buscas estaticas com `rg`, leitura dos arquivos e testes focados com Vitest.
- Testes: 3 arquivos e 16 testes aprovados.

### Arquivos principais inspecionados no Sandicts

- `src/bootstrap/bootstrap.ts`
- `src/bootstrap/setup-logger.ts`
- `src/infra/logging/logging.module.ts`
- `src/infra/logging/pino-logger.factory.ts`
- `src/infra/logging/pino-http.integration.spec.ts`
- `src/infra/http/http-platform.module.ts`
- `src/infra/http/filters/global-exception.filter.ts`
- `src/infra/http/filters/global-exception.filter.spec.ts`
- `src/shared/errors/app-error.ts`
- `src/shared/errors/error-codes.ts`
- `src/modules/auth/application/errors/auth-errors.ts`
- `src/modules/players/application/errors/player-profile-errors.ts`
- `docs/ai/logging/logging-foundation.md`
- `docs/ai/api/error-handling-foundation.md`

## Diagnostico do exemplo do BFF

### O que o codigo realmente faz

O `catch` nao chama o logger diretamente. Ele cria excecoes com `cause`, dados e `metadata`. Isso e melhor do que fazer `logger.error(...)` e relancar em cada camada, desde que um unico filtro global transforme essa metadata em um unico evento estruturado.

O provider ainda emite logs locais para cache e para o fluxo `404`. Assim, existem dois mecanismos simultaneos: logs imperativos no metodo e metadados carregados pelas excecoes.

### Campos com utilidade operacional

| Campo | Utilidade | Recomendacao |
| --- | --- | --- |
| `event_name` | Alta para busca, dashboard e alerta estavel | Manter, com catalogo pequeno e estavel |
| `provider_name` | Alta em falhas de integracao | Manter apenas na fronteira de integracao |
| `operation` | Alta para saber qual chamada falhou | Manter, preferindo valor estavel |
| `error_code` | Muito alta para agregacao e playbooks | Manter |
| `http_status_code` | Alta para falha HTTP downstream | Manter quando existir |
| `cause` | Muito alta para stack e causa raiz | Preservar e serializar com politica segura |
| `duration_ms` | Alta para timeout e degradacao | Medir no cliente/interceptor; o valor atual inclui cache e autenticacao |
| `http_method` / `url_path` | Media/alta | Derivar da configuracao da requisicao, evitando repeticao manual |
| `error_type` | Media | Derivar da classe/codigo quando possivel |
| `outcome: failure` | Baixa em um evento que ja e exclusivamente de erro | Omitir ou gerar centralmente |

### Riscos encontrados

1. O `catch` cobre cache, obtencao de token, chamada HTTP, validacao Zod e escrita no cache. Qualquer uma dessas falhas, salvo Zod, vira `SpringBootApiException` do provider. Isso pode atribuir causa e alerta ao sistema errado.
2. `duration_ms` comeca antes da leitura do cache e do token. Portanto, nao representa apenas a duracao da chamada downstream.
3. O `404` tratado como resultado normal gera dois `warn`. Se o comportamento e esperado, isso cria ruido e pode acionar alertas falsos. Um unico `info`/`debug` estruturado ou uma metrica costuma ser mais adequado.
4. Os mesmos oito a dez campos precisam ser repetidos em cada operacao. Esse boilerplate aumenta o risco de `operation`, rota ou codigo serem copiados incorretamente.
5. O `TagsService` adiciona outro bloco de metadata. Isso e aceitavel para um erro de negocio novo, mas nao deve repetir o mesmo evento do provider.

## Arquitetura atual do Sandicts

O Sandicts usa uma unica stack com `nestjs-pino`/`pino-http`, JSON fora do ambiente local, `LoggerErrorInterceptor`, auto logging HTTP, um filtro global, validacao Zod global e um `AppError` compartilhado.

O fluxo de erro e:

1. gateway/repositorio traduz uma falha conhecida para `AppError` e preserva `cause`;
2. `AppError` carrega `code` e `details` internos;
3. o filtro global normaliza a resposta HTTP e, quando existem `details`, emite um `warn` estruturado;
4. o `pino-http` emite o log de conclusao da requisicao e recebe o erro original pelo `LoggerErrorInterceptor`.

Isso ja implementa a ideia central do exemplo sem colocar telemetria extensa em cada service.

## Shape atual dos logs HTTP do Sandicts

O log automatico inclui, entre outros:

- `service`, `env`, `version`;
- `requestId`;
- `request.method`, `request.url`, headers selecionados, IP e porta remota;
- `response.statusCode`;
- `durationMs`;
- `traceId` e `spanId` quando existe `traceparent` valido.

Pontos bons: body desligado, redacao central, objetos HTTP compactos, JSON por padrao e teste de integracao do shape.

Pontos a revisar:

- `requestId` e `correlationId` sao fundidos no mesmo valor e devolvidos nos dois headers;
- o `spanId` extraido do `traceparent` e o span recebido/parent, nao um span local real;
- os campos emitidos usam `camelCase`, enquanto o contrato de observabilidade de referencia usa `snake_case`;
- `request.url` pode conter query string;
- `x-forwarded-for`, `user-agent`, IP e `remotePort` aumentam risco de privacidade, cardinalidade e custo;
- nao foi encontrada reducao de logs para healthcheck;
- nao existem `event_name` nem `log_schema_version`.

## Error logging e possivel duplicidade

O filtro chama `logger.warn`/`logger.error`. Em paralelo, `LoggerErrorInterceptor` coloca o erro em `response.err`, e o `pino-http` usa esse erro no log de conclusao. Portanto, para `AppError` com `details` e para erros inesperados, a arquitetura permite duas linhas sobre a mesma falha.

Isso nao e necessariamente incorreto se os eventos forem definidos como:

- evento semantico da aplicacao; e
- evento tecnico de conclusao HTTP.

Hoje, porem, eles nao possuem `event_name` distintos, e a documentacao simultaneamente chama o completion log de primario e declara o objetivo de evitar duplicidade. Falta um teste de integracao que prove a cardinalidade e o shape do fluxo completo.

## Seguranca e privacidade

- Bom: request body nao e serializado por padrao; authorization, cookies, chaves e campos comuns de segredo possuem redacao.
- Risco: URL bruta pode conter query sensivel.
- Risco: `x-forwarded-for`, IP remoto, porta e user-agent sao coletados por padrao sem evidencia de necessidade operacional.
- Risco: `details` e `unknown`; a seguranca depende da disciplina de cada factory de erro. O codigo atual de auth documenta a proibicao de tokens, mas nao existe uma allowlist tipada/central para todos os modulos.

## Alinhamento com o contrato alvo

| Area | BFF colado | Sandicts | Nota |
| --- | --- | --- | --- |
| Stack unica | Desconhecido | Bom | Sandicts usa apenas Pino |
| JSON fora de local | Desconhecido | Bom | Configurado e testado |
| HTTP auto log | Desconhecido | Bom | `pino-http` |
| Sem log duplicado | Desconhecido | Risco | filtro + completion log |
| `request_id` separado | Desconhecido | Aceitavel | existe como `requestId` |
| `correlation_id` separado | Desconhecido | Risco | fundido com request id |
| `trace_id` | Desconhecido | Aceitavel | extraido, sem tracing real |
| `span_id` local real | Desconhecido | Risco | o id recebido e nomeado como local |
| `event_name` | Bom | Faltante | presente no BFF, ausente no Sandicts |
| `log_schema_version` | Desconhecido | Faltante | nao encontrado |
| `error_code` estavel | Bom | Bom | Sandicts usa `code` tipado |
| `cause` preservada | Bom | Bom | presente nos dois modelos |
| Filtro global | Desconhecido | Bom | registrado via `APP_FILTER` |
| Validacao global | Desconhecido | Bom | Zod global |
| Excecoes tipadas | Bom | Bom | ambos possuem erro de aplicacao |
| Mapeamento de provider | Aceitavel | Aceitavel | Sandicts traduz falhas conhecidas, mas ainda tem poucas integracoes HTTP |
| Sem body por padrao | Desconhecido | Bom | serializer do Sandicts nao inclui body |
| Redacao | Desconhecido | Aceitavel | boa base, mas `details` continua aberto |
| Healthcheck reduzido | Desconhecido | Faltante | `autoLogging: true` sem exclusao encontrada |
| Testes de logging/error | Desconhecido | Bom | 16 testes focados aprovados |

## Evidencias principais

### 1. Excecao enriquecida no provider do BFF

Arquivo: anexo, linhas 139-152.

```ts
throw new SpringBootApiException({
  cause: error,
  metadata: {
    event_name: OBSERVABILITY_EVENTS.DOWNSTREAM_REQUEST_FAILED,
    provider_name: BROKER_DETAILS_OBSERVABILITY.PROVIDER_NAME,
    operation: BROKER_DETAILS_OBSERVABILITY.OPERATIONS.LIST_TAGS,
    http_status_code: getAxiosStatus(error),
    error_code: BROKER_DETAILS_OBSERVABILITY.ERROR_CODES.TAGS_PROVIDER_FAILED,
  },
});
```

Prova que a camada carrega contexto estruturado sem chamar `logger.error` dentro do `catch`.

### 2. `AppError` do Sandicts ja preserva contexto e causa

Arquivo: `nodejs-sandicts-api/src/shared/errors/app-error.ts`, linhas 4-23.

```ts
class AppError extends Error {
  readonly code: AppErrorCode;
  readonly details?: unknown;

  // ...
  this.details = options.details;
  if (options.cause !== undefined) this.cause = options.cause;
}
```

Prova que nao e necessario introduzir outra hierarquia apenas para copiar o BFF.

### 3. Logging semantico no filtro do Sandicts

Arquivo: `nodejs-sandicts-api/src/infra/http/filters/global-exception.filter.ts`, linhas 46-60.

```ts
if (normalizedException.shouldLog) {
  const logPayload = {
    code: normalizedException.responseBody.code,
    details: normalizedException.details,
    requestId: normalizedException.responseBody.requestId,
    statusCode: normalizedException.responseBody.statusCode,
  };
  this.logger.warn(logPayload, normalizedException.logMessage);
}
```

Prova que o contexto interno ja e emitido centralmente.

### 4. Auto logging HTTP permanece ativo

Arquivo: `nodejs-sandicts-api/src/infra/logging/pino-logger.factory.ts`, linhas 188-214.

```ts
pinoHttp: {
  autoLogging: true,
  customLogLevel: (_request, response, error) => {
    if (error || response.statusCode >= 500) return 'error';
    if (response.statusCode >= 400) return 'warn';
    return 'info';
  },
  quietReqLogger: true,
}
```

Prova que o filtro nao e o unico produtor de log em uma falha HTTP.

### 5. Correlacao atual funde dois conceitos

Arquivo: `nodejs-sandicts-api/src/infra/logging/pino-logger.factory.ts`, linhas 86-94.

```ts
const requestId =
  getHeaderValue(request.headers, REQUEST_ID_HEADER) ??
  getHeaderValue(request.headers, CORRELATION_ID_HEADER) ??
  randomUUID();

response.setHeader('X-Request-Id', requestId);
response.setHeader('X-Correlation-Id', requestId);
```

Prova que `request_id` e `correlation_id` ainda nao sao identidades separadas.

## O que esta bom

- No BFF, contexto e anexado a excecao em vez de fazer `log-and-rethrow` no `catch` mostrado.
- No Sandicts, a politica de resposta e de logging esta centralizada e testada.
- Os dois preservam `cause`.
- O Sandicts ja separa dados publicos (`message`, `code`) de detalhes internos.
- O Sandicts evita body por padrao e tem redacao central.

## O que e arriscado

- Copiar toda a metadata para cada metodo produziria boilerplate e inconsistencias no Sandicts.
- O `catch` amplo do BFF classifica falhas de cache/auth como falha do provider.
- O BFF mede uma duracao de operacao total com nome de duracao downstream.
- O BFF emite dois warnings para um `404` convertido em sucesso.
- O Sandicts pode emitir duas linhas por falha sem nomes de evento que expliquem a diferenca.
- O Sandicts conflui request/correlation id e trata o parent span recebido como `spanId` local.

## Recomendacao de desenho

Para services e use cases:

- incluir apenas semantica que a infraestrutura nao consegue inferir: `code`, `event_name`, `operation` e ids de dominio estritamente necessarios;
- nunca anexar payload, token, cabecalhos completos ou resposta do provider;
- evitar `logger.error` quando a excecao sera propagada ao filtro global.

Para gateways/providers:

- traduzir erros de transporte em erros tipados e preservar `cause`;
- incluir `provider_name`, `operation`, codigo estavel e status downstream;
- medir metodo, rota e duracao num wrapper/interceptor do cliente HTTP;
- restringir o `try/catch` ao trecho cuja falha esta sendo traduzida.

Para o boundary global:

- emitir uma unica linha de falha enriquecida; ou
- manter dois eventos apenas se um for explicitamente `application.error.handled` e o outro `http.server.request.completed`, com consultas/alertas que nao contem ambos como a mesma falha.

## Mudancas candidatas para o Sandicts

1. Antes de mudar codigo, adicionar teste de integracao que conte logs para `AppError` e erro inesperado.
2. Definir `event_name` estavel no boundary e decidir a politica de uma ou duas linhas.
3. Evoluir `AppError.details` para um contexto interno mais controlado/tipado quando surgirem novas integracoes.
4. Adicionar `provider_name` e `operation` apenas nos gateways externos.
5. Separar `request_id` de `correlation_id`.
6. Renomear o span recebido para `incoming_span_id`/`parent_span_id` ate existir tracing local real.
7. Usar rota sem query, revisar headers/IP/porta e reduzir healthcheck.
8. Nao adicionar manualmente `outcome`, metodo, URL e duracao a cada service; gerar esses campos na instrumentacao HTTP.

## Informacoes ainda faltantes do BFF

- Implementacao de `ApplicationException`.
- Implementacao de `SpringBootApiException`.
- Filtro global/interceptor que converte as excecoes em logs e respostas.
- Implementacao/configuracao de `LoggerService`, incluindo redacao.
- Constantes de observabilidade e um exemplo real do JSON emitido.
- Testes que demonstrem quantas linhas sao geradas por erro.

## Proximo envio sugerido

1. `application.exception.ts` e `springBootApi.exception.ts`.
2. Filtro global de excecoes.
3. `logger.service.ts` e configuracao do logger.
4. Um log JSON real de `DOWNSTREAM_REQUEST_FAILED`, com dados sensiveis removidos.
5. Teste de um provider ou do filtro para esse fluxo.

## Readiness score

- BFF colado: 5/10, com baixa confianca por falta da infraestrutura que consome a metadata.
- Sandicts: 7/10. A base e boa e ja evita a maior parte da poluicao no dominio; as lacunas principais sao cardinalidade do erro, semantica dos ids/tracing e padronizacao dos eventos.
