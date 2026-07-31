FROM teddysun/xray:latest

# Install envsubst for config generation
RUN apk add --no-cache gettext bash

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Xray config template
COPY config.json.template /etc/xray/config.json.template

EXPOSE 1080

CMD ["/start.sh"]
