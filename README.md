# Mantra - मंत्र

[![Build Status](https://travis-ci.org/allomov/mantra.svg?branch=master)](https://travis-ci.org/allomov/mantra)

### Description

Mantra (/ˈmæntrə/, abr. Manifest Transformation) is a tool to ease work with manifests.

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
transforms:
- type: filter
  sections: ["networks", "compilation", "update", "resource_pools", "disk_pools"]
- type: rename
  section: "resource_pools"
  to: "vm_types"
- type: rename
  section: "disk_pools"
  to: "disk_types"
- type: add
  section:
    az: z1
  to: "networks[].subnets[]"
- type: add
  section:
    az: z1
  to: "update"
- type: add
  section:
    az: z1
  to: "compilation"
- type: add
  section:
    azs:
    - name: z1
  to: ""
```


```yaml
transforms:
- type: extract-section
  section: jobs
  source: manifest.yml
  target: workspace/jobs.yml  
- type: extract-certificates
  source: workspace/properties.yml
  target: workspace/secrets.yml
- type: extract-certificates-to-files
  source: workspace/secrets.yml
  target: workspace/secrets
- type: extract
  source: manifest.yml
  section: jobs
- type: extract
  source: manifest.yml
  section: resource_pools
- type: extract
  source: manifest.yml
  section: resource_pools
- type: extract-spiff-option
  source: manifest.yml
  target: workspace/stub.yml
  regex: "*cfdomain.com*"
  spiff-property: meta.domain
- type: templatize-value
  source: manifest.yml
  target: workspace/stub.yml
  value: "*cfdomain.com*"
  spiff-property: meta.domain
```

```
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

