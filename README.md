# Mantra - मंत्र

[![Build Status](https://travis-ci.org/allomov/mantra.svg?branch=master)](https://travis-ci.org/allomov/mantra)

### Description

Mantra (/ˈmæntrə/, abr. **Man**ifest **Tra**nsformation for BOSH) is a tool to ease work with BOSH manifests.

It allows to perform such routines as:

* find manifest parts 
* extract cloud config for BOSH v2 from your BOSH v1 manifest
* convert you BOSH v1 manifest to BOSH v2 manifest
* convert your manifest into bosh-cli templates with
  * extracted passwords
  <!-- * extracted certificates to different files -->
  <!-- * templatized network configuration -->
  <!-- * extracted or changed properties -->
* and much more

Mantra tends to be an easily extendable tool, so you can add new commands and transforms by yourself. If you need have any questions or suggestions feel free to create an [issue on Github](https://github.com/allomov/mantra/issues) or contact [me](https://github.com/allomov) directly.

### Concepts

While some actions performed on manifest can be automated, anther require special configuration and extra knowledges about source manifes. Here is a small glossery that I use:

`Transformation Manifest` - config file that describes how your manifest should be udpated
`Source Manifest` - your source BOSH manifest, if you run templatizers on source manifest they can change it.
`Target Manifest` - manifest that will contain extracted template properties, to restore source manifest you'll need to run merge tool with resulting source manifest.
`Transform` - a ruby class that declares how specific transformation should be done.

One more concept: no nokogiri and native dependencies.

### Examples

- [Simple example of how to use a transform](https://github.com/allomov/mantra/blob/master/examples/filter-transform.md)
- [Example of `mantra merge` command to update your manifest](https://github.com/allomov/mantra/blob/master/examples/merge-command.md)
- [Convert BOSH v1 manifest to BOSH v2 manifest](https://github.com/allomov/mantra/blob/master/examples/convert-bosh-manifest-to-v2.md)
- [Extract cloud config from BOSH v1 manifest](https://github.com/allomov/mantra/blob/master/examples/extract-cloud-config.md)

### Run tests

```
rake
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mantra. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.
