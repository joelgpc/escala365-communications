# Documentación de Configuración

## Índice

1. [Configuración de Asterisk](#configuración-de-asterisk)
2. [Integración CRM](#integración-crm)
3. [Generación de Audios](#generación-de-audios)
4. [Configuración de Agentes](#configuración-de-agentes)

## Configuración de Asterisk

### 1. PJSIP Endpoints

Los agentes están configurados en `asterisk/config/pjsip.conf`. Para añadir un nuevo agente:

```ini
[agent006]
type=endpoint
context=from-internal
transport=transport-tls
auth=agent006-auth
aors=agent006
callerid="Agente 6" <105>

[agent006-auth](auth-userpass)
username=agent006
password=PASSWORD_SEGURO

[agent006]
type=aor
max_contacts=1
```

### 2. Colas (Queues)

Editar `asterisk/config/queues.conf` para gestionar colas:

```ini
[nueva-cola]
strategy = rrmemory
timeout = 30
retry = 5
member => PJSIP/agent001
```

### 3. Dialplan

El flujo de llamadas está en `asterisk/config/extensions.conf`:

- `from-external`: Llamadas entrantes
- `from-internal`: Llamadas salientes y transferencias
- `queue-soporte` / `queue-ventas`: Colas específicas

## Integración CRM

### 1. Configurar AsterLink

Editar `asterlink/asterlink.conf`:

```yaml
agents:
  - extension: "agent001"
    crm_user_id: "UUID_DE_USUARIO_EN_SUITECRM"
```

### 2. Obtener UUID de Usuario

1. Acceder a SuiteCRM
2. Ir a Admin → Users
3. Editar usuario y copiar ID desde URL

## Generación de Audios

### Usando Google Cloud Text-to-Speech

```python
from google.cloud import texttospeech

client = texttospeech.TextToSpeechClient()

texto = """Bienvenido a Escala365. Le informamos que esta llamada
puede ser grabada con fines de calidad y formación..."""

synthesis_input = texttospeech.SynthesisInput(text=texto)

voice = texttospeech.VoiceSelectionParams(
    language_code="es-ES",
    name="es-ES-Neural2-A",
    ssml_gender=texttospeech.SsmlVoiceGender.FEMALE
)

audio_config = texttospeech.AudioConfig(
    audio_encoding=texttospeech.AudioEncoding.LINEAR16,
    sample_rate_hertz=8000
)

response = client.synthesize_speech(
    input=synthesis_input,
    voice=voice,
    audio_config=audio_config
)

with open("aviso-legal.wav", "wb") as out:
    out.write(response.audio_content)
```

Colocar archivo en: `asterisk/sounds/es/custom/aviso-legal-es.wav`

## Configuración de Agentes

### 1. Softphone Zoiper

**Configuración:**

- Account name: agent001
- Domain: IP_PUBLICA:5061
- Username: agent001
- Password: [desde .env]
- Transport: TLS
- SRTP: Mandatory

### 2. Códigos DTMF Útiles

- `*9`: Detener grabación (derecho oposición)
- `##`: Transferencia ciega
- `*2`: Atender segunda llamada

## Troubleshooting

### Problema: No hay audio en llamadas

**Solución**: Verificar puertos RTP abiertos (10000-20000 UDP)

```bash
sudo ufw status
```

### Problema: Agente no puede registrarse

**Solución**: Verificar password en pjsip.conf y certificados TLS

```bash
docker exec callcenter_asterisk asterisk -rx "pjsip show endpoints"
```

### Problema: CRM no recibe eventos

**Solución**: Verificar conexión AMI

```bash
docker logs callcenter_connector
```
