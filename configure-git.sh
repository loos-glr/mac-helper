#!/usr/bin/env sh

if [ -e .env ]; then
    . ./.env
fi

if [ -z "${NAME}" ] || [ -z "${EMAIL}" ]; then
    echo "Error: NAME and EMAIL must be set. Copy .env.example to .env and fill in your values." >&2
    exit 1
fi

echo "Configuring your git..."
echo "Setting email ${EMAIL} for ${NAME}"
git config --global user.name "${NAME}"
git config --global user.email "${EMAIL}"
echo "done!"