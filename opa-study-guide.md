# 🎓 Guia de Estudo: Políticas OPA para Trino

## 🎯 **Ambiente Configurado e Funcionando!**

✅ **OPA Server**: http://localhost:8181
✅ **Políticas carregadas**: `trino.rego`
✅ **Dados de usuários**: `users.json`
✅ **Trino**: http://localhost:8080
✅ **Superset**: http://localhost:8088

---

## 🧪 **Como Testar Suas Políticas**

### **1. Testes Básicos de Permissão**

```bash
# Admin (pode tudo)
curl -X POST http://localhost:8181/v1/data/trino/allow \
  -H "Content-Type: application/json" \
  -d '{"input": {"context": {"identity": {"user": "admin"}}, "action": {"operation": "SELECT"}}}'

# Alice (analista - só SELECT)
curl -X POST http://localhost:8181/v1/data/trino/allow \
  -H "Content-Type: application/json" \
  -d '{"input": {"context": {"identity": {"user": "alice"}}, "action": {"operation": "SELECT"}}}'

# Alice tentando CREATE (deve falhar)
curl -X POST http://localhost:8181/v1/data/trino/allow \
  -H "Content-Type: application/json" \
  -d '{"input": {"context": {"identity": {"user": "alice"}}, "action": {"operation": "CREATE_TABLE"}}}'

# Bob (engenheiro - pode SELECT/CREATE/INSERT/UPDATE)
curl -X POST http://localhost:8181/v1/data/trino/allow \
  -H "Content-Type: application/json" \
  -d '{"input": {"context": {"identity": {"user": "bob"}}, "action": {"operation": "CREATE_TABLE"}}}'
```

### **2. Teste de Colunas Sensíveis**

```bash
# Alice tentando acessar coluna SSN (deve ser filtrada)
curl -X POST http://localhost:8181/v1/data/trino/filtered_columns \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "context": {"identity": {"user": "alice"}},
      "action": {
        "operation": "FilterColumns",
        "resource": {
          "column": {"columnName": "ssn"}
        }
      }
    }
  }'
```

---

## 📝 **Estrutura das Suas Políticas**

### **Usuários e Roles (users.json)**
```json
{
  "users": {
    "admin": {"role": "admin"},
    "alice": {"role": "analyst"},
    "bob": {"role": "engineer"},
    "charlie": {"role": "analyst"}
  },
  "roles": {
    "admin": {"permissions": ["*"]},
    "engineer": {"permissions": ["SELECT", "INSERT", "UPDATE", "CREATE_TABLE", "DROP_TABLE"]},
    "analyst": {
      "permissions": ["SELECT"],
      "restricted_columns": ["ssn", "credit_card", "password"]
    }
  }
}
```

### **Regras de Política (trino.rego)**

#### **1. Regra Principal**
```rego
allow if {
    user := input.context.identity.user
    action := input.action.operation
    user_has_permission(user, action)
}
```

#### **2. Permissões por Role**
```rego
# Admin tem tudo
user_has_permission(user, operation) if {
    data.users.users[user].role == "admin"
}

# Verificar permissões específicas
user_has_permission(user, operation) if {
    user_role := data.users.users[user].role
    role_permissions := data.users.roles[user_role].permissions
    operation in role_permissions
}
```

#### **3. Filtro de Colunas**
```rego
filtered_columns contains column if {
    user := input.context.identity.user
    user_role := data.users.users[user].role
    user_role == "analyst"

    restricted := data.users.roles[user_role].restricted_columns
    column_name := input.action.resource.column.columnName
    column_name in restricted
    column := column_name
}
```

---

## 🔧 **Cenários para Experimentar**

### **Cenário 1: Novo Role "Manager"**

1. **Adicione** ao `users.json`:
```json
"roles": {
    "manager": {
        "permissions": ["SELECT", "INSERT"],
        "restricted_columns": ["salary"]
    }
}
```

2. **Teste**: Manager pode INSERT mas não vê salários

### **Cenário 2: Controle por Tabela**

Modifique `trino.rego` para controlar acesso por tabela:

```rego
user_has_permission(user, operation) if {
    user := "alice"
    operation == "SELECT"
    table := input.action.resource.table.tableName
    table in ["products", "sales"]  # Alice só vê essas tabelas
}
```

### **Cenário 3: Horário de Acesso**

```rego
allow if {
    user := input.context.identity.user
    operation := input.action.operation

    # Verificar horário comercial
    now := time.now_ns()
    hour := time.weekday(now)
    hour >= 8
    hour <= 18

    user_has_permission(user, operation)
}
```

---

## 🧪 **Script de Teste Completo**

Execute: `./test-opa-policies.sh` para testar todos os cenários.

---

## 🚀 **Próximos Passos de Estudo**

### **1. Políticas Avançadas**
- ✅ Controle por horário
- ✅ Limites de linhas por query
- ✅ Auditoria de acessos
- ✅ Políticas condicionais

### **2. Integração com Trino**
- ✅ Custom Access Control Plugin
- ✅ Event Listeners para auditoria
- ✅ Contexto adicional (IP, query, etc.)

### **3. Monitoramento**
- ✅ Logs de decisões OPA
- ✅ Métricas de acesso
- ✅ Alertas de violações

---

## 📚 **Recursos de Estudo**

- **OPA Playground**: https://play.openpolicyagent.org/
- **Rego Tutorial**: https://www.openpolicyagent.org/docs/latest/policy-language/
- **Trino Security**: https://trino.io/docs/current/security.html

**🎯 Você agora tem um laboratório completo para estudar e desenvolver políticas OPA!**

Execute queries, modifique políticas, teste diferentes cenários e veja os resultados em tempo real!
