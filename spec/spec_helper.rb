$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift File.expand_path("..", __FILE__)
# puts $LOAD_PATH
require "mantra"
require "fileutils"
require "helpers/markdown"
require "helpers/command"

ENV["RACK_ENV"] ||= "test"

def project_folder
  File.dirname(File.expand_path(File.dirname(__FILE__)))
end

def assets_path(*args)
  File.join(project_folder, "spec", "assets", *args)
end

def examples_path(*args)
  File.join(project_folder, "examples", *args)
end

