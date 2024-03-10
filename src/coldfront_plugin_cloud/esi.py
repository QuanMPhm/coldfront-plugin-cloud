import logging
import functools
import os

from keystoneauth1.identity import v3
from keystoneauth1 import session

from coldfront_plugin_cloud import attributes, utils
from coldfront_plugin_cloud.openstack import OpenStackResourceAllocator


QUOTA_KEY_MAPPING = {
    'network': {
        'keys': {
            attributes.ESI_FLOATING_IPS: 'floatingip',
            attributes.ESI_NETWORKS: 'network'
        }
    }
}


QUOTA_KEY_MAPPING_ALL_KEYS = dict()
for service in QUOTA_KEY_MAPPING.keys():
    QUOTA_KEY_MAPPING_ALL_KEYS.update(QUOTA_KEY_MAPPING[service]['keys'])


class ESIResourceAllocator(OpenStackResourceAllocator):

    resource_type = 'esi'

    def set_quota(self, project_id):
        for service_name, service in QUOTA_KEY_MAPPING.items():
            payload = dict()
            for coldfront_attr, openstack_key in service['keys'].items():
                value = self.allocation.get_attribute(coldfront_attr)
                if value is not None:
                    payload[openstack_key] = value

            if not payload:
                # Skip if service doesn't have any associated attributes
                continue

            self.network.update_quota(project_id, body={'quota': payload})

    def get_quota(self, project_id):
        quotas = dict()

        network_quota = self.network.show_quota(project_id)['quota']
        for k in QUOTA_KEY_MAPPING['network']['keys'].values():
            quotas[k] = network_quota.get(k)

        return quotas
