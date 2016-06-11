describe Mantra::MergeTool::Spiff do
  subject { Mantra::MergeTool::Spiff }
  let(:merge_tool) { Mantra::MergeTool.create(type: :spiff) }

  describe "#templatize" do
    it "replaces simple value with domain" do
      value  = "domain.com"
      string = "https://sys.domain.com"
      scope  = "meta.domain"
      start  = string.index(value)
      result = merge_tool.templatize(string, scope, start, start + value.size)
      expect(result).to eq("(( \"https://sys.\" #{scope} ))")
    end

    it "works with ip address quad" do
      string = "192.168.0.1"
      scope  = "meta.network.quad"
      value  = "0"
      start  = string.index(value)
      result = merge_tool.templatize(string, scope, start, start + value.size)
      expect(result).to eq("(( \"192.168.\" #{scope} \".1\" ))")
    end

    it "works with ip address range" do
      string = "192.168.0.1-192.168.0.10"
      scope  = "meta.network.quad"
      value  = "0"
      start  = string.index(value)
      result = merge_tool.templatize(string, scope, start, start + value.size)
      expect(result).to eq("(( \"192.168.\" #{scope} \".1-192.168.0.10\" ))")
    end

  end

end