#!/bin/bash

# configure claude code before container starts

mkdir -p /root/.claude

# point claude at litellm and inject auth token
cat > /root/.claude/settings.json << EOF
{
  "env": {
    "ANTHROPIC_BASE_URL": "${ANTHROPIC_BASE_URL}",
    "ANTHROPIC_AUTH_TOKEN": "${ANTHROPIC_AUTH_TOKEN}"
  }
}
EOF

exec "$@"
