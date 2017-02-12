
# Example of mantra merge command

Imagine you have in your `manifest.yml` file something like this:

```file:manifest.yml
networks:
- name: redis_z1
releases:
- name: cf-redis
  version: 23
- name: cf-redis-broker
  version: 13
- name: backup-and-monitoring
  version: 3
update:
  canaries: 1
  max_in_flight: 6
```

And you want to update all releases which names start from `cf` prefix to have `"latest"` version. You can do it using `mantra merge` command as following:

```command
mantra merge -m manifest.yml -j '{"version": "latest"}' -s releases[name=cf-*]
```

As an output you will have a following manifest:

```output
networks:
- name: redis_z1
releases:
- name: cf-redis
  version: latest
- name: cf-redis-broker
  version: latest
- name: backup-and-monitoring
  version: 3
update:
  canaries: 1
  max_in_flight: 6
```

As you see all release versions that start with `cf` prefix got updated versions to the `latest`.
