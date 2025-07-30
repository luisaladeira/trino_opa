# 🔐 Testando Impersonation com OPA

Este documento explica como testar as políticas de segurança OPA impersonando diferentes usuários.

## 🎯 Método 1: Via Superset SQL Lab (Recomendado)

### 1. Atualizar Conexão Trino no Superset

1. **Acesse**: Settings → Database Connections → **Editar conexão Trino**
2. **Na aba "Advanced"** → **SQL Lab**:
   - ✅ Marque: **"Allow user impersonation"**
   - ✅ Marque: **"Allow file uploads to databases"** (opcional)

3. **Salve** a conexão

### 2. Usar Impersonation no SQL Lab

1. **Acesse**: SQL → SQL Lab
2. **Selecione**: Database "Trino Local"
3. **Na interface**, você verá um campo **"Run SQL as:"**
4. **Digite o usuário** que quer impersonar: `alice`, `bob`, `charlie`, ou `admin`

### 3. Queries de Teste por Usuário

#### 🔧 **Admin (acesso total)**
```sql
-- ✅ Deve funcionar - admin tem acesso a tudo
SELECT * FROM public.users;
CREATE TABLE public.test_admin (id INT, name VARCHAR(50));
```

#### 👩‍💼 **Alice (analista - só SELECT)**
```sql
-- ✅ Deve funcionar - analistas podem fazer SELECT
SELECT name, department, salary FROM public.users;

-- ❌ Deve falhar - analistas não veem colunas sensíveis
SELECT * FROM public.users;

-- ❌ Deve falhar - analistas não podem CREATE
CREATE TABLE public.test_alice (id INT);
```

#### 👨‍💻 **Bob (engenheiro - SELECT/INSERT/UPDATE/CREATE)**
```sql
-- ✅ Deve funcionar - engenheiros têm mais permissões
SELECT * FROM public.users;
CREATE TABLE public.test_bob (id INT, name VARCHAR(50));
INSERT INTO public.products (name, category, price) VALUES ('Test', 'test', 10.00);
```

#### 👨‍🎨 **Charlie (analista - mesmo que Alice)**
```sql
-- ✅ Deve funcionar
SELECT name, department FROM public.users WHERE department = 'analytics';

-- ❌ Deve falhar - não pode ver colunas sensíveis
SELECT ssn, credit_card FROM public.users;
```

## 🎯 Método 2: Via CLI Trino (Para testes avançados)

### Conectar com usuários específicos:

```bash
# Conectar como Alice (analista)
docker exec -it trino-coordinator trino --user alice

# Conectar como Bob (engenheiro)
docker exec -it trino-coordinator trino --user bob

# Conectar como Charlie (analista)
docker exec -it trino-coordinator trino --user charlie

# Conectar como Admin
docker exec -it trino-coordinator trino --user admin
```

### Testar queries específicas:
```sql
-- No CLI do Trino
SHOW CATALOGS;
SHOW SCHEMAS FROM postgresql;
SELECT * FROM postgresql.public.users LIMIT 3;
```

## 🎯 Método 3: Verificar Logs OPA

Para monitorar as decisões do OPA em tempo real:

```bash
# Ver logs do OPA
docker-compose logs -f opa

# Fazer uma query no Superset e observar as decisões
```

## 🔍 Validação das Políticas

### ✅ **Comportamentos Esperados:**

| Usuário | SELECT básico | Colunas sensíveis | CREATE/INSERT |
|---------|---------------|-------------------|---------------|
| admin   | ✅ Permitido  | ✅ Permitido      | ✅ Permitido  |
| alice   | ✅ Permitido  | ❌ Bloqueado      | ❌ Bloqueado  |
| bob     | ✅ Permitido  | ✅ Permitido      | ✅ Permitido  |
| charlie | ✅ Permitido  | ❌ Bloqueado      | ❌ Bloqueado  |

### 🚨 **Colunas Sensíveis Bloqueadas:**
- `ssn` (CPF)
- `credit_card` (Cartão de crédito)
- `password` (Senha)

## 🛠️ Troubleshooting

### Se impersonation não funcionar:

1. **Verificar configuração Superset**:
   ```bash
   docker exec -it trino-superset cat /app/superset_config.py | grep -i imperson
   ```

2. **Verificar logs Trino**:
   ```bash
   docker-compose logs trino-coordinator | grep -i "user\|auth"
   ```

3. **Testar conexão OPA**:
   ```bash
   curl -X GET http://localhost:8181/v1/data/trino
   ```

## 📊 Exemplo Prático

1. **Abra SQL Lab** no Superset
2. **Selecione "Run SQL as: alice"**
3. **Execute**: `SELECT * FROM public.users LIMIT 5;`
4. **Observe**: Colunas sensíveis devem estar ausentes
5. **Troque para "Run SQL as: admin"**
6. **Execute a mesma query**
7. **Observe**: Agora todas as colunas aparecem

**Desta forma você pode validar se suas políticas OPA estão funcionando corretamente!** 🎯
