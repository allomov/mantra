# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mantra/version'

Gem::Specification.new do |spec|
  spec.name          = "mantra"
  spec.version       = Mantra::VERSION
  spec.authors       = ["Alexander Lomov"]
  spec.email         = ["lomov.as@gmail.com"]

  spec.summary       = %q{mantra - Manifest Transfromation for BOSH}
  spec.description   = %q{Manifest Transfromation for BOSH}
  # spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["mantra"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",   "~> 1.11"
  spec.add_development_dependency "rake",      "~> 10.0"
  spec.add_development_dependency "rspec",     "~> 3.4"
  spec.add_development_dependency "rspec-its", "~> 1.2"
  spec.add_development_dependency 'redcarpet', '~> 3.4', '>= 3.4.0'
end
