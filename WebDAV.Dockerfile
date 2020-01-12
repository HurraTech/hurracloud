FROM bytemark/webdav
COPY entrypoint-webdav.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
EXPOSE 80/tcp 443/tcp
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
CMD [ "httpd-foreground" ]

