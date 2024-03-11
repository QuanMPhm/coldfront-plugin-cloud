# Creates the appropriate credentials and runs tests
#
# Tests expect the resource to be name ESI
set -xe

source /opt/stack/devstack/openrc admin admin

credential_name=$(openssl rand -base64 12)

export ESI_ESI_APPLICATION_CREDENTIAL_SECRET=$(
    openstack application credential create "$credential_name" -f value -c secret)
export ESI_ESI_APPLICATION_CREDENTIAL_ID=$(
    openstack application credential show "$credential_name" -f value -c id)

export ESI_PUBLIC_NETWORK_ID=$(openstack network show public -f value -c id)

if [[ ! "${CI}" == "true" ]]; then
    source /tmp/coldfront_venv/bin/activate
fi

export DJANGO_SETTINGS_MODULE="local_settings"
export FUNCTIONAL_TESTS="True"
export OS_AUTH_URL="http://$HOST_IP/identity"
export KEYCLOAK_URL="http://$HOST_IP:8080"
export KEYCLOAK_USER="admin"
export KEYCLOAK_PASS="nomoresecret"
export KEYCLOAK_REALM="master"

coverage run --source="." -m django test coldfront_plugin_cloud.tests.functional.esi
coverage report

openstack application credential delete $ESI_ESI_APPLICATION_CREDENTIAL_ID
