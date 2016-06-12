describe Mantra::Transform::TemplatizeIpAddress do
  # subject { Mantra::Transforms::TemplatizeValue }
  let(:transform) { Mantra::Transform.create(options.merge(type: type)) }
  let(:type)      { :"templatize-ip-address" }
  let(:source)    { Mantra::Manifest.new(options["source"]) }
  let(:target)    { Mantra::Manifest.new(options["target"]) }
  let(:options) do
    {"source" => "manifest.yml", "target" => "stub.yml", "quads" => [{ "number" => 3, "scope" => "meta.quad" }]}
  end

  describe "#run" do

    before(:each) do
      tmpdir = Dir.mktmpdir("mantra-tests")
      FileUtils.cp(assets_path("transforms", "manifest.yml"), tmpdir)
      FileUtils.cp(assets_path("transforms", "stub.yml"), tmpdir)
      Dir.chdir(tmpdir)
    end
    describe "#tampletize" do
      it "works" do
        Sc = Mantra::Transform::TemplatizeIpAddress::Scope
        result = transform.tampletize(["192.168.", Sc.new("meta.net"), ".1", "-", "192.168.", Sc.new("meta.net"), ".10"])
        expect(result.join(" ")).to eq("\"192.168.\" meta.net \".1-192.168.\" meta.net \".10\"")
      end
    end

    # describe "validations" do
    #   describe "error on source manifest doesn't exist" do
    #     let(:options) do
    #       {"source" => "non-existing-manifest.yml", "target" => "stub.yml", "quad" => { "number" => 3 }}
    #     end
    #     it "raises error that source manifest file does not exists" do
    #     end
    #   end
    # end

    # describe "sample test" do
    #   let(:options) do
    #     { "source" => "manifest.yml",
    #       "target" => "stub.yml",
    #       "quads" => [{"number" => 3,    "scope"  => "meta.networks.cf.quad"},
    #                   {"range" => "1-2", "scope"  => "meta.networks.prefix"}]}
    #   end
    #   it "merges values that are already in target file" do
    #     transform.run
    #     domain = source.find("jobs[name=cloud_controller].properties.cc.srv_api_uri")
    #     expect(domain).to eq("(( \"http://api.\" meta.domain ))")
    #     domain = source.find("jobs[name=uaa].properties.login.url")
    #     expect(domain).to eq("(( \"http://login.\" meta.domain ))")
    #     expect(target.find(options["scope"])).to eq(options["value"])
    #   end
    # end


  end
end
