describe Mantra::Helpers::ObjectWithType do
  subject { Mantra::Helpers::ObjectWithType }
  let(:superclass) do
    Class.new do
      include Mantra::Helpers::ObjectWithType
    end
  end
  let(:inheritor) do
    Class.new(superclass) do
      type(:test)
    end
  end
  let(:object) do
  	superclass.create(type: :test)
  end

  it "saves all subclasses" do
    expect{ inheritor }.not_to raise_error(Exception)
    expect(superclass.subclasses).not_to be_empty
  end

  it "creates objects by type" do
    expect{ inheritor }.not_to raise_error(Exception)
    expect(superclass.subclasses.map { |c| c.type }).to eq([:test])
    expect{ object }.not_to raise_error(Exception)
    expect(object.type).to eq :test
  end

end