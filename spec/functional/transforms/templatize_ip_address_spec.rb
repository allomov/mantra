describe Mantra::Transform::TemplatizeIpAddress do
  let(:type)      { :"templatize-ip-address" }
  let(:transform) { Mantra::Transform.create(options.merge(type: type)) }
  let(:source)    { Mantra::Manifest.new(options["source"]) }
  let(:target)    { Mantra::Manifest.new(options["target"]) }
  # let(:options) do
  #   {
  #     "source" => "manifest.yml",
  #     "target" => "stub.yml",
  #     "quads" => [
  #       { "number" => 3, "scope" => "meta.quad" }
  #     ]
  #   }
  # end

  # let(:options) do
  #   {
  #     "source" => "manifest.yml",
  #     "target" => "stub.yml",
  #     "quads" => [
  #       { "range"  => "1-2", "scope" => "meta.network.prefix" }
  #       { "number" => "3",   "scope" => "meta.quad1", "with_value" => "2" }
  #       { "number" => "3",   "scope" => "meta.quad2", "with_value" => "3" }
  #     ]
  #   }
  # end


  describe "#run" do

    before(:each) do
      tmpdir = Dir.mktmpdir("mantra-tests")
      FileUtils.cp(assets_path("transforms", "manifest.yml"), tmpdir)
      FileUtils.cp(assets_path("transforms", "stub.yml"), tmpdir)
      Dir.chdir(tmpdir)
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

    describe "sample test" do
      let(:options) do
        { "source" => "manifest.yml",
          "target" => "stub.yml",
          "quads" => [{"range" => "1-2", "scope"  => "meta.networks.cf.prefix", "with_value" => "192.168"},
                      {"number" => "3", "scope"  => "meta.networks.cf.quad1", "with_value" => "2"},
                      {"number" => "3", "scope"  => "meta.networks.cf.quad2", "with_value" => "3"}]}
      end

      it "merges values that are already in target file" do
        transform.run

        ip_address_template = source.get("jobs[name=nats].networks[0].static_ips[0]")
        expect(ip_address_template).to eq("(( meta.networks.cf.prefix \".\" meta.networks.cf.quad1 \".11\" ))")

        ip_range_template = source.get("networks[name=default].subnets[0].range")
        expect(ip_range_template).to eq("(( meta.networks.cf.prefix \".\" meta.networks.cf.quad1 \".0/22\" ))")

        ip_range_template = source.get("networks[name=default].subnets[0].reserved[0]")
        expect(ip_range_template).to eq("(( meta.networks.cf.prefix \".\" meta.networks.cf.quad1 \".2-\" meta.networks.cf.prefix \".\" meta.networks.cf.quad2 \".9\" ))")
      end
    end


  end
end
