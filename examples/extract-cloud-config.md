
# How to extract Cloud Config

```file:manifest.yml
compilation:
  cloud_properties: {cpu: 1}
  network: redis_z1
director_uuid: DIRECTOR_ID
jobs:
- instances: 3
  name: dedicated-node
  networks:
  - name: redis_z1
    static_ips:
    - 10.0.0.51
  persistent_disk: 4096
  resource_pool: redis_z1
  templates:
  - {name: dedicated-node, release: cf-redis}
  - {name: syslog-configurator, release: cf-redis}
- instances: 1
  lifecycle: errand
  name: smoke-tests
  networks:
  - name: redis_z1
  resource_pool: redis_z1
  templates:
  - {name: smoke-tests, release: cf-redis}
networks:
- name: redis_z1
  subnets:
  - cloud_properties:
      name: YOUR_SUBNET_NAME
    dns:
    - 8.8.8.8
    gateway: 10.0.0.1
    range: 10.0.0.0/24
    reserved:
    - 10.0.0.2 - 10.0.0.49
    static:
    - 10.0.0.50 - 10.0.0.99
properties:
  redis:
    agent:
      backend_port: 54321
    host: 10.0.0.50
    maxmemory: 262144000
  syslog_aggregator:
    address: REPLACE_WITH_SYSLOG_AGGREGATOR_HOST
    port: REPLACE_WITH_SYSLOG_AGGREGATOR_PORT
releases:
- {name: cf-redis, version: latest}
- {name: routing, version: 0.143.0}
resource_pools:
- cloud_properties:
    cpu: 1
  name: redis_z1
  stemcell: {name: bosh-vsphere-esxi-ubuntu-trusty-go_agent, version: latest}
update:
  canaries: 1
  max_in_flight: 6
```

```file:transform.yml
transforms:
- type: "filter"
  sections: ["networks", "compilation", "update", "resource_pools", "disk_pools"]
- type: "rename"
  section: "resource_pools"
  to: "vm_types"
- type: "rename"
  section: "disk_pools"
  to: "disk_types"
- type: merge
  value: &az-hash
    az: az1
  to: "networks[].subnets[]"
- type: merge
  value: *az-hash
  to: "update"
- type: merge
  value: *az-hash
  to: "compilation"
```

```command
mantra transform -m manifest.yml -t transform.yml
```

```output
value
```