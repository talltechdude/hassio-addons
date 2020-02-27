# Vouch SSO Addon

The Vouch Addon allows the use of Hass.io's built in SSO functionality to be used by other applications such as extra entries in the [Nginx Proxy Manager Addon](https://github.com/hassio-addons/addon-nginx-proxy-manager).

## Example configuration

Below are some configuration files that can be used to proxy hosts to require HomeAssistant SSO authentication before proxing. Add something similar to Nginx Proxy Manager for this Vouch plugin then add these files to `/share/npm`

[![Nginx Proxy Manager Config](https://gitlab.com/talltechdude/addon-vouch/-/raw/master/images/NPM-vouch-screenshot.png?inline=false)]

#### `/share/npm/http.conf`
```
# map directive to exclude backends from requiring authorization 
# specifically need to exclude homeassistant and vouch to provide the actual authentication flow, but custom entries can be added too
# e.g. interal-example      0;
map $server $vouch_ignore_backend {
    hostnames;
    default                                   1;
    homeassistant                             0;
    homeassistant.local.hass.io               0;
    755a1d8b-vouch                            0;
    755a1d8b-vouch.local.hass.io              0;
    1fdd3664-vouch                            0;
    1fdd3664-vouch.local.hass.io              0;
    127.0.0.1                                 0;
    localhost                                 0;
    # internal-example                        0;
}  

map $host $vouch_ignore_host {
    hostnames;
    default                                   1;
    # example.hassio.local                    0;
}
```

#### `/share/npm/server_proxy.conf`

NB: update the $vouch_host variable to your vouch proxy host name from Nginx Proxy Manager above

```
    set $vouch_host "vouch.yourdomain.com";
    
    # send all requests to the `/validate` endpoint for authorization
    auth_request /vouch_validate;
    
    location = /vouch_validate {
      # use map from http.conf to exclude homeassistant & vouch
      if ($vouch_ignore_backend = 0) {
          return 200;
      }
  
      if ($vouch_ignore_host = 0) {
          return 200;
      }

      if ($vouch_ignore ~ "^$") {
          set $vouch_ignore 0;
      }

      if ($vouch_ignore = 1) {
          return 200;
      }

      # forward the /validate request to Vouch Proxy
      proxy_pass http://1fdd3664-vouch:9090/validate;
      # be sure to pass the original host header
      proxy_set_header Host $http_host;
      
      # Vouch Proxy only acts on the request headers
      proxy_pass_request_body off;
      proxy_set_header Content-Length "";

      # optionally add X-Vouch-User as returned by Vouch Proxy along with the request
      auth_request_set $auth_resp_x_vouch_user $upstream_http_x_vouch_user;

      # these return values are used by the @error401 call
      auth_request_set $auth_resp_jwt $upstream_http_x_vouch_jwt;
      auth_request_set $auth_resp_err $upstream_http_x_vouch_err;
      auth_request_set $auth_resp_failcount $upstream_http_x_vouch_failcount;

      # Vouch Proxy can run behind the same Nginx reverse proxy
      # may need to comply to "upstream" server naming
      # proxy_pass http://vouch.yourdomain.com/validate;
      # proxy_set_header Host $http_host;
    }

    # if validate returns `401 not authorized` then forward the request to the error401block
    error_page 401 = @error401;

    location @error401 {
        # redirect to Vouch Proxy for login
        return 302 https://$vouch_host/login?url=$scheme://$http_host$request_uri&vouch-failcount=$auth_resp_failcount&X-Vouch-Token=$auth_resp_jwt&error=$auth_resp_err;
        # you usually *want* to redirect to Vouch running behind the same Nginx config proteced by https  
        # but to get started you can just forward the end user to the port that vouch is running on
        # return 302 http://vouch.yourdomain.com:9090/login?url=$scheme://$http_host$request_uri&vouch-failcount=$auth_resp_failcount&X-Vouch-Token=$auth_resp_jwt&error=$auth_resp_err;
    }
```
