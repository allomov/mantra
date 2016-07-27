# Mantra - मंत्र

[![Build Status](https://travis-ci.org/allomov/mantra.svg?branch=master)](https://travis-ci.org/allomov/mantra)

### Description

Mantra (/ˈmæntrə/, abr. **Man**ifest **Tra**nsformation) is a tool to ease work with manifests.

It allows to do following:

* find manifest parts 
* extract cloud config from you BOSH v1 manifest
* convert your manifest into spiff templates with
  * extracted passwords
  * extracted certificates to different files
  * templatized network configuration
  * extracted or changed properties
* and much more

Mantra is tend to be an easily extendable tool, so you can add new commands and transforms.

### Concepts

While some actions performed on manifest can be automated, anther require special configuration and extra knowledges about source manifes. Here is a small glossery that I use:

`Transformation Manifest` - config file that describes how your manifest should be udpated
`Source Manifest` - your source BOSH manifest, if you run templatizers on source manifest they can change it.
`Target Manifest` - manifest that will contain extracted template properties, to restore source manifest you'll need to run merge tool with resulting source manifest.
`Transform` - a ruby class that declares how specific transformation should be done.

### Examples

Find and output in json some manifest parts:

```
mantra find jobs[name=consul].properties -m manifest.yml -f json
# alias: mantra f
```

Transform BOSH v1 manifest to extract cloud config:

```
mantra transform -c transformation-manifest.yml -m manifest.yml
# mantra t
```

Here is an example of `transformation-manifest.yml`:

```yaml
global:
  source: manifest.yml
  target: cloud-config.yml
transforms:
- filter:
    sections: ["networks", "compilation", "update", "resource_pools", "disk_pools"]
- rename:
    section: "resource_pools"
    to: "vm_types"
- rename:
    section: "disk_pools"
    to: "disk_types"
- type: add
    section:
      az: z1
    to: "networks[].subnets[]"
- add:
    section:
      az: z1
    to: "update"
- add:
    section:
      az: z1
    to: "compilation"
- add:
    section:
      azs:
      - name: z1
    to: ""
```


```yaml
global_vars:
  source: manifest.yml
transforms:
- extract:
    section: jobs
    to:   workspace/jobs.yml  
- extract-certs:
    from: workspace/properties.yml
    to:   workspace/secrets.yml
- extract-certs-to-files:
    from: workspace/secrets.yml
    to:   workspace/secrets
- extract:
    section: jobs
    to:
      file: manifest.yml
      with_scope: meta.jobs
- extract:
    source: manifest.yml
    section: resource_pools
- extract:
    section: resource_pools
    to: resource_pools.yml
- extract:
    section: networks
    to: networks.yml
- templatize-ip-address:
    from:  networks.yml
    to: workspace/stub.yml
    quads:
      - range: "1-2"
        scope: meta.networks.cf.prefix
        with_value: "192.168"
      - number: 3
        scope: meta.networks.cf.quad1
        with_value: 2
      - number: 3
        scope: meta.networks.cf.quad2
        with_value: 3
- templatize-value:
    source: manifest.yml
    to: workspace/stub.yml
    value: cfdomain.com
    in: "*.cfdomain.com"
    scope: meta.domain
```


## Installation

Install it as a gem:

```
    $ gem install mantra
```

## Dependencies

`openssl`!

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mantra. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

