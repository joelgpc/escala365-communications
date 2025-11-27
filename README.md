# ESCALA365 Communications

Sistema de comunicaciones integrado con Asterisk, React y Node.js.

## Estructura

- **backend/**: API Node.js + Express
- **frontend/**: React App + Softphone SIP.js
- **asterisk/**: Configuración de PBX
- **nginx/**: Reverse Proxy

## Despliegue

Este proyecto está configurado para desplegarse con Docker Compose.

```bash
docker-compose up -d
```
