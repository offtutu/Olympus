# Olympus Motors

Sistema full-stack para gerenciamento de veiculos da Olympus Motors, com autenticação JWT, controle de permissões por perfil de usuário e painel web para cadastro, listagem, edição e remoção de carros.

## Visão Geral

O projeto está dividido em duas aplicações:

- `back-end/olympus`: API REST em Java com Spring Boot.
- `front-end/olympusweb`: aplicação web em React.
 - `mobile/olympusapp`: aplicativo móvel em Flutter (Android).

Principais recursos:

- Cadastro e login de usuários.
- Autenticação com JWT.
- Perfis `ADMIN` e `COMUM`.
- CRUD de carros protegido por permissões.
- Listagem e busca pública de veículos.
- Migrações de banco com Flyway.
- Testes automatizados do back-end com H2.

## Tecnologias

Back-end:

- Java 21
- Spring Boot 4
- Spring Security
- Spring Data JPA
- PostgreSQL
- Flyway
- JWT com `java-jwt`
- Maven Wrapper
- H2 para testes

Front-end:

- React
- Axios
- React Scripts
- CSS modular por tela/componente

Mobile:

- Flutter

## Estrutura

```text
.
├── back-end/
│   └── olympus/
│       ├── src/main/java/olympusmotors/olympus/
│       │   ├── config/
│       │   ├── controller/
│       │   ├── DTos/
│       │   ├── exception/
│       │   ├── modules/
│       │   └── service/
│       ├── src/main/resources/
│       │   ├── db/migrate/
│       │   ├── application.properties
│       │   └── application-dev.properties
│       └── pom.xml
└── front-end/
    └── olympusweb/
        ├── public/
        ├── src/
        │   ├── components/
        │   ├── pages/
        │   └── services/
        └── package.json

```

Além disso, o repositório contém o app móvel Flutter:

```text
└── mobile/
  └── olympusapp/
    ├── lib/
    ├── android/
    ├── ios/
    └── pubspec.yaml
```
```

## Pré-requisitos

- Java 21
- Node.js e npm
- PostgreSQL
- Git
 - Flutter SDK (somente se for usar o app móvel)

## Configuração do Banco

Crie um banco PostgreSQL para a aplicação:

```sql
CREATE DATABASE olympus;
```

O back-end usa Flyway para criar as tabelas automaticamente ao subir a aplicação.

As configurações principais ficam em:

```text
back-end/olympus/src/main/resources/application.properties
```

Por padrão, ele espera as variáveis de ambiente:

```text
DB_URL
DB_USER
DB_PASSWORD
```

Exemplo no PowerShell:

```powershell
$env:DB_URL='jdbc:postgresql://localhost:5432/olympus'
$env:DB_USER='postgres'
$env:DB_PASSWORD='sua-senha'
```

## Rodando o Back-end

Entre na pasta do back-end:

```powershell
cd back-end/olympus
```

Suba a API:

```powershell
.\mvnw.cmd spring-boot:run
```

A API ficará disponível em:

```text
http://localhost:8080
```

## Rodando o Front-end

Entre na pasta do front-end:

```powershell
cd front-end/olympusweb
```

Instale as dependências:

```powershell
npm install
```

Suba a aplicação:

```powershell
npm start
```

O front-end ficará disponível em:

```text
http://localhost:3000
```

Na tela de autenticação, selecione `API Online` para usar o back-end real.

## Endpoints Principais

Autenticação:

```text
POST /api/auth/registrar
POST /api/auth/login
```

Carros:

```text
GET    /api/carros
GET    /api/carros/{id}
GET    /api/carros/codigo/{codigo}
POST   /api/carros
PUT    /api/carros/{id}
DELETE /api/carros/{id}
```

As rotas de criação, edição e exclusão de carros exigem usuário com perfil `ADMIN`.

## Exemplos de Requisição

Cadastro:

```http
POST http://localhost:8080/api/auth/registrar
Content-Type: application/json
```

```json
{
  "login": "admin@olympus.com",
  "senha": "admin123",
  "cargo": "ADMIN"
}
```

Login:

```http
POST http://localhost:8080/api/auth/login
Content-Type: application/json
```

```json
{
  "login": "admin@olympus.com",
  "senha": "admin123"
}
```

Resposta:

```json
{
  "token": "eyJ..."
}
```

Criar carro:

```http
POST http://localhost:8080/api/carros
Content-Type: application/json
Authorization: Bearer SEU_TOKEN
```

```json
{
  "codigo": 234,
  "nome": "Civic",
  "marca": "Honda",
  "modelo": "Civic EX",
  "ano": 2000
}
```

## Testes

Para rodar os testes do back-end:

```powershell
cd back-end/olympus
.\mvnw.cmd test
```

Os testes usam H2 em memória e configuração própria em:

```text
back-end/olympus/src/test/resources/application.properties
```

Para rodar os testes do front-end:

```powershell
cd front-end/olympusweb
npm test
```

## Rodando o App Mobile

Pré-requisitos: instale o Flutter SDK e configure um emulador ou dispositivo.

No diretório do app mobile:

```powershell
cd mobile/olympusapp
flutter pub get
flutter run
```

Para gerar um build Android:

```powershell
cd mobile/olympusapp
flutter build apk --release
```

Observação: o app consome a API do back-end em `http://localhost:8080` por padrão — ajuste a URL caso use dispositivo físico ou servidor diferente.


## Segurança

- O login retorna um token JWT.
- O front-end salva o token no `localStorage`.
- O Axios envia o token no header `Authorization`.
- O back-end valida o token no `SecurityFilter`.
- Usuários `ADMIN` podem criar, atualizar e remover carros.
- Usuários `COMUM` podem acessar recursos liberados para visualização.

## Observações

- O CORS está configurado para permitir requisições do front-end em `http://localhost:3000`.
- Evite versionar senhas reais, tokens ou arquivos de configuração locais.
- Caso altere configurações do Spring Security ou CORS, reinicie o back-end.
