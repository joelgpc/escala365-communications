# Guía de Despliegue Rápido - VoIP Integration

## 🎯 Objetivo

Hacer funcionar **SuiteCRM + Asterisk + AsterLink** para tener:

- Pop-up automático cuando llega una llamada
- Click-to-call desde el CRM

## 📋 Pre-requisitos

- Coolify instalado en Oracle Cloud ARM
- Dominio configurado
- Puertos abiertos: 5060 UDP, 8010 TCP, 8080 TCP

## 🚀 Pasos de Despliegue

### 1. En Coolify - Crear Servicio

1. **Projects** → **New Service** → **Docker Compose**
2. Pegar contenido de `docker-compose.yml`
3. Configurar **Environment Variables**:
   ```
   DB_ROOT_PASSWORD=TuPasswordRoot
   DB_PASSWORD=TuPasswordDB
   ADMIN_PASSWORD=TuPasswordAdmin
   CRM_DOMAIN=https://crm.tudominio.com
   ```

### 2. Configurar Dominios en Coolify

- **Puerto 8080**: `crm.tudominio.com` (SuiteCRM)
- **Puerto 8010**: `ws.tudominio.com` (WebSocket AsterLink)

### 3. Deploy

Click en **Deploy** y espera ~5 minutos a que SuiteCRM inicialice.

### 4. Configurar SuiteCRM

#### 4.1 Instalar Módulo AsterLink

1. Descargar: [AsterLink.zip](https://github.com/serfreeman1337/asterlink/raw/master/module/AsterLink.zip)
2. SuiteCRM → **Admin** → **Module Loader**
3. **Upload** y **Install**

#### 4.2 Generar API Keys

1. SuiteCRM → **Admin** → **OAuth2 Clients and Tokens**
2. **Create New**:
   - Name: `AsterLink`
   - Copiar el **Client ID** y **Client Secret**

#### 4.3 Actualizar AsterLink Config

En tu servidor (SSH):

```bash
cd ~/crm-voip-stack
nano asterlink/asterlink.yml
```

Actualizar:

```yaml
crm:
  url: https://crm.tudominio.com
  key: "CLIENT_SECRET_AQUI"
  id: "CLIENT_ID_AQUI"
```

Reiniciar:

```bash
docker restart voip_connector
```

#### 4.4 Configurar Usuario

1. SuiteCRM → **Mi Perfil**
2. Sección **AsterLink Configuration**:
   - Extension: `100`
   - WebSocket URL: `wss://ws.tudominio.com`
3. **Guardar**

### 5. Probar con Softphone

#### 5.1 Configurar Zoiper

- **Domain**: IP_PUBLICA_ORACLE:5060
- **Username**: 100
- **Password**: 100
- **Transport**: UDP

#### 5.2 Hacer Llamada de Prueba

1. Registra Zoiper con extensión 100
2. Desde otro teléfono, llama a la extensión 100
3. **Resultado esperado**: Pop-up en SuiteCRM mostrando la llamada

## 🔧 Troubleshooting

### Pop-up no aparece

```bash
# Ver logs de AsterLink
docker logs voip_connector

# Verificar conexión AMI
docker exec pbx_engine asterisk -rx "manager show connected"
```

### Zoiper no registra

```bash
# Ver endpoints
docker exec pbx_engine asterisk -rx "pjsip show endpoints"

# Ver logs
docker logs pbx_engine
```

## 📊 Verificación de Estado

```bash
# Todos los contenedores corriendo
docker ps

# SuiteCRM accesible
curl https://crm.tudominio.com

# WebSocket respondiendo
curl -v https://ws.tudominio.com
```

## ✅ Checklist de Despliegue

- [ ] Variables de entorno configuradas
- [ ] Dominios apuntando correctamente
- [ ] Puertos abiertos en Oracle Cloud
- [ ] SuiteCRM accesible vía web
- [ ] Módulo AsterLink instalado
- [ ] API keys generadas y configuradas
- [ ] Extensión 100 registrada en Zoiper
- [ ] Pop-up funcionando
