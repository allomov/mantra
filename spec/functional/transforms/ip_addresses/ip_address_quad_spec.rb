describe Mantra::Transform::TemplatizeIpAddress::QuadSplitter do
  subject { Mantra::Transform::TemplatizeIpAddress::QuadSplitter }
  let(:quad) { subject.new(value, options) }
  describe "number option" do
    let(:options) { {number: 3}  }
    let(:value)   { "192.168.0.1" }
    it "extracts value" do
      expect(quad.before).to eq("192.168.")
      expect(quad.value).to eq("0")
      expect(quad.after).to eq(".1")
      expect(quad.start).to eq value.index("0")
      expect(quad.finish).to eq(value.index("0") + 1)
    end
  end

  describe "extract quad by range" do
    let(:options) { {range: "1-3"}  }
    let(:value)   { "192.168.0.1" }
    it "extracts value" do
      expect(quad.before).to eq("")
      expect(quad.value).to eq("192.168.0")
      expect(quad.after).to eq(".1")
      expect(quad.start).to eq 0
      expect(quad.finish).to eq(value.index("0") + 1)
    end
  end

  describe "extract quad by range" do
    let(:options) { {range: "2-3"}  }
    let(:value)   { "192.168.0.1" }
    it "extracts value" do
      expect(quad.before).to eq("192.")
      expect(quad.value).to eq("168.0")
      expect(quad.after).to eq(".1")
      expect(quad.start).to eq value.index("168")
      expect(quad.finish).to eq(value.index("0") + 1)
    end
  end

  describe "extract quad by range" do
    let(:options) { {range: "1-4"}  }
    let(:value)   { "192.168.0.1" }
    it "extracts value" do
      expect(quad.before).to eq("")
      expect(quad.value).to eq(value)
      expect(quad.after).to eq("")
      expect(quad.start).to eq 0
      expect(quad.finish).to eq value.size
    end
  end

end