ARG BUILD_FROM=hassioaddons/base:5.0.1


FROM "voucher/vouch-proxy" as vouch
#FROM "talltechdude/vouch-proxy" as vouch


# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy binary from official container
COPY --from=vouch templates/ /opt/templates/
COPY --from=vouch static/ /opt/static/
COPY --from=vouch /vouch-proxy /opt/vouch-proxy

# Add envsubst
RUN apk add gettext

# Copy root filesystem
COPY rootfs /

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="Vouch Auth Proxy" \
    io.hass.description="An SSO and OAuth login solution for Nginx using the auth_request module" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="TallTechDude <talltechdude@gmail.com>" \
    org.label-schema.description="An SSO and OAuth login solution for Nginx using the auth_request module" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="Vouch Auth Proxy" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://gitlab.com/talltechdude/addon-vouch" \
    org.label-schema.usage="https://gitlab.com/talltechdude/addon-vouch/blob/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://gitlab.com/talltechdude/addon-vouch" \
    org.label-schema.vendor="TallTechDude's Hass.io Add-ons"
