describe Mantra::Manifest do
  subject { Mantra::Manifest }
  let(:manifest_file) { assets_path("integration", "manifest.yml") }
  let(:manifest) { subject.new(manifest_file) }
  

  describe "#fetch" do
    let(:result) { manifest.fetch(scope) }
    describe "jobs[name=c*]" do
      let(:scope) { "jobs[name=c*]" }
      it "selects all jobs that starts on c" do
        expect(result.size).to(eq(2))
        result.each do |element|
          expect(element).to(be_a(Mantra::Manifest::HashElement))
          expect(element.name).to(start_with("c"))
        end
      end
    end
    describe "jobs[name=c*].properties" do
      let(:scope) { "jobs[name=c*].properties" }
      it "selects all jobs that starts on c" do
        expect(result.size).to(eq(2))
        result.each do |element|
          expect(element).to(be_a(Mantra::Manifest::HashElement))
          expect(element.job_name_starts_with_c.content).to be_truthy
        end
      end
    end
    describe "jobs[name=c*].prop*.job_name_starts_with_c" do
      let(:scope) { "jobs[name=c*].prop*.job_name_starts_with_c" }
      it "selects all jobs that starts on c" do
        puts result.map(&:path).join("\n")
        expect(result.size).to(eq(2))
        result.each do |element|
          expect(element).to(be_a(Mantra::Manifest::LeafElement))
          expect(element.content).to be_truthy
        end
      end
    end

  end
end
