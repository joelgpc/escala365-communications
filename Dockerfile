FROM nginx:alpine

# Copiar la configuración de nginx
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

# Verificar que el archivo existe
RUN cat /etc/nginx/conf.d/default.conf

# Exponer puerto
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
