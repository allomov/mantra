describe Mantra::Manifest::Ext do
  subject { Mantra::Manifest }

  let(:manifest) { subject.new(assets_path("integration/manifest.yml")) }

  describe "#jobs" do
    it "returns array with all jobs from manifest" do
      expect(manifest.jobs.size).to eq(12)
    end
  end

  describe "#properties" do
    it "returns hash element" do
      expect(manifest.properties.class).to eq(Mantra::Manifest::HashElement)
    end

    it "contain properties from global section" do
      expect(manifest.properties.get("nfs_server.address")).to eq("192.168.3.10")
    end

    it "contain properties declared in jobs section" do
      expect(manifest.properties.get("cc.use_nginx")).to eq(true)
    end
  end
end
