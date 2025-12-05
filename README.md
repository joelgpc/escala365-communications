# Escala365 VoIP Integration

Sistema de integración VoIP entre SuiteCRM y Asterisk, optimizado para Oracle Cloud ARM via Coolify.

## 🎯 Características

- **Pop-up Automático**: Notificación en CRM cuando llega una llamada
- **Click-to-Call**: Llamar desde el CRM con un click
- **SuiteCRM**: CRM open source con integración telefónica
- **Asterisk PBX**: Central telefónica profesional
- **AsterLink**: Conector en tiempo real vía WebSocket
- **ARM64 Optimizado**: Para Oracle Cloud Always Free

## 🚀 Despliegue Rápido

Ver [Guía de Inicio Rápido](docs/QUICK_START.md) para instrucciones paso a paso.

### Resumen de 3 Pasos:

1. **Deploy en Coolify**

   - Copiar `docker-compose.yml`
   - Configurar variables de entorno
   - Asignar dominios

2. **Configurar SuiteCRM**

   - Instalar módulo AsterLink
   - Generar API keys
   - Configurar extensión de usuario

3. **Probar**
   - Registrar softphone (ext. 100)
   - Hacer llamada de prueba
   - Ver pop-up en CRM

## 📁 Estructura

```
├── asterisk/
│   └── config/
│       ├── manager.conf    # AMI para AsterLink
│       ├── pjsip.conf      # Extensiones SIP
│       └── extensions.conf # Dialplan básico
├── asterlink/
│   └── asterlink.yml       # Config WebSocket
├── docs/
│   ├──QUICK_START.md      # Guía de despliegue
│   └── configuracion.md    # Config avanzada
├── .env.example            # Variables de entorno
└── docker-compose.yml      # Stack completo
```

## 🔐 Seguridad

**IMPORTANTE**: Antes de desplegar en producción:

- [ ] Cambiar todas las contraseñas en `.env`
- [ ] Configurar firewall (solo puertos necesarios)
- [ ] Activar HTTPS en Coolify (Let's Encrypt)
- [ ] Configurar restricciones de IP para AMI

## 📊 Requisitos de Sistema

- **Oracle Cloud**: VM.Standard.A1.Flex (2 OCPU, 12GB RAM mínimo)
- **Puertos**: 5060 UDP, 8010 TCP, 8080 TCP
- **Dominio**: Con DNS configurado
- **Coolify**: v 4.x o superior

## 🛠️ Próximos Pasos

Después de tener funcionando el pop-up:

1. **Colas de Llamadas**: Configurar queues para soporte/ventas
2. **Más Extensiones**: Añadir agentes adicionales
3. **IVR**: Sistema de menú interactivo
4. **Grabación**: Grabar llamadas con avisos legales
5. **Reportes**: Estadísticas de llamadas en CRM

Ver [Configuración Avanzada](docs/configuracion.md) para más detalles.

## 🤝 Soporte

- [Issues](https://github.com/tuusuario/escala365-communications/issues)
- [Documentación Completa](docs/)

## 📜 Licencia

MIT
