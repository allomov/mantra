# Mantra

```
mantra find jobs[name=consul].properties manifest.yml
# mantra f
```

```
mantra transform transformation-manifest.yml manifest.yml
# mantra t
```

```
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
  target: workspace/properties.yml  
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
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mantra'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mantra

## Usage

TODO: Write usage instructions here

## Dependencies

`openssl`!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mantra. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

