# Filter transform 

### Description

Filter all sections of a manifest, leaving only those you mention in parameters.

### Example

For example you may have `manifest.yml` file wit the following content:

```file:manifest.yml
section1:
  key: value
  properties: {cpu: 1}
section2: "value"
section3: [a1, a2, a3]
section4: "some-value"
```

Config for filter transform in `transform.yml` will look as following:

```file:transform.yml
transforms:
- type: "filter"
  sections: ["section1", "section3"]
```

To perform transformation run this command:

```command
mantra transform -m manifest.yml -t transform.yml
```

The output that you'll get is:

```output
section1:
  key: value
  properties:
    cpu: 1
section3:
- a1
- a2
- a3
```

