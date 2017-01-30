describe Mantra::Manifest do
  subject { Mantra::Manifest }
  let(:manifest) { subject.new(assets_path("transforms", "manifest.yml")) }
  let(:result) { manifest.select(scope) }

  describe "#select" do
    let(:scope) { "jobs[].templates" }
    it "jobs[].templates" do
      expect(result).to be_an(Array)
      expect(result.size).to eq(manifest.jobs.size)
      result.each do |element|
        # puts element.parent.type
        # puts element.to_ruby_object.to_json
        # puts element.type
        expect(element).to be_array
        expect(element.parent).to be_hash
      end
    end
  end

end
