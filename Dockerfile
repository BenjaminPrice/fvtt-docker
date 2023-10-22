FROM node:16-alpine

RUN deluser node && \
    mkdir -p /opt/foundryvtt/resources/app && \
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

# Set permissions for the volumes
USER root
RUN chown -R fvtt:fvtt /data/foundryvtt && \
    chown -R fvtt:fvtt /opt/foundryvtt/resources/app && \
    chmod -R g+s /data/foundryvtt && \
    chmod -R g+s /opt/foundryvtt/resources/app

USER fvtt
VOLUME /data/foundryvtt
VOLUME /host
VOLUME /opt/foundryvtt/resources/app
EXPOSE 30000

ENTRYPOINT /opt/foundryvtt/run-server.sh
