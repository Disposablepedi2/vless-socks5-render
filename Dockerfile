FROM teddysun/xray:latest
RUN apk add --no-cache python3
COPY start.sh /start.sh
RUN chmod +x /start.sh
EXPOSE 1080
CMD ["/start.sh"]
