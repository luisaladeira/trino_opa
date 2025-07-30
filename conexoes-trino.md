# 🔗 Conexões Trino por Usuário no Superset

Para testar diferentes usuários sem depender de impersonation, crie **conexões separadas**:

## 📋 **Criando Conexões por Usuário**

### **1. Admin (acesso total)**
- **Nome**: `Trino - Admin`
- **SQLAlchemy URI**: `trino://admin@trino-coordinator:8080/postgresql`

### **2. Alice (analista)**
- **Nome**: `Trino - Alice`
- **SQLAlchemy URI**: `trino://alice@trino-coordinator:8080/postgresql`

### **3. Bob (engenheiro)**
- **Nome**: `Trino - Bob`
- **SQLAlchemy URI**: `trino://bob@trino-coordinator:8080/postgresql`

### **4. Charlie (analista)**
- **Nome**: `Trino - Charlie`
- **SQLAlchemy URI**: `trino://charlie@trino-coordinator:8080/postgresql`

## 🧪 **Como Testar**

1. **Crie todas as 4 conexões** acima no Superset
2. **No SQL Lab**, selecione diferentes databases
3. **Execute a mesma query** em cada uma:

```sql
SELECT * FROM public.users LIMIT 3;
```

4. **Compare os resultados** entre diferentes usuários

## ⚡ **Comando Rápido via CLI**

Alternativamente, use CLI diretamente:

```bash
# Alice
docker exec -it trino-coordinator trino --user alice --execute "SELECT name, department FROM postgresql.public.users LIMIT 2;"

# Bob
docker exec -it trino-coordinator trino --user bob --execute "SELECT name, department FROM postgresql.public.users LIMIT 2;"

# Admin
docker exec -it trino-coordinator trino --user admin --execute "SELECT name, department FROM postgresql.public.users LIMIT 2;"
```

**Esta abordagem garante que você pode testar todos os usuários facilmente!** 🎯
