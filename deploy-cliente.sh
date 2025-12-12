#!/bin/bash

# Script para desplegar el CLIENTE en NODO 1
# Este script prepara los archivos del cliente para ser servidos desde un servidor web

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# ====================================================================
# ⚠️ CAMBIO CRUCIAL: URL PÚBLICA DEL SERVIDOR (TU TÚNEL NGROK)
# Reemplaza esta línea con la URL HTTPS real de tu túnel ngrok.
NGROK_URL="https://jailless-ayako-tenaciously.ngrok-free.dev"
# ====================================================================

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Despliegue CLIENTE - NODO 1${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Variables configurables
CLIENTE_DIR="/var/www/gimnasio/cliente"
# ⚠️ Eliminar SERVER_IP o usar la URL de ngrok para consistencia
SERVER_URL_PLACEHOLDER="SERVER_URL_PLACEHOLDER"

echo -e "${YELLOW}Configurando CLIENTE para comunicarse con SERVIDOR en: $NGROK_URL${NC}"
echo ""

# Detectar usuario del servidor web según el sistema operativo
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    WEB_USER="_www"
    WEB_GROUP="_www"
    USE_SUDO="sudo"
elif [ -f /etc/debian_version ]; then
    # Debian/Ubuntu
    WEB_USER="www-data"
    WEB_GROUP="www-data"
    USE_SUDO="sudo"
elif [ -f /etc/redhat-release ]; then
    # CentOS/RHEL
    WEB_USER="apache"
    WEB_GROUP="apache"
    USE_SUDO="sudo"
else
    # Por defecto, usar usuario actual
    WEB_USER=$(whoami)
    WEB_GROUP=$(whoami)
    USE_SUDO=""
fi

# Crear estructura de directorios
echo -e "${YELLOW}[1/5] Creando estructura de directorios...${NC}"
if [ -n "$USE_SUDO" ]; then
    sudo mkdir -p "$CLIENTE_DIR/public"
    sudo mkdir -p "$CLIENTE_DIR/assets/css"
    sudo mkdir -p "$CLIENTE_DIR/assets/js"
else
    mkdir -p "$CLIENTE_DIR/public"
    mkdir -p "$CLIENTE_DIR/assets/css"
    mkdir -p "$CLIENTE_DIR/assets/js"
fi
echo -e "${GREEN}✅ Directorios creados${NC}"

# Copiar archivos estáticos
echo -e "${YELLOW}[2/5] Copiando archivos estáticos...${NC}"
if [ -d "public/assets" ]; then
    if [ -n "$USE_SUDO" ]; then
        sudo cp -r public/assets/* "$CLIENTE_DIR/assets/"
    else
        cp -r public/assets/* "$CLIENTE_DIR/assets/"
    fi
    echo -e "${GREEN}✅ Assets copiados${NC}"
else
    echo -e "${RED}❌ No se encontró public/assets${NC}"
    exit 1
fi

# Crear archivo HTML del cliente
echo -e "${YELLOW}[3/5] Creando archivo HTML del cliente...${NC}"
# ⚠️ MODIFICACIÓN 1: El placeholder ahora es SERVER_URL_PLACEHOLDER
cat > /tmp/index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sistema de Gestión de Gimnasio - Cliente</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
    <header class="header">
        <div class="container">
            <h1 class="logo">🏋️ Gimnasio MVC</h1>
            <nav class="nav">
                <a href="#" onclick="loadPage('member')" class="nav-link">Miembros</a>
                <a href="#" onclick="loadPage('class')" class="nav-link">Clases</a>
                <a href="#" onclick="loadPage('payment')" class="nav-link">Pagos</a>
            </nav>
        </div>
    </header>
    
    <main class="main container" id="content">
        <div id="loading">Cargando desde el servidor...</div>
    </main>
    
    <footer class="footer">
        <div class="container">
            <p>Sistema de Gestión de Gimnasio - Arquitectura Cliente-Servidor</p>
            <p><small>CLIENTE: Nodo 1 | SERVIDOR: Nodo 2</small></p>
        </div>
    </footer>
    
    <script>
        // Configuración del SERVIDOR
        const SERVER_URL = 'SERVER_URL_PLACEHOLDER';
    </script>
    <script src="/assets/js/client.js"></script>
</body>
</html>
EOF

# ⚠️ MODIFICACIÓN 2: Reemplazar el placeholder por la URL de ngrok
if [ -n "$USE_SUDO" ]; then
    sed "s|SERVER_URL_PLACEHOLDER|$NGROK_URL|g" /tmp/index.html | sudo tee "$CLIENTE_DIR/public/index.html" > /dev/null
else
    sed "s|SERVER_URL_PLACEHOLDER|$NGROK_URL|g" /tmp/index.html > "$CLIENTE_DIR/public/index.html"
fi
echo -e "${GREEN}✅ Archivo HTML creado${NC}"

# Crear JavaScript del cliente
echo -e "${YELLOW}[4/5] Creando JavaScript del cliente...${NC}"
cat > /tmp/client.js << 'EOF'
/**
 * CLIENTE: JavaScript que se ejecuta en el navegador
 * Se comunica con el SERVIDOR mediante peticiones HTTP
 */

// Obtener URL del servidor desde la configuración
// ⚠️ MODIFICACIÓN 3: El fallback ahora es la URL de ngrok
const SERVER_URL = window.SERVER_URL || 'https://jailless-ayako-tenaciously.ngrok-free.dev';

/**
 * CLIENTE: Envía petición HTTP al SERVIDOR
 */
async function requestToServer(controller, action, method = 'GET', data = null) {
    const url = `${SERVER_URL}/index.php?controller=${controller}&action=${action}`;
    
    const options = {
        method: method,
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        mode: 'cors',
        credentials: 'omit'
    };
    
    if (data && method === 'POST') {
        options.body = new URLSearchParams(data).toString();
    }
    
    try {
        const response = await fetch(url, options);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const html = await response.text();
        return html;
    } catch (error) {
        console.error('Error comunicándose con el servidor:', error);
        return `<div class="alert alert-error">Error de conexión con el servidor: ${error.message}</div>`;
    }
}

/**
 * CLIENTE: Carga una página desde el SERVIDOR
 */
async function loadPage(page) {
    const content = document.getElementById('content');
    content.innerHTML = '<div id="loading">Cargando desde el servidor...</div>';
    
    // CLIENTE: Envía petición GET al SERVIDOR
    const html = await requestToServer(page, 'index');
    content.innerHTML = html;
    
    // Inicializar eventos después de cargar
    initializeEvents();
}

/**
 * CLIENTE: Maneja envío de formularios
 */
function handleFormSubmit(form, controller, action) {
    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const formData = new FormData(form);
        const data = Object.fromEntries(formData);
        
        // CLIENTE: Envía datos al SERVIDOR mediante POST
        const result = await requestToServer(controller, action, 'POST', data);
        
        if (result.includes('success') || result.includes('exitosamente')) {
            alert('Operación exitosa');
            loadPage(controller);
        } else {
            document.getElementById('content').innerHTML = result;
            initializeEvents();
        }
    });
}

/**
 * CLIENTE: Inicializa eventos después de cargar contenido
 */
function initializeEvents() {
    // Manejar enlaces
    document.querySelectorAll('a[href*="controller="]').forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const url = new URL(link.href, window.location.origin);
            const controller = url.searchParams.get('controller');
            loadPage(controller);
        });
    });
    
    // Manejar botones de eliminar
    document.querySelectorAll('a[href*="action=delete"]').forEach(link => {
        link.addEventListener('click', async (e) => {
            e.preventDefault();
            if (confirm('¿Está seguro de eliminar este registro?')) {
                const url = new URL(link.href, window.location.origin);
                const controller = url.searchParams.get('controller');
                const action = url.searchParams.get('action');
                const id = url.searchParams.get('id');
                
                await requestToServer(controller, action, 'GET', { id: id });
                loadPage(controller);
            }
        });
    });
    
    // Manejar formularios
    document.querySelectorAll('form').forEach(form => {
        const action = form.action;
        if (action.includes('store')) {
            const match = action.match(/controller=(\w+)/);
            if (match) {
                handleFormSubmit(form, match[1], 'store');
            }
        } else if (action.includes('update')) {
            const match = action.match(/controller=(\w+)/);
            if (match) {
                handleFormSubmit(form, match[1], 'update');
            }
        }
    });
}

// CLIENTE: Cargar página inicial
document.addEventListener('DOMContentLoaded', () => {
    loadPage('member');
});
EOF

if [ -n "$USE_SUDO" ]; then
    sudo cp /tmp/client.js "$CLIENTE_DIR/assets/js/client.js"
else
    cp /tmp/client.js "$CLIENTE_DIR/assets/js/client.js"
fi
echo -e "${GREEN}✅ JavaScript del cliente creado${NC}"

# Configurar permisos
echo -e "${YELLOW}[5/5] Configurando permisos...${NC}"

# Verificar si el usuario existe antes de cambiar ownership
if id "$WEB_USER" &>/dev/null 2>&1; then
    if [ -n "$USE_SUDO" ]; then
        sudo chown -R "$WEB_USER:$WEB_GROUP" "$CLIENTE_DIR"
        sudo chmod -R 755 "$CLIENTE_DIR"
    else
        chown -R "$WEB_USER:$WEB_GROUP" "$CLIENTE_DIR" 2>/dev/null || true
        chmod -R 755 "$CLIENTE_DIR"
    fi
    echo -e "${GREEN}✅ Permisos configurados (usuario: $WEB_USER)${NC}"
else
    # Si no existe, usar usuario actual
    CURRENT_USER=$(whoami)
    if [ -n "$USE_SUDO" ]; then
        sudo chown -R "$CURRENT_USER:$CURRENT_USER" "$CLIENTE_DIR"
        sudo chmod -R 755 "$CLIENTE_DIR"
    else
        chmod -R 755 "$CLIENTE_DIR"
    fi
    echo -e "${YELLOW}⚠️  Usuario $WEB_USER no encontrado, usando usuario actual ($CURRENT_USER)${NC}"
fi
echo -e "${GREEN}✅ Permisos configurados${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Cliente desplegado exitosamente${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Próximos pasos:${NC}"
echo -e "1. Configura Nginx/Apache para servir desde: $CLIENTE_DIR/public"
echo -e "2. Configura CORS para permitir comunicación con: $SERVER_IP"
echo -e "3. Reinicia el servidor web"
echo ""