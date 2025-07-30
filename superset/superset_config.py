import os
from flask_appbuilder.security.manager import AUTH_OID, AUTH_DB, AUTH_LDAP, AUTH_OAUTH

# Configurações básicas
SECRET_KEY = "trino-superset-secret-key-change-in-production"

# Configuração SQLite com threading corrigido
SQLALCHEMY_DATABASE_URI = (
    "sqlite:////app/superset_home/superset.db?check_same_thread=false"
)

# Configurações de pool de conexões para SQLite
SQLALCHEMY_ENGINE_OPTIONS = {
    "pool_pre_ping": True,
    "pool_recycle": 300,
    "connect_args": {"check_same_thread": False, "timeout": 20},
}

# Configurações de Trino
SQLALCHEMY_TRACK_MODIFICATIONS = False
WTF_CSRF_ENABLED = True

# Configurações de autenticação
AUTH_TYPE = AUTH_DB
AUTH_ROLE_ADMIN = "Admin"
AUTH_ROLE_PUBLIC = "Public"

# Cache Redis (opcional)
CACHE_CONFIG = {
    "CACHE_TYPE": "simple",
}

# Configurações de logging
ENABLE_PROXY_FIX = True

# Configurações específicas para Trino
PREFERRED_DATABASES = [
    {
        "name": "Trino",
        "engine": "trino",
        "preferred": True,
    }
]

# Permitir conexões de dados via UI
PREVENT_UNSAFE_DB_CONNECTIONS = False

# Configurações de feature flags
FEATURE_FLAGS = {
    "ENABLE_TEMPLATE_PROCESSING": True,
    "SQLLAB_BACKEND_PERSISTENCE": True,
    "ENABLE_SUPERSET_META_DB": True,
    "SQLLAB_USER_IMPERSONATION": True,  # Habilitar impersonation
}

# Configurações de timeout
SQLLAB_TIMEOUT = 300  # 5 minutos
SUPERSET_WEBSERVER_TIMEOUT = 300

# Row limit para SQL Lab
DEFAULT_SQLLAB_LIMIT = 1000
SQL_MAX_ROW = 100000

# Configurações de impersonation
SQLLAB_IMPERSONATION = True
SQLLAB_QUERY_COST_ESTIMATE_ENABLED = False

# Configurações adicionais para threading
RESULTS_BACKEND_USE_MSGPACK = True
SQLLAB_ASYNC_TIME_LIMIT_SEC = 600
