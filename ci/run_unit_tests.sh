#!/bin/bash

set -xe

if [[ ! "${CI}" == "true" ]]; then
    source /tmp/coldfront_venv/bin/activate
fi

export DJANGO_SETTINGS_MODULE="local_settings"
export DB_URL="postgres://postgres:postgres@localhost:5432/postgres"

coverage run --source="." -m django test coldfront_plugin_cloud.tests.unit
coverage report
