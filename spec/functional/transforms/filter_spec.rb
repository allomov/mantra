describe Mantra::Transform::Filter do
  let(:type)      { :filter }
  let(:transform) { Mantra::Transform.create(options.merge(type: type, previous_transform: previous_transform)) }
  let(:previous_transform) do
    obj = double()
    allow(obj).to receive(:result) { Mantra::Manifest::Element.create(manifest) }
    obj
  end

  describe "#run" do
    describe "validations" do
      describe "error on sections options field doesn't exist" do
        let(:options) { Hash.new }
        it "raises error when no source specified" do
          expect { transform.run }.to raise_error(Mantra::Transform::ValidationError)
        end
      end
    end

    describe "sample test" do
      let(:options) do
        {"sections" => [ "jobs", "releases", "update"]}
      end

      let(:manifest) do
        YAML.load_file(assets_path("transforms", "manifest.yml"))
      end

      before(:each) {transform.run}

      it "has a right class for result" do
        expect(transform.result).to be_kind_of(Mantra::Manifest::Element)
      end

      it "has a right sections in result" do
        expect(transform.result.content.keys).to eq(options["sections"])
      end
    end
  end
end
