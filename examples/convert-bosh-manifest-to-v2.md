
# Convert BOSH manifest v1 to manifest v2

Imagine you have a following BOSH v1 manifest in following format:

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

You should be able to define transformations in the following format:

```file:transform.yml
transforms:
- type: filter
  sections: ["jobs", "releases", "stemcells", "update"]
- type: rename
  section: "jobs"
  to: "instance_groups"
- type: rename
  section: "instance_groups[].templates"
  to: "jobs"
- type: merge
  value:
    azs: az1
  to: "instance_groups[]"
- type: rename
  section: "instance_groups[].resource_pools"
  to: "vm_type"
```

And run this command:

```command
mantra transform -m manifest.yml -t transform.yml
```

And get following output:

```output
---
releases:
- name: cf-redis
  version: latest
- name: routing
  version: 0.143.0
update:
  canaries: 1
  max_in_flight: 6
instance_groups:
- instances: 3
  name: dedicated-node
  networks:
  - name: redis_z1
    static_ips:
    - 10.0.0.51
  persistent_disk: 4096
  resource_pool: redis_z1
  jobs:
  - name: dedicated-node
    release: cf-redis
  - name: syslog-configurator
    release: cf-redis
  azs: az1
- instances: 1
  lifecycle: errand
  name: smoke-tests
  networks:
  - name: redis_z1
  resource_pool: redis_z1
  jobs:
  - name: smoke-tests
    release: cf-redis
  azs: az1
```
