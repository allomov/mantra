describe Mantra::Transform::TemplatizeIpAddress::QuadSplitter do
  subject { Mantra::Transform::TemplatizeIpAddress::QuadSplitter }
  let(:quad) { subject.new(value, quads) }
  let(:value)   { "192.168.0.1" }
  describe "number option" do
    let(:quads) { [{"number" => 3, "scope" => "meta.quad"}] }
    it "extracts value" do
      result = quad.parts(templatize: true).join(" ")
      expect(result).to eq("\"192.168.\" meta.quad \".1\"")
    end
  end

  describe "extract quad by range" do
    let(:quads) { [{"range" => "1-3", "scope" => "meta.range.quad"}] }
    it "extracts value" do
      result = quad.parts(templatize: true).join(" ")
      expect(result).to eq("meta.range.quad \".1\"")
      expect(quad.values["meta.range.quad"]).to eq("192.168.0")
    end
  end

  describe "extract quad by range and number" do
    let(:quads) {[
      {"number" => 3,     "scope" => "meta.quad"},
      {"range"  => "1-2", "scope" => "meta.range.quad"},
    ]}
    it "extracts value" do
      result = quad.parts(templatize: true).join(" ")
      expect(result).to eq("meta.range.quad \".\" meta.quad \".1\"")
      expect(quad.values["meta.quad"]).to eq("0")
      expect(quad.values["meta.range.quad"]).to eq("192.168")
    end
  end

  describe "extract quad by range and number" do
    let(:quads) {[
      {"number" => 3, "scope" => "meta.quad3"},
      {"number" => 1, "scope" => "meta.quad1"},
    ]}
    it "extracts value" do
      result = quad.parts(templatize: true).join(" ")
      expect(result).to eq("meta.quad1 \".168.\" meta.quad3 \".1\"")
      expect(quad.values["meta.quad3"]).to eq("0")
      expect(quad.values["meta.quad1"]).to eq("192")
    end
  end

  describe "extract quad by range" do
    let(:quads) { [{"range" => "1-4", "scope" => "meta.range.quad"}] }
    it "extracts value" do
      result = quad.parts(templatize: true).join(" ")
      expect(result).to eq("meta.range.quad")
      expect(quad.values["meta.range.quad"]).to eq(value)
    end
  end


end