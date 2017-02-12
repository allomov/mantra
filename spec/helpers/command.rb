require "open3"

def run_mantra_command(command)
  env = ENV.to_hash
  env["PATH"] = "#{ENV["PATH"]}:#{File.join(project_folder, "bin")}"
  stdout, status = Open3.capture2(env, *processor.command)
  return stdout, status
end
