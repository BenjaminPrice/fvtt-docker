FROM node:16-alpine

RUN deluser node && \
    mkdir /opt/foundryvtt && \
    mkdir /data && \
    mkdir /data/foundryvtt && \
    adduser --disabled-password fvtt && \
    chown fvtt:fvtt /opt/foundryvtt && \
    chown fvtt:fvtt /data/foundryvtt && \
    chmod g+s /opt/foundryvtt && \
    chmod g+s /data/foundryvtt
USER fvtt

COPY --chown=fvtt run-server.sh /opt/foundryvtt
RUN chmod +x /opt/foundryvtt/run-server.sh
VOLUME /data/foundryvtt
VOLUME /host
EXPOSE 30000

ENTRYPOINT /opt/foundryvtt/run-server.sh
