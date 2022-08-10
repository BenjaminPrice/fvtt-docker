FROM node:16-alpine

RUN deluser node && \
    mkdir -p /opt/foundryvtt && \
    mkdir -p /data/foundryvtt && \
    addgroup fvtt &&\
    adduser --disabled-password -G fvtt fvtt && \
    chown fvtt:fvtt /opt/foundryvtt && \
    chown fvtt:fvtt /data/foundryvtt && \
    chmod g+s /opt/foundryvtt && \
    chmod g+s /data/foundryvtt
USER fvtt

COPY --chown=fvtt run-server.sh /opt/foundryvtt
RUN chmod +x /opt/foundryvtt/run-server.sh
VOLUME /data/foundryvtt
VOLUME /host
VOLUME /opt/foundryvtt/resources/app
EXPOSE 30000

ENTRYPOINT /opt/foundryvtt/run-server.sh
