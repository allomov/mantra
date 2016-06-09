describe Mantra::Manifest::HashElement do
  subject { Mantra::Manifest::HashElement }

  let(:element1) { subject.create(source1) }
  let(:element2) { subject.create(source2) }

  describe "#has_equal_name?" do
    describe "arrays with objects that have names" do
      let(:source1) do
        {"name"=>"name-3", "cloud_properties"=>{"instance_type"=>"Standard_A3"}}
      end
      let(:source2) do
        {"name"=>"name-4", "cloud_properties"=>{"instance_type"=>"Standard_A4"}}
      end
      it "retruns false if names are different" do
        expect(element1.has_equal_name?(element2)).to be_falsey
      end
    end
  end

end
