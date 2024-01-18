# Creates the appropriate credentials and runs tests
#
# Tests expect the resource to be name Devstack
set -xe

export OPENSHIFT_MICROSHIFT_USERNAME="admin"
export OPENSHIFT_MICROSHIFT_PASSWORD="pass"

if [[ ! "${CI}" == "true" ]]; then
    source /tmp/coldfront_venv/bin/activate
fi

export DJANGO_SETTINGS_MODULE="local_settings"
export FUNCTIONAL_TESTS="True"
export OS_AUTH_URL="https://onboarding-onboarding.cluster.local"

export ACCT_MGT_ADMIN_USERNAME=admin
export ACCT_MGT_ADMIN_PASSWORD=pass
export ACCT_MGT_IDENTITY_PROVIDER=developer
export ACCT_MGT_OPENSHIFT_URL=https://172.17.0.2:6443

coverage run --source="." -m django test coldfront_plugin_cloud.tests.functional.openshift
coverage report
