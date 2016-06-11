$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "mantra"
require "fileutils"

ENV["RACK_ENV"] ||= "test"

def assets_path(*args)
  File.join(File.expand_path(File.dirname(__FILE__)), "assets", File.join(args))
end


