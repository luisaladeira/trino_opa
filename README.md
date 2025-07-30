# Ambiente Local Trino + OPA

Este repositório contém uma configuração completa para executar Trino com Open Policy Agent (OPA) localmente usando Docker Compose.

## ⚡ Quick Start

```bash
# 1. Clone o repositório
git clone git@github.com:luisaladeira/trino_opa.git
cd trino_opa

# 2. Inicie o ambiente (aguarde ~2-3 minutos)
./start.sh

# 3. Teste uma query
docker exec -it trino-coordinator trino --user alice --execute "SELECT name, department FROM postgresql.public.users LIMIT 3;"
```

**Pronto!** 🎉 Seu ambiente Trino + OPA está funcionando.

## 📋 Índice

- [⚡ Quick Start](#-quick-start)
- [🏗️ Arquitetura](#️-arquitetura)
- [🚀 Como Iniciar](#-como-iniciar)
- [🔌 Configurando Superset para Testar Regras OPA](#-configurando-superset-para-testar-regras-opa)
- [👤 Usuários e Permissões](#-usuários-e-permissões)
- [🧪 Testando o Controle de Acesso](#-testando-o-controle-de-acesso)
- [📊 Dados de Exemplo](#-dados-de-exemplo)
- [🔧 Configuração Avançada](#-configuração-avançada)
- [🔍 Monitoramento e Debug](#-monitoramento-e-debug)
- [🧪 Scripts Auxiliares](#-scripts-auxiliares)
- [🛑 Parar o Ambiente](#-parar-o-ambiente)
- [🐛 Solução de Problemas](#-solução-de-problemas)
- [🚀 Próximos Passos e Cenários Avançados](#-próximos-passos-e-cenários-avançados)

## 🏗️ Arquitetura

- **Trino Coordinator**: Motor de query principal (porta 8080)
- **Trino Worker**: Node de processamento
- **OPA (Open Policy Agent)**: Controle de acesso baseado em políticas (porta 8181)
- **PostgreSQL**: Banco de dados de exemplo (porta 5432)
- **Apache Superset**: Interface de BI e visualização (porta 8088)

## 🚀 Como Iniciar

### Pré-requisitos

- Docker e Docker Compose instalados
- Pelo menos 4GB de RAM disponível
- Portas disponíveis: 8080 (Trino), 8088 (Superset), 8181 (OPA), 5432 (PostgreSQL)

### 1. Subir o ambiente

**Método recomendado (mais fácil):**
```bash
# Clonar e navegar para o diretório do projeto
cd trino_opa

# Iniciar com script automatizado (recomendado)
./start.sh
```

**Método manual:**
```bash
# Subir todos os serviços
docker-compose up -d

# Verificar se todos os serviços estão rodando
docker-compose ps
```

### 2. Aguardar inicialização

```bash
# Verificar logs do Trino (aguardar até ver "SERVER STARTED")
docker-compose logs -f trino-coordinator

# Verificar se o OPA está respondendo
curl http://localhost:8181/health
```

### 3. Conectar ao Trino

```bash
# Usando CLI do Trino
docker exec -it trino-coordinator trino

# Ou via web UI
open http://localhost:8080
```

### 4. Acessar Superset (Opcional)

```bash
# Acessar interface web do Superset
open http://localhost:8088

# Credenciais padrão:
# Usuário: admin
# Senha: admin
```

## 🔌 Configurando Superset para Testar Regras OPA

O Superset permite criar diferentes conexões para cada usuário, facilitando o teste das políticas OPA.

### Passo 1: Adicionar Conexões por Usuário

No Superset, vá em **Settings > Database Connections > + Database** e crie 4 conexões:

#### 🔴 Admin (Acesso Total)
- **Display Name**: `Trino - Admin`
- **SQLAlchemy URI**: `trino://admin@trino-coordinator:8080/postgresql`
- **Descrição**: Acesso completo a todos os dados

#### 🔵 Alice (Analista)
- **Display Name**: `Trino - Alice (Analista)`
- **SQLAlchemy URI**: `trino://alice@trino-coordinator:8080/postgresql`
- **Descrição**: SELECT apenas, colunas sensíveis filtradas

#### 🟢 Bob (Engenheiro)
- **Display Name**: `Trino - Bob (Engenheiro)`
- **SQLAlchemy URI**: `trino://bob@trino-coordinator:8080/postgresql`
- **Descrição**: SELECT/INSERT/UPDATE/CREATE permitidos

#### 🟡 Charlie (Analista)
- **Display Name**: `Trino - Charlie (Analista)`
- **SQLAlchemy URI**: `trino://charlie@trino-coordinator:8080/postgresql`
- **Descrição**: Mesmo que Alice, SELECT apenas

### Passo 2: Testar as Regras OPA

#### Teste 1: Colunas Sensíveis (Filtragem)
Execute esta query em cada conexão:

```sql
SELECT * FROM public.users LIMIT 5;
```

**Resultados esperados:**
- **Admin**: Vê todas as colunas (ssn, credit_card, password)
- **Alice/Charlie**: Colunas sensíveis são filtradas automaticamente
- **Bob**: Vê todas as colunas (engenheiro tem acesso)

#### Teste 2: Tentativa de CREATE TABLE
Execute em cada conexão:

```sql
CREATE TABLE public.test_permissions (
    id INTEGER,
    name VARCHAR(100)
);
```

**Resultados esperados:**
- **Admin/Bob**: ✅ Sucesso
- **Alice/Charlie**: ❌ Acesso negado

#### Teste 3: Query de Agregação
```sql
SELECT
    department,
    COUNT(*) as total_employees,
    AVG(salary) as avg_salary
FROM public.users
GROUP BY department;
```

**Resultados esperados:**
- **Admin/Bob**: Valores reais de salário
- **Alice/Charlie**: Valores de salário podem ser filtrados/nulos

### Passo 3: Criar Datasets e Dashboards

#### Datasets por Usuário
1. **Data > Datasets > + Dataset**
2. Crie datasets usando cada conexão:

**Dataset Admin:**
```sql
SELECT
    name,
    email,
    department,
    salary,
    ssn,
    created_at
FROM public.users
```

**Dataset Analista (Alice/Charlie):**
```sql
SELECT
    name,
    email,
    department,
    created_at
FROM public.users
-- Colunas sensíveis serão automaticamente filtradas pelo OPA
```

**Dataset Engenheiro (Bob):**
```sql
SELECT
    u.name,
    u.department,
    u.salary,
    s.total_amount,
    p.category
FROM public.users u
JOIN public.sales s ON u.id = s.user_id
JOIN public.products p ON s.product_id = p.id
```

#### Dashboards Demonstrativos

1. **Dashboard "OPA Demo - Comparação"**
   - Crie 4 tabelas lado a lado
   - Uma para cada usuário executando `SELECT * FROM users`
   - Demonstra visualmente as diferenças de acesso

2. **Dashboard "Análise de Vendas"**
   - Use conexão Bob para dados completos
   - Use conexão Alice para dados filtrados
   - Compare os insights disponíveis

### 🎯 Teste Completo Guiado

#### Via SQL Lab:
1. **SQL Lab > SQL Editor**
2. **Database**: Selecione "Trino - Alice"
3. **Execute**:
   ```sql
   SELECT * FROM public.users LIMIT 3;
   ```
4. **Anote** quantas colunas aparecem
5. **Mude** para "Trino - Admin"
6. **Execute** a mesma query
7. **Compare** - Admin verá colunas como `ssn`, `credit_card`, `password`

#### Via Dashboard:
1. **Dashboards > + Dashboard**
2. **Adicione** chart com conexão Alice
3. **Clone** o chart e mude para conexão Admin
4. **Compare** os dados lado a lado

### 📊 Exemplos de Queries por Usuário

#### Para Alice (Analista):
```sql
-- ✅ Funciona - dados agregados sem informações sensíveis
SELECT department, COUNT(*) as employees
FROM public.users
GROUP BY department;

-- ❌ Falhará - tentativa de CREATE
CREATE TABLE public.temp AS SELECT * FROM public.users;
```

#### Para Bob (Engenheiro):
```sql
-- ✅ Funciona - análise técnica com JOINs
SELECT u.name, p.name as product, s.total_amount
FROM public.users u
JOIN public.sales s ON u.id = s.user_id
JOIN public.products p ON s.product_id = p.id
WHERE s.sale_date >= DATE '2024-01-01';

-- ✅ Funciona - criação de tabelas para ETL
CREATE TABLE public.sales_summary AS
SELECT department, SUM(total_amount) as revenue
FROM public.users u
JOIN public.sales s ON u.id = s.user_id
GROUP BY department;
```

#### Para Admin:
```sql
-- ✅ Funciona - acesso completo a dados sensíveis
SELECT name, email, ssn, salary, department
FROM public.users
WHERE salary > 70000;

-- ✅ Funciona - operações administrativas
DROP TABLE IF EXISTS public.temp_data;
ALTER TABLE public.users ADD COLUMN last_login TIMESTAMP;
```

## 👤 Usuários e Permissões

O OPA está configurado com os seguintes usuários de exemplo:

### admin
- **Permissões**: Acesso total a todos os recursos
- **Uso**: `trino --user admin`

### alice (Analista)
- **Permissões**: Apenas SELECT no schema public
- **Restrições**: Colunas sensíveis (ssn, credit_card, password) são filtradas
- **Uso**: `trino --user alice`

### bob (Engenheiro)
- **Permissões**: SELECT, INSERT, UPDATE, CREATE_TABLE
- **Uso**: `trino --user bob`

### charlie (Analista)
- **Permissões**: Mesmo que alice
- **Uso**: `trino --user charlie`

## 🧪 Testando o Controle de Acesso

### Teste 1: Query como admin (deve funcionar)
```sql
-- Conectar como admin
docker exec -it trino-coordinator trino --user admin

-- Executar query com colunas sensíveis
SELECT * FROM postgresql.public.users;
```

### Teste 2: Query como analista (colunas sensíveis filtradas)
```sql
-- Conectar como alice
docker exec -it trino-coordinator trino --user alice

-- Esta query deve filtrar colunas sensíveis
SELECT * FROM postgresql.public.users;
```

### Teste 3: Tentativa de CREATE TABLE como analista (deve falhar)
```sql
-- Conectar como alice
docker exec -it trino-coordinator trino --user alice

-- Esta operação deve ser negada
CREATE TABLE postgresql.public.test (id INTEGER);
```

### Teste 4: CREATE TABLE como engenheiro (deve funcionar)
```sql
-- Conectar como bob
docker exec -it trino-coordinator trino --user bob

-- Esta operação deve funcionar
CREATE TABLE postgresql.public.test (id INTEGER);
```

## 📊 Dados de Exemplo

O PostgreSQL vem pré-carregado com:

- **users**: Tabela com informações de usuários (incluindo dados sensíveis)
- **products**: Catálogo de produtos
- **sales**: Transações de vendas

### Queries de Exemplo

```sql
-- Análise de vendas por departamento
SELECT
    u.department,
    COUNT(s.id) as total_sales,
    SUM(s.total_amount) as revenue
FROM postgresql.public.users u
JOIN postgresql.public.sales s ON u.id = s.user_id
GROUP BY u.department;

-- Produtos mais vendidos
SELECT
    p.name,
    p.category,
    SUM(s.quantity) as total_sold
FROM postgresql.public.products p
JOIN postgresql.public.sales s ON p.id = s.product_id
GROUP BY p.name, p.category
ORDER BY total_sold DESC;
```

## 🔧 Configuração Avançada

### Modificar Políticas OPA

As políticas estão em `opa/policies/trino.rego`. Após modificar:

```bash
# Recarregar OPA
docker-compose restart opa
```

### Adicionar Novos Usuários

Edite `opa/data/users.json` e reinicie o OPA:

```bash
docker-compose restart opa
```

### Adicionar Novos Catálogos

Crie arquivos `.properties` em `trino/catalog/` e reinicie o Trino:

```bash
docker-compose restart trino-coordinator trino-worker
```

## 🔍 Monitoramento e Debug

### Logs do Trino
```bash
docker-compose logs -f trino-coordinator
docker-compose logs -f trino-worker
```

### Logs do OPA
```bash
docker-compose logs -f opa
```

### Debug de Políticas OPA
```bash
# Console interativo do OPA
docker exec -it trino-opa opa run --server --log-level debug /policies

# Testar política manualmente
curl -X POST http://localhost:8181/v1/data/trino/allow \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "context": {"identity": {"user": "alice"}},
      "action": {"operation": "SELECT"},
      "resource": {"table": {"schemaName": "public"}}
    }
  }'
```

### Web UI do Trino
- Acesse: http://localhost:8080
- Use diferentes usuários para ver diferentes níveis de acesso

### Verificar se todos os serviços estão funcionando
```bash
# Status de todos os containers
docker-compose ps

# Teste rápido de conectividade
curl http://localhost:8080/v1/info    # Trino
curl http://localhost:8181/health     # OPA
curl http://localhost:8088/health     # Superset
```

## 🛑 Parar o Ambiente

**Método recomendado:**
```bash
# Usar script de parada
./stop.sh
```

**Método manual:**
```bash
# Parar todos os serviços
docker-compose down

# Parar e remover volumes (perde dados)
docker-compose down -v
```

## 🧪 Scripts Auxiliares

### Testar Políticas OPA
```bash
# Executar testes automatizados das políticas
./test-opa-policies.sh
```

### Queries de Exemplo
```bash
# Ver arquivo com queries de teste
cat test-queries.sql

# Ou executar queries interativamente
docker exec -it trino-coordinator trino --user alice < test-queries.sql
```

### Parar Ambiente
```bash
# Script para parar todos os serviços
./stop.sh
```

## 📝 Estrutura de Arquivos

```
.
├── docker-compose.yml          # Orquestração dos serviços
├── trino/
│   ├── coordinator/           # Configuração do coordinator
│   ├── worker/               # Configuração do worker
│   └── catalog/              # Conectores de dados
├── opa/
│   ├── policies/             # Políticas Rego
│   └── data/                 # Dados para políticas
├── data/
│   └── init.sql              # Dados iniciais PostgreSQL
├── test-queries.sql          # Queries de exemplo
└── README.md                 # Esta documentação
```

## 🐛 Solução de Problemas

### ❌ "docker: command not found"
```bash
# Instalar Docker primeiro
# macOS: brew install docker
# Ubuntu: sudo apt install docker.io docker-compose
# Windows: Instalar Docker Desktop
```

### ❌ Trino não inicia
```bash
# Verificar memória disponível (precisa de 4GB+)
docker system df

# Ver logs detalhados
docker-compose logs -f trino-coordinator

# Reiniciar só o Trino
docker-compose restart trino-coordinator
```

### ❌ Porta já está em uso
```bash
# Verificar quais portas estão ocupadas
lsof -i :8080  # Trino
lsof -i :8181  # OPA
lsof -i :8088  # Superset
lsof -i :5432  # PostgreSQL

# Matar processo se necessário
kill -9 <PID>
```

### ❌ OPA não conecta
```bash
# Verificar se container está rodando
docker ps | grep opa

# Testar OPA diretamente
curl http://localhost:8181/health

# Ver logs do OPA
docker-compose logs -f opa
```

### ❌ Permissões negadas inesperadamente
```bash
# Verificar políticas
cat opa/policies/trino.rego

# Testar política manualmente
./test-opa-policies.sh

# Debug específico de usuário
curl -X POST http://localhost:8181/v1/data/trino/allow \
  -H "Content-Type: application/json" \
  -d '{"input": {"context": {"identity": {"user": "alice"}}, "action": {"operation": "SELECT"}}}'
```

### ❌ "Permission denied" nos scripts
```bash
# Dar permissão de execução
chmod +x start.sh stop.sh test-opa-policies.sh
```

### ❌ Superset não carrega
```bash
# Superset demora ~3-5 minutos na primeira vez
docker-compose logs -f superset

# Se der erro de driver, reiniciar
docker-compose restart superset
```

### ❌ Erro ao conectar Trino no Superset
```bash
# Verificar se o Trino está acessível do container Superset
docker exec trino-superset ping trino-coordinator

# Testar conexão manualmente
docker exec trino-superset curl http://trino-coordinator:8080/v1/info

# Se falhar, verificar network
docker network ls
docker network inspect trino_opa_trino-network
```

### ❌ "Database connection failed" no Superset
**Problemas comuns:**
1. **URI incorreta**: Use `trino://usuario@trino-coordinator:8080/postgresql`
2. **Container não encontrado**: Verifique se todos os containers estão na mesma network
3. **Driver não instalado**: O Superset instala automaticamente, aguarde

**Teste de conectividade:**
```bash
# Dentro do container Superset, teste:
docker exec -it trino-superset python3 -c "
from trino.dbapi import connect
conn = connect(host='trino-coordinator', port=8080, user='alice')
cursor = conn.cursor()
cursor.execute('SELECT 1')
print(cursor.fetchone())
"
```

### ❌ Colunas sensíveis aparecem para analistas
**Causa**: OPA não está filtrando corretamente

**Solução:**
```bash
# 1. Verificar políticas OPA
cat opa/policies/trino.rego

# 2. Testar política diretamente
curl -X POST http://localhost:8181/v1/data/trino/filtered_columns \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "context": {"identity": {"user": "alice"}},
      "action": {
        "operation": "FilterColumns",
        "resource": {
          "table": {"catalogName": "postgresql", "schemaName": "public", "tableName": "users"},
          "column": {"columnName": "ssn"}
        }
      }
    }
  }'

# 3. Verificar logs do Trino para requests OPA
docker-compose logs trino-coordinator | grep -i opa
```

## 🔗 URLs Importantes

- **Trino Web UI**: http://localhost:8080
- **Superset**: http://localhost:8088 (admin/admin)
- **OPA Health**: http://localhost:8181/health
- **PostgreSQL**: localhost:5432 (postgres/postgres)

## 🚀 Próximos Passos e Cenários Avançados

### Expandindo as Políticas OPA
1. **Filtragem por linha**: Implementar row-level security
2. **Horário de acesso**: Restringir acesso por horário
3. **Políticas por departamento**: Acesso baseado em departamento
4. **Auditoria**: Log de todas as queries executadas

### Exemplo de Política Avançada
```rego
# Política de horário comercial
allow if {
    user := input.context.identity.user
    user_has_permission(user, input.action.operation)
    is_business_hours
}

is_business_hours if {
    now := time.now_ns()
    hour := time.weekday(now)[1]
    hour >= 9
    hour <= 18
}
```

### Integrações Adicionais
- **Apache Ranger**: Para políticas mais complexas
- **LDAP/Active Directory**: Autenticação empresarial
- **Kubernetes**: Deploy em produção
- **Monitoring**: Prometheus + Grafana para métricas

## 📚 Mais Recursos

- [Documentação do Trino](https://trino.io/docs/)
- [Open Policy Agent Guide](https://www.openpolicyagent.org/docs/)
- [Apache Superset Docs](https://superset.apache.org/)
- [Trino Security Guide](https://trino.io/docs/current/security.html)
- [OPA Policy Examples](https://github.com/open-policy-agent/example-api-authz-go)

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.
