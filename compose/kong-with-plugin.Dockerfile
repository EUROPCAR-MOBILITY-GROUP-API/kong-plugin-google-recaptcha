FROM kong:2.8.1

# Running in db-less mode
ENV KONG_DATABASE off
# load the plugin google-recaptcha
ENV KONG_PLUGINS bundled, google-recaptcha

USER root

# Installing kong plugin as lua modules
RUN luarocks install kong-plugin-google-recaptcha
