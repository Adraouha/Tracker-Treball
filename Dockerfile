# Imagen base oficial de Node.js ligera para la capa gratuita de AWS
FROM node:20-alpine

LABEL maintainer="Hassan Adraou"
LABEL description="Tracker Treball - Sistema Integral de Control Horario y Gestion de Equipos"

WORKDIR /app

# Copiar el contenido del proyecto al contenedor
COPY . /app

# Exponer el puerto de Tracker Treball
EXPOSE 8080

# Configuracion de ejecucion en produccion
ENV NODE_ENV=production
ENV PORT=8080

# Iniciar el servidor (compatible si server.js esta en backend/ o en la raiz)
CMD ["sh", "-c", "if [ -f backend/server.js ]; then node backend/server.js; else node server.js; fi"]
