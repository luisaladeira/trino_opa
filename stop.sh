#!/bin/bash

echo "🛑 Parando ambiente Trino + OPA..."

# Parar os serviços
docker-compose down

echo "✅ Ambiente parado com sucesso!"
echo ""
echo "💾 Para remover também os dados (volumes):"
echo "   docker-compose down -v"
