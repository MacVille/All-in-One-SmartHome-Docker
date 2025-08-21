FROM homeassistant/home-assistant:stable

COPY /src/Configs/ha-configuration-example.yaml /defaults/configuration.template.yaml
COPY /src/Scripts/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 8123

ENTRYPOINT ["/entrypoint.sh"]
CMD ["python", "-m", "homeassistant", "--config", "/config"]


