#!/bin/sh

set -e

# Respect NPM_CONFIG_USERCONFIG if it is provided, default to $HOME/.npmrc
NPM_CONFIG_USERCONFIG="${NPM_CONFIG_USERCONFIG:-"$HOME/.npmrc"}"

if [ -n "$NPM_AUTH_TOKEN" ]; then
  NPM_REGISTRY_URL="${NPM_REGISTRY_URL:-registry.npmjs.org}"
  NPM_STRICT_SSL="${NPM_STRICT_SSL:-true}"
  NPM_REGISTRY_SCHEME="https"
  if ! $NPM_STRICT_SSL
  then
    NPM_REGISTRY_SCHEME="http"
  fi
  
  # Allow registry.npmjs.org to be overridden with an environment variable
  printf "//%s/:_authToken=%s\\nregistry=%s\\nstrict-ssl=%s" "$NPM_REGISTRY_URL" "$NPM_AUTH_TOKEN" "${NPM_REGISTRY_SCHEME}://$NPM_REGISTRY_URL" "${NPM_STRICT_SSL}" > "$NPM_CONFIG_USERCONFIG"
  
  chmod 0600 "$NPM_CONFIG_USERCONFIG"
fi

if [ -n "$NPM_AUTH_TOKEN_0" ]; then
  i=0
  eval currentToken=\${NPM_AUTH_TOKEN_$i}
  eval currentUrl=\${NPM_REGISTRY_URL_$i}
  touch "$NPM_CONFIG_USERCONFIG"

  while [ ! -z "$currentToken" ] && [ ! -z "$currentUrl" ]; do
    printf "//%s/:_authToken=%s\\n" "$currentUrl" "$currentToken" >> "$NPM_CONFIG_USERCONFIG"

    i=$((i+1))
    eval currentToken=\${NPM_AUTH_TOKEN_$i}
    eval currentUrl=\${NPM_REGISTRY_URL_$i}
  done
  
  chmod 0600 "$NPM_CONFIG_USERCONFIG"
fi

sh -c "yarn $*"
