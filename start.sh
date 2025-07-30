#!/bin/bash

echo "🚀 Iniciando ambiente Trino + OPA + Superset..."

# Verificar se Docker está rodando
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker não está rodando. Por favor, inicie o Docker primeiro."
    exit 1
fi

# Verificar se docker-compose está disponível
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "❌ docker-compose não está instalado."
    exit 1
fi

# Subir os serviços
echo "📦 Subindo serviços..."
docker-compose up -d

echo "⏳ Aguardando serviços ficarem prontos..."

# Aguardar PostgreSQL
echo "🗄️  Aguardando PostgreSQL..."
while ! docker exec trino-postgres pg_isready -U postgres >/dev/null 2>&1; do
    sleep 2
done
echo "✅ PostgreSQL pronto!"

# Aguardar OPA
echo "🔐 Aguardando OPA..."
while ! curl -s http://localhost:8181/health >/dev/null; do
    sleep 2
done
echo "✅ OPA pronto!"

# Aguardar Trino Coordinator
echo "🧠 Aguardando Trino Coordinator..."
while ! curl -s http://localhost:8080/v1/info >/dev/null; do
    sleep 5
done
echo "✅ Trino Coordinator pronto!"

# Aguardar Superset
echo "📊 Aguardando Superset..."
while ! curl -s http://localhost:8088/health >/dev/null; do
    sleep 5
done
echo "✅ Superset pronto!"

echo ""
echo "🎉 Ambiente iniciado com sucesso!"
echo ""
echo "📋 Informações dos serviços:"
echo "   • Trino Web UI: http://localhost:8080"
echo "   • Superset UI: http://localhost:8088"
echo "   • OPA: http://localhost:8181"
echo "   • PostgreSQL: localhost:5432"
echo ""
echo "👤 Usuários disponíveis:"
echo "   • admin - Acesso total"
echo "   • alice - Analista (SELECT apenas)"
echo "   • bob - Engenheiro (SELECT/INSERT/UPDATE/CREATE)"
echo "   • charlie - Analista (SELECT apenas)"
echo ""
echo "🔑 Credenciais Superset:"
echo "   • Usuário: admin"
echo "   • Senha: admin"
echo ""
echo "🧪 Para testar via CLI:"
echo "   docker exec -it trino-coordinator trino --user alice"
echo ""
echo "📚 Para mais informações, consulte o README.md"
