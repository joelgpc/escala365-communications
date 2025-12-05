# Escala365 Call Center

Sistema de call center impulsado por Asterisk, SuiteCRM y AsterLink, optimizado para despliegue en Oracle Cloud ARM via Coolify.

## 🎯 Características

- **Asterisk PBX**: Central telefónica open source con soporte TLS/SRTP
- **SuiteCRM**: CRM open source con integración telefónica
- **AsterLink**: Conector en tiempo real entre Asterisk y CRM
- **Cumplimiento RGPD**: Grabaciones con aviso legal, Lista Robinson, retención automatizada
- **Arquitectura ARM64**: Optimizado para Oracle Cloud Always Free tier

## 📋 Requisitos

- **Oracle Cloud**: Instancia VM.Standard.A1.Flex (4 OCPU, 24GB RAM)
- **Coolify**: Instalado y configurado
- **Dominio**: Con DNS apuntando a la IP pública
- **Let's Encrypt**: Certificados SSL automáticos

## 🚀 Despliegue Rápido

### 1. Clonar Repositorio

```bash
git clone https://github.com/tuusuario/escala365-communications.git
cd escala365-communications
```

### 2. Configurar Variables de Entorno

```bash
cp .env.example .env
nano .env
```

Actualiza todas las contraseñas y la IP pública de Oracle Cloud.

### 3. Configurar Oracle Cloud Security List

Abre los siguientes puertos en la VCN:

- `5060 TCP/UDP`: SIP
- `5061 TCP`: SIP over TLS
- `10000-20000 UDP`: RTP (audio)
- `80/443 TCP`: HTTPS

### 4. Desplegar en Coolify

1. Crear nuevo proyecto en Coolify
2. Seleccionar "Docker Compose"
3. Pegar contenido de `docker-compose.yml`
4. Añadir variables de entorno desde `.env`
5. Configurar dominios:
   - SuiteCRM: `crm.tudominio.com` → Port 8080
   - AsterLink: `ws.tudominio.com` → Port 8010
6. Deploy

### 5. Configurar Softphones

Configurar Zoiper o Linphone para los agentes:

- **Servidor**: `IP_PUBLICA:5061`
- **Usuario**: `agent001` (etc.)
- **Contraseña**: Desde `.env`
- **Transporte**: TLS
- **SRTP**: Mandatory

## 📁 Estructura del Proyecto

```
├── asterisk/
│   ├── config/           # Configuración PBX
│   ├── sounds/es/custom/ # Audios personalizados
│   └── scripts/          # Scripts de cumplimiento
├── asterlink/            # Conector Asterisk-CRM
├── suitecrm/             # Configuraciones CRM
├── docs/                 # Documentación adicional
└── docker-compose.yml    # Orquestación de servicios
```

## 🔐 Cumplimiento Normativo

### LSSICE - Aviso de Grabación

- Reproducción automática antes de iniciar grabación
- Opción DTMF 9 para detener grabación (derecho de oposición)

### Lista Robinson

- Verificación automática en llamadas salientes
- Base de datos local sincronizable

### RGPD - Retención de Datos

- Grabaciones eliminadas automáticamente después de 90 días
- Logs de auditoría de todas las eliminaciones

## 📊 Monitorización

Instalar Prometheus + Grafana para monitorizar:

- CPU/RAM de la instancia
- Llamadas concurrentes
- Latencia RTP
- Tiempos de espera en colas

## 🔧 Mantenimiento

### Backups Automáticos

```bash
# Añadir a crontab
0 3 * * * /path/to/asterisk/scripts/backup-callcenter.sh
```

### Limpieza RGPD

```bash
# Ejecutar diariamente
0 3 * * * /path/to/asterisk/scripts/cleanup-recordings.sh
```

## 📖 Documentación Adicional

- [Configuración Detallada](docs/configuracion.md)
- [Manual de Agentes](docs/manual-agentes.md)
- [Troubleshooting](docs/troubleshooting.md)

## 🤝 Soporte

Para soporte, contactar a través de [issues](https://github.com/tuusuario/escala365-communications/issues).

## 📜 Licencia

MIT
