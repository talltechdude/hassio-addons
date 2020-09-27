# Vouch SSO Addon


The Vouch Addon allows the use of Home Assistant's built in authentication and Single Sign On functionality to be used by other applications such as extra entries in the [Nginx Proxy Manager Addon](https://github.com/hassio-addons/addon-nginx-proxy-manager).

## Configuration

**Note**: _Remember to restart the add-on when the configuration is changed._

Example add-on configuration:

```yaml
"domain": "homeassistant.io"
"homeassistant_url": "https://home.homeassistant.io"
"vouch_url": "https://vouch.homeassistant.io"
"jwt_max_age": 10080
"log_level": "info"
```

**Note**: _This is just an example, don't copy and paste it! Create your own!_

### Option: `domain`

The base domain that all other DNS entries sit under - e.g. `homeassistant.io`.

### Option: `homeassistant_url`

The public facing Home Assistant URL used to redirect to for authentication pages - e.g. `https://home.homeassistant.io`.

### Option: `vouch_url`

The public facing URL used for the Vouch addon using the steps below - e.g. `https://vouch.homeassistant.io`.

### Option: `jwt_max_age`

The age (in secods) for access tokens to last before being re-prompted for authentication

### Option: `log_level`

The `log_level` option controls the level of log output by the addon and can
be changed to be more or less verbose, which might be useful when you are
dealing with an unknown issue. Possible values are:

- `trace`: Show every detail, like all called internal functions.
- `debug`: Shows detailed debug information.
- `info`: Normal (usually) interesting events.
- `warning`: Exceptional occurrences that are not errors.
- `error`:  Runtime errors that do not require immediate action.
- `fatal`: Something went terribly wrong. Add-on becomes unusable.

Please note that each level automatically includes log messages from a
more severe level, e.g., `debug` also shows `info` messages. By default,
the `log_level` is set to `info`, which is the recommended setting unless
you are troubleshooting.

## Installation

### Step 1:
Install and configure addon as described above.

### Step 2:
Add a new proxy item to Nginx Proxy Manager for this Vouch plugin:
[Nginx Proxy Manager Config](https://gitlab.com/talltechdude/addon-vouch/-/raw/master/images/NPM-vouch-screenshot.png?inline=false)

### Step 3:
Add the following snippit to the `Custom Nginx Configuration` under the `Advanced` tab in Nginx Proxy Manager for any proxy host you would like to protect.

NB: update the `$vouch_host` variable to your vouch proxy host name from Nginx Proxy Manager in Step 2 above (e.g. vouch.yourdomain.com)

```Nginx
    #####################################################################
    #########           Vouch Proxy Authentication              #########
    #####################################################################

    # Update this variable to match your public vouch URL (e.g. vouch.yourdomain.com)
    set $vouch_host "vouch.yourdomain.com";
    
    
    #####################################################################
    # No other edits required below this line

    # send all requests to the `/validate` endpoint for authorization
    auth_request /vouch_validate;
    
    location = /vouch_validate {
      # forward the /validate request to Vouch Proxy
      # proxy_pass http://1fdd3664-vouch:9090/validate;
      proxy_pass http://local-vouch:9090/validate;
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
    }

    # if validate returns `401 not authorized` then forward the request to the error401block
    error_page 401 = @error401;

    location @error401 {
        # redirect to Vouch Proxy for login
        return 302 https://$vouch_host/login?url=$scheme://$http_host$request_uri&vouch-failcount=$auth_resp_failcount&X-Vouch-Token=$auth_resp_jwt&error=$auth_resp_err;
    }

    #####################################################################
    #########         END Vouch Proxy Authentication            #########
    #####################################################################    
```
