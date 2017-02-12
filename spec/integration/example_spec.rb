shared_examples_for "markdown example" do
  let(:processor) { markdown_example_processor(examples_path(markdown_file)) }
  let(:temp_folder) { Dir.mktmpdir }

  before(:each) do
    Dir.chdir(temp_folder)
    processor.files.each_pair do |name, content|
      File.open(name, 'w') { |file| file.write(content) }
    end
  end

  describe "example" do
    it "is executed without errors" do
      stdout, status = run_mantra_command(processor.command)
      expect(status).to be_success
    end
    it "contains expected manifest" do
      stdout, status = run_mantra_command(processor.command)
      expect(stdout).to include(processor.output)
    end
  end
end

describe "filter transform example" do
  it_should_behave_like "markdown example" do
    let(:markdown_file) { "filter-transform.md" }
  end
end

describe "mantra merge command example" do
  it_should_behave_like "markdown example" do
    let(:markdown_file) { "merge-command.md" }
  end
end

# describe "convert bosh v1 manifest ro bosh v2 manifest" do
#   it_should_behave_like "markdown example" do
#     let(:markdown_file) { "convert-bosh-manifest-to-v2.md" }
#   end
# end

describe "convert bosh v1 manifest ro bosh v2 manifest" do
  it_should_behave_like "markdown example" do
    let(:markdown_file) { "extract-cloud-config.md" }
  end
end
