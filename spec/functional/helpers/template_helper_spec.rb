describe Mantra::Helpers::ObjectWithType do
  subject { IpAddressTemplate }
  let(:ip_address_template_class) { IpAddressTemplate }
  # let(:scope_class) { IpAddressTemplate }
  # let(:value_class) { IpAddressTemplate }
  let(:ip_address_template) { ip_address_template_class.new(ip_address) }
  let(:ip_address) { "192.168.0.1" }

  it "creates objects by type" do
    ip_address_template.replace_with_scope(0..1, "meta.scope")
    expect(ip_address_template.parts.size).to eq(5)
    expect(ip_address_template.parts[0].is_scope?).to be_truthy
    expect(ip_address_template.parts[1]).to eq(".")
    expect(ip_address_template.parts[2]).to eq("0")
    expect(ip_address_template.parts[3]).to eq(".")
    expect(ip_address_template.parts[4]).to eq("1")
  end

end