# Despliegue por Fases - Guía Simplificada

## 🎯 Estrategia

**Fase 1**: SuiteCRM + Asterisk funcionando (llamadas básicas)  
**Fase 2**: Integración VoIP (pop-up en CRM)

## 📋 Fase 1: Core Stack

### Paso 1: Deploy en Coolify

1. **Eliminar servicio anterior** si existe
2. **New Service** → **Docker Compose**
3. Copiar contenido de `docker-compose.yml`

### Paso 2: Variables de Entorno

```
DB_ROOT_PASSWORD=dbtest2025
DB_PASSWORD=P0stgr3s_Sup3r_S3cur3_Key_2025!
ADMIN_PASSWORD=Jesucristo93.
ADMIN_EMAIL=admin@escala365.com
SUITECRM_PUBLIC_URL=https://ggk8gok8o04swgk8480kkwo4.apps.elanchurch.org
```

### Paso 3: Configurar Dominio

En Coolify:

- **Puerto 8080**: Asignar dominio para SuiteCRM

### Paso 4: Deploy

Click **Deploy** y esperar 5-10 minutos.

**Verificar**:

```bash
# Ver logs
docker logs crm_app
docker logs pbx_engine

# Estado de servicios
docker ps
```

### Paso 5: Acceder a SuiteCRM

1. Abrir: `https://ggk8gok8o04swgk8480kkwo4.apps.elanchurch.org`
2. Login:
   - Username: `admin`
   - Password: `Jesucristo93.`

### Paso 6: Probar Asterisk con Zoiper

#### 6.1 Descargar Zoiper

- [Windows/Mac/Linux](https://www.zoiper.com/en/voip-softphone/download/current)

#### 6.2 Configurar Extensión 100

**En Zoiper**:

- Account name: `Agente 1`
- Domain: `143.47.41.244:5060`
- Username: `100`
- Password: `100pass`
- Transport: UDP

#### 6.3 Verificar Registro

En servidor Oracle:

```bash
docker exec pbx_engine asterisk -rx "pjsip show endpoints"
```

Debería mostrar:

```
100    alaw,ulaw    Unavailable/Available    0
```

#### 6.4 Segunda Extensión (Opcional)

En otro dispositivo/navegador:

- Domain: `143.47.41.244:5060`
- Username: `101`
- Password: `101pass`

#### 6.5 Test de Llamada

1. Desde ext 100, marcar: `101`
2. Debería sonar en la otra extensión
3. **Audio bidireccional OK** = ✅ Fase 1 completa

## 📋 Fase 2: Integración VoIP (Después)

### Opción A: Módulo Nativo SuiteCRM

1. SuiteCRM → Admin → Module Loader
2. Buscar módulo "Asterisk Integration" o "VoIP"
3. Instalar y configurar

### Opción B: AsterLink (Manual)

Si el módulo nativo no funciona, instalar AsterLink:

```bash
# En servidor Oracle
docker run -d \
  --name voip_connector \
  --network host \
  -v $(pwd)/asterlink.yml:/app/config.yml:ro \
  IMAGE_ASTERLINK
```

(Instrucciones detalladas después de completar Fase 1)

## 🔧 Troubleshooting

### SuiteCRM no carga

```bash
docker logs crm_app
# Verificar healthcheck de MariaDB
docker exec crm_db mysql -u root -p$DB_ROOT_PASSWORD -e "SHOW DATABASES;"
```

### Zoiper no registra

```bash
# Ver logs de Asterisk
docker logs pbx_engine

# Ver endpoints
docker exec pbx_engine asterisk -rx "pjsip show endpoints"

# Verificar puerto 5060 UDP abierto
sudo ufw status
```

### No hay audio en llamadas

```bash
# Verificar puertos RTP (10000-20000 UDP)
sudo ufw allow 10000:20000/udp

# Ver configuración NAT
docker exec pbx_engine asterisk -rx "pjsip show transports"
```

## ✅ Checklist Fase 1

- [ ] SuiteCRM accesible vía web
- [ ] Login admin funciona
- [ ] Zoiper registra extensión 100
- [ ] Zoiper registra extensión 101 (opcional)
- [ ] Llamada 100 → 101 suena
- [ ] Audio bidireccional OK

**Una vez completa Fase 1, procedemos a Fase 2** 🚀

## 📊 Puertos Requeridos (Oracle Cloud)

### Security List / Firewall

**TCP**:

- 8080 (SuiteCRM - via Coolify)
- 5038 (AMI - solo localhost, no abrir)

**UDP**:

- 5060 (SIP)
- 10000-20000 (RTP - audio)

### UFW en servidor

```bash
sudo ufw allow 5060/udp
sudo ufw allow 10000:20000/udp
sudo ufw allow 8080/tcp
sudo ufw allow 443/tcp
```

## 📝 Próximos Pasos

1. ✅ Deploy stack básico
2. ✅ Acceder a SuiteCRM
3. ✅ Probar llamadas con Zoiper
4. ⏳ Instalar módulo VoIP en CRM
5. ⏳ Configurar pop-up
6. ⏳ Click-to-call
