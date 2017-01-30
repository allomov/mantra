shared_examples_for "markdown example" do
  let(:processor) { markdown_example_processor(examples_path(markdown_file)) }
  let(:temp_folder) { File.join(project_folder, "tmp") }

  before(:each) do
    Dir.chdir temp_folder
    processor.files.each_pair do |name, content|
      File.open(name, 'w') { |file| file.write(content) }
    end
  end


  describe "example" do
    it "can be run" do      
      processor.files.each_pair do |name, content|
        File.open(name, 'w') { |file| file.write(content) }
      end
      stdout, status = run_mantra_command(processor.command)
      expect(status).to be_success
    end
  end
end

describe "convert bosh v1 manifest ro bosh v2 manifest" do
  it_should_behave_like "markdown example" do
    let(:markdown_file) { "convert-bosh-manifest-to-v2.md" }
  end
end
