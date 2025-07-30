#!/bin/bash

echo "🔐 Testando Políticas OPA para Trino"
echo "===================================="
echo

# Função para testar políticas
test_policy() {
    local user=$1
    local operation=$2
    local table=$3
    local description=$4

    echo "📋 Teste: $description"
    echo "👤 Usuário: $user | 🔧 Operação: $operation | 📊 Recurso: $table"

    local query=$(cat <<EOF
{
  "input": {
    "context": {
      "identity": {
        "user": "$user"
      }
    },
    "action": {
      "operation": "$operation",
      "resource": {
        "table": {
          "catalogName": "postgresql",
          "schemaName": "public",
          "tableName": "$table"
        }
      }
    }
  }
}
EOF
)

    local result=$(curl -s -X POST http://localhost:8181/v1/data/trino/allow \
        -H "Content-Type: application/json" \
        -d "$query")

    local decision=$(echo "$result" | jq -r '.result // false')

    if [ "$decision" = "true" ]; then
        echo "✅ PERMITIDO"
    else
        echo "❌ BLOQUEADO"
    fi
    echo "📄 Resposta completa: $result"
    echo "----------------------------------------"
    echo
}

echo "🧪 Testando diferentes cenários:"
echo

# Admin - deve ter acesso total
test_policy "admin" "SELECT" "users" "Admin fazendo SELECT em users"
test_policy "admin" "CREATE_TABLE" "test_table" "Admin criando tabela"

# Alice (analista) - só SELECT
test_policy "alice" "SELECT" "users" "Alice (analista) fazendo SELECT"
test_policy "alice" "CREATE_TABLE" "test_table" "Alice tentando criar tabela"

# Bob (engenheiro) - SELECT/CREATE/INSERT/UPDATE
test_policy "bob" "SELECT" "users" "Bob (engenheiro) fazendo SELECT"
test_policy "bob" "CREATE_TABLE" "test_table" "Bob criando tabela"
test_policy "bob" "INSERT" "products" "Bob inserindo dados"

# Charlie (analista) - só SELECT
test_policy "charlie" "SELECT" "products" "Charlie (analista) fazendo SELECT"
test_policy "charlie" "UPDATE" "users" "Charlie tentando UPDATE"

echo "🎯 Testes de coluna sensível:"
echo

# Teste específico para colunas sensíveis
test_column_access() {
    local user=$1
    local column=$2
    local description=$3

    echo "📋 Teste: $description"
    echo "👤 Usuário: $user | 📊 Coluna: $column"

    local query=$(cat <<EOF
{
  "input": {
    "context": {
      "identity": {
        "user": "$user"
      }
    },
    "action": {
      "operation": "FilterColumns",
      "resource": {
        "table": {
          "catalogName": "postgresql",
          "schemaName": "public",
          "tableName": "users"
        },
        "column": {
          "columnName": "$column"
        }
      }
    }
  }
}
EOF
)

    local result=$(curl -s -X POST http://localhost:8181/v1/data/trino/filtered_columns \
        -H "Content-Type: application/json" \
        -d "$query")

    echo "📄 Resultado: $result"
    echo "----------------------------------------"
    echo
}

test_column_access "alice" "ssn" "Alice tentando acessar coluna SSN"
test_column_access "alice" "salary" "Alice tentando acessar coluna salary"
test_column_access "bob" "ssn" "Bob tentando acessar coluna SSN"
test_column_access "admin" "ssn" "Admin acessando coluna SSN"

echo "✅ Testes concluídos!"
