#!/usr/bin/with-contenv bashio
# ==============================================================================
# TallTechDude Hass.io Add-ons: Vouch Proxy
# Runs the Vouch Proxy Server
# ==============================================================================

#bashio::config.require.ssl

export LOG_LEVEL=$(bashio::config 'log_level')
export DOMAIN=$(bashio::config 'domain')
export JWT_MAX_AGE=$(bashio::config 'jwt_max_age')
export VOUCH_URL=$(bashio::config 'vouch_url')
export HOMEASSISTANT_URL=$(bashio::config 'homeassistant_url')

envsubst '$LOG_LEVEL $DOMAIN $JWT_MAX_AGE $VOUCH_URL $HOMEASSISTANT_URL' < "/opt/config.yml" > "/data/config.yml" 

