FROM ubuntu:22.04

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=linux

# Instalar Asterisk sin prompts
RUN apt-get update && apt-get install -y \
    asterisk asterisk-modules asterisk-core-sounds-en \
    asterisk-moh-opsound-gsm curl wget git \
    python3 python3-pip ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN pip3 install openai-whisper --no-cache-dir

RUN mkdir -p /var/lib/asterisk/scripts && \
    chown asterisk:asterisk /var/lib/asterisk/scripts

COPY sip.conf /etc/asterisk/sip.conf
COPY extensions.conf /etc/asterisk/extensions.conf
COPY http.conf /etc/asterisk/http.conf

RUN chown asterisk:asterisk /etc/asterisk/*.conf

EXPOSE 5060/udp 5038 8088

USER asterisk

CMD ["/usr/sbin/asterisk", "-f"]
