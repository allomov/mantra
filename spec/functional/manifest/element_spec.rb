describe Mantra::Manifest::Element do
  subject { Mantra::Manifest::Element }

  let(:element1) { subject.create(source1) }
  let(:element2) { subject.create(source2) }

  describe "#merge" do
    describe "arrays with objects that have names" do
      let(:source1) do
        [{ "name" => "element1", "key1" => "value1" },
         { "name" => "element2" }]
      end
      let(:source2) do
        [{ "name" => "element1", "key1" => "value1" },
         { "name" => "element2", "key2" => "value2" },
         { "name" => "element3", "key3" => "value3" }]
      end
      it "merges elements with the same name and add elements that didn't exist" do
        element1.merge(element2)
        expect(element1.to_ruby_object).to eq(source2)
      end
    end

    describe "arrays with objects that have names" do
      let(:source1) do
        [{ "name" => "element1", "key1" => "value1" },
         { "name" => "element2" }]
      end
      let(:source2) do
        [{ "name" => "element1", "key1" => "value1" },
         { "name" => "element2", "key2" => "value2" },
         { "name" => "element3", "key3" => "value3" }]
      end
      it "merges elements with the same name and add elements that didn't exist" do
        element1.merge(element2)
        expect(element1.to_ruby_object).to eq(source2)
      end
    end

    describe "global cloud config test" do
      let(:source1) do
        {"vm_types"=>[{"name"=>"name-1", "network"=>"default", "cloud_properties"=>{"storage_account_name"=>"storage_account_name", "storage_access_key"=>"storage_access_key", "availability_set"=>"availability-consul-lab", "instance_type"=>"Standard_A1"}}, {"name"=>"name-2", "network"=>"default", "cloud_properties"=>{"storage_account_name"=>"storage_account_name", "storage_access_key"=>"storage_access_key", "availability_set"=>"availability-nats-lab", "instance_type"=>"Standard_A2"}}, {"name"=>"name-3", "cloud_properties"=>{"instance_type"=>"Standard_A3"}}, {"name"=>"consul_server-partition", "network"=>"default", "cloud_properties"=>{"storage_account_name"=>"storage_account_name", "storage_access_key"=>"storage_access_key", "availability_set"=>"availability-consul-lab", "instance_type"=>"Standard_D1_v2"}}]}
      end
      let(:source2) do
        {"azs"=>[{"name"=>"z1"}, {"name"=>"z2"}], "vm_types"=>[{"name"=>"name-1", "cloud_properties"=>{"instance_type"=>"Standard_A1"}}, {"name"=>"name-2", "cloud_properties"=>{"instance_type"=>"Standard_A2"}}, {"name"=>"name-4", "cloud_properties"=>{"instance_type"=>"Standard_A4"}}], "networks"=>[{"name"=>"floating", "type"=>"vip"}]}
      end
      it "merges elements with the same name and add elements that didn't exist" do
        expect{ element1.merge(element2) }.not_to raise_error
      end
    end

    describe "conflicts of element types" do
      let(:source1) do
        [{ "name" => "element1", "key1" => "value1" },
         { "name" => "element2" }]
      end
      let(:source2) do
        [{ "name" => "element1", "key1" => {"key1" => "value1"} },
         { "name" => "element3", "key3" => "value3" }]
      end
      it "merges elements with the same name and add elements that didn't exist" do
        expect{ element1.merge(element2) }.to raise_error(Mantra::Manifest::Element::MergeConflictError)
      end
    end

    describe "arrays with same values" do
      let(:source1) do
        ["element1", "element2"]
      end
      let(:source2) do
        ["element2", "element3"]
      end
      it "merges elements with the same name and add elements that didn't exist" do
        element1.merge(element2)
        expect(element1.to_ruby_object).to eq(["element1", "element2", "element3"])
      end
    end

    describe "complex hash" do
      let(:source1) do
        {"vm_types"=>[{"name"=>"name-1", "network"=>"default", "cloud_properties"=>{"storage_account_name"=>"storage_account_name", "storage_access_key"=>"storage_access_key", "availability_set"=>"availability-consul-lab", "instance_type"=>"Standard_A1"}}, {"name"=>"name-2", "network"=>"default", "cloud_properties"=>{"storage_account_name"=>"storage_account_name", "storage_access_key"=>"storage_access_key", "availability_set"=>"availability-nats-lab", "instance_type"=>"Standard_A2"}}, {"name"=>"name-3", "cloud_properties"=>{"instance_type"=>"Standard_A3"}}, {"name"=>"consul_server-partition", "network"=>"default", "cloud_properties"=>{"storage_account_name"=>"storage_account_name", "storage_access_key"=>"storage_access_key", "availability_set"=>"availability-consul-lab", "instance_type"=>"Standard_D1_v2"}}]}
      end
      let(:source2) do
        {"azs"=>[{"name"=>"z1"}, {"name"=>"z2"}], "vm_types"=>[{"name"=>"name-1", "cloud_properties"=>{"instance_type"=>"Standard_A1"}}, {"name"=>"name-2", "cloud_properties"=>{"instance_type"=>"Standard_A2"}}, {"name"=>"name-4", "cloud_properties"=>{"instance_type"=>"Standard_A4"}}], "networks"=>[{"name"=>"floating", "type"=>"vip"}]}
      end
      it "merges elements with the same name and add elements that didn't exist" do
        element1.merge(element2)
        expect(element1.vm_types.size).to eq 5
      end
    end

    describe "deep merge" do
    end
    describe "with collisions" do
    end
  end

  describe "#select" do
    describe "array selector" do
      let(:source1) do
        [{ "name" => "element1", "key1" => {"key1" => "value1"} },
         { "name" => "element2", "key3" => "value3" },
         { "name" => "element3", "key3" => "value3" }]
      end
      it "[] returns all elements" do
        result = element1.select("[]")
        expect(result).to be_a(Array)
        expect(result.size).to eq 3
      end
      it "[].name returns all names" do
        result = element1.select("[].name")
        expect(result).to be_a(Array)
        expect(result.size).to eq 3
        expect(result.map { |r| r.content }).to eq %w(element1 element2 element3)
      end
      it "[name=*1].name returns element1" do
        result = element1.select("[name=*1].name")
        expect(result).to be_a(Array)
        expect(result.size).to eq 1
        expect(result.map { |r| r.content }).to eq %w(element1)
      end
      it "[2].name returns element1" do
        result = element1.select("[1].name")
        expect(result).to be_a(Array)
        expect(result.size).to eq(1)
        expect(result.map { |r| r.content }).to eq %w(element2)
      end
    end

    describe "hash and array" do
      let(:source1) do
        {"networks"=>[{"name"=>"default2"}, {"name"=>"vip", "type"=>"vip", "subnets"=>[{"name"=>"s1"}]}, {"name"=>"default", "subnets"=>[{"range"=>"10.240.192.0/22", "gateway"=>"10.240.192.1", "dns"=>["172.30.54.9"], "static"=>["10.240.192.11-10.240.192.100"], "reserved"=>["10.240.192.0-10.240.192.10", "10.240.192.151-10.240.195.244", "10.240.195.245-10.240.195.254"], "cloud_properties"=>{"virtual_network_name"=>"US4", "subnet_name"=>"US4_CF_Sandbox_CF"}}]}]}
      end
      it "networks[].subnets[] returns an array of all subnets elements" do
        result = element1.select("networks[].subnets[]")
        expect(result).to be_a(Array)
        expect(result.size).to eq 2
      end
    end
  end

  describe "#traverse" do
    let(:source1) do
      [{ "name" => "element1", "key1" => {"key1" => "element2"} },
       ["element3", "element4", "element5"],
       { "name" => "element6", "key3" => ["element7", ["element8", "element9"]] }]
    end
    it "iterates through all leafs" do
      values = []
      element1.traverse do |e|
        values << e.content
      end
      expect(values.size).to eq 9
      expected_values = Set.new((1..9).to_a.map { |i| "element#{i}" })
      actual_values   = Set.new(values)
      expect(actual_values).to eq expected_values
    end
  end

  describe "#hash_element_from_selector" do
    it "creates hash from selector" do
      element = subject.element_with_selector("meta.networks.mysql.squad", 4)
      expect(element.to_ruby_object).to eq({ "meta" => { "networks" => { "mysql" => { "squad" => 4 } } }})
    end
  end

  describe "#path" do
    describe "array path" do
      let(:source1) do
        [{ "name" => "element1", "key1" => {"key1" => "element2"} },
         { "name" => "element3", "key3" => ["element4", ["element5", "element6"]] },
         ["element7", "element8", "element9"]]
      end
      it "root path is empty" do
        expect(element1.path).to be_empty
      end
      it "path of element with name has name selector" do
        expect(element1.content.first.path).to eq("[name=element1]")
      end
      it "path of element without name is []" do
        expect(element1.content.last.path).to eq("[]")
      end
      it "path of element within array and without name is [][]" do
        expect(element1.content.last.content.first.path).to eq("[][]")
      end
    end
    describe "hash path" do
      let(:source1) do
        {"jobs" => [{}], "properties" => {"servers" => ["s1", "s2", "s3"]}}
      end
      it "hash selector for main section" do
        expect(element1.content.values.first.path).to eq("jobs")
      end
      it "hash selector for main section" do
        expect(element1.content.values.first.content.first.path).to eq("jobs[]")
      end
      it "hash selector for second level section" do
        expect(element1.content.values.last.content.values.first.path).to eq("properties.servers")
      end
    end
  end

end
