describe Mantra::Transform::TemplatizeValue do
  # subject { Mantra::Transforms::TemplatizeValue }
  let(:transform) { Mantra::Transform.create(options.merge(type: type)) }
  let(:type)      { :"templatize-value" }
  let(:source)    { Mantra::Manifest.new(options["source"]) }
  let(:target)    { Mantra::Manifest.new(options["target"]) }

  describe "#run" do

    before(:each) do
      tmpdir = Dir.mktmpdir("mantra-tests")
      FileUtils.cp(assets_path("transforms", "manifest.yml"), tmpdir)
      FileUtils.cp(assets_path("transforms", "stub.yml"), tmpdir)
      Dir.chdir(tmpdir)
    end

    describe "validations" do
      describe "error on source manifest doesn't exist" do
        let(:options) do
          {"source" => "non-existing-manifest.yml", "target" => "stub.yml", "value" => "domain.com"}
        end
        it "raises error that source manifest file does not exists" do
          expect { transform.run }.to raise_error Mantra::Transform::ValidationError
        end
      end
      describe "error with no source specified" do
        let(:options) do
          {"target" => "stub.yml", "value" => "domain.com"}
        end
        it "raises error when no source specified" do
          expect { transform.run }.to raise_error(Mantra::Transform::ValidationError)
        end
      end
      describe "correct input" do
        let(:options) do
          {"source" => "manifest.yml", "target" => "stub.yml", "value" => "domain.com", "scope" => "meta.scope"}
        end
        it "does not raise an error" do
          expect { transform.run }.not_to raise_error Mantra::Transform::ValidationError
        end
      end
    end

    describe "target file does not exist" do
      let(:options) do
        {"source" => "manifest.yml", "target" => "workspace/non-existing-stub.yml", "value" => "domain.com", "scope" => "meta.scope"}
      end

      it "creates target file with directories if they don't exist" do
        expect(File).not_to exist("workspace/non-existing-stub.yml")
        transform.run
        expect(File).to exist("workspace/non-existing-stub.yml")
      end
    end

    describe "sample test" do
      let(:options) do
        { "source" => "manifest.yml",
          "target" => "stub.yml",
          "value"  => "example-domain.com",
          "scope"  => "meta.domain" }
      end
      it "merges values that are already in target file" do
        transform.run
        domain = source.find("jobs[name=cloud_controller].properties.cc.srv_api_uri")
        expect(domain).to eq("(( \"http://api.\" meta.domain ))")
        domain = source.find("jobs[name=uaa].properties.login.url")
        expect(domain).to eq("(( \"http://login.\" meta.domain ))")
      end

      it "(?) it fails if values in target file are different" do

      end

      it "spiff can restore source manifest from manifest resulting source manifest and target file" do

      end
    end

    describe "filter value using 'in' section" do

    end

    describe "test ip address range" do
      let(:options) do
        { "source" => "manifest.yml",
          "target" => "stub.yml",
          "value"  => "domain.com",
          "as"     => {"quad": 3},
          "scope"  => "meta.domain" }
      end
      # it "merges values that are already in target file" do
        
      # end
      # it "(?) it fails if values in target file are different" do

      # end
      # it "spiff can restore source manifest from manifest resulting source manifest and target file" do

      # end
    end

  end
end
