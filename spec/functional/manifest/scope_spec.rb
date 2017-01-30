describe Mantra::Manifest::Scope do
  subject { Mantra::Manifest::Scope }
  let(:parse) { subject.new() }


  describe "##split_selector" do

    describe "HASH_SELECTOR_REGEXP" do
      let (:regexp) { subject::HASH_SELECTOR_REGEXP }
      it "jobs" do
        head_selector, tail_selector = subject.split_selector("jobs", regexp)
        expect(head_selector).to eq("jobs")
        expect(tail_selector).to be_empty
      end
      it "jobs[]" do
        head_selector, tail_selector = subject.split_selector("jobs[]", regexp)
        expect(head_selector).to eq("jobs")
        expect(tail_selector).to eq("[]")
      end
      it "jobs[name=concourse]" do
        head_selector, tail_selector = subject.split_selector("jobs[name=concourse]", regexp)
        expect(head_selector).to eq("jobs")
        expect(tail_selector).to eq("[name=concourse]")
      end
      it "jobs[name=concourse].properties" do
        head_selector, tail_selector = subject.split_selector("jobs[name=concourse].properties", regexp)
        expect(head_selector).to eq("jobs")
        expect(tail_selector).to eq("[name=concourse].properties")
      end
      it "properties.cf.password" do
        head_selector, tail_selector = subject.split_selector("properties.cf.password", regexp)
        expect(head_selector).to eq("properties")
        expect(tail_selector).to eq("cf.password")
      end
      it "raises error" do
        expect { subject.split_selector("[name=aria-stark].name", regexp) }.to raise_error(subject::ScopeParseError)
      end
    end

    describe "ARRAY_SELECTOR_REGEXP" do
      let (:regexp) { subject::ARRAY_SELECTOR_REGEXP }
      it "[]" do
        head_selector, tail_selector = subject.split_selector("[]", regexp)
        expect(head_selector).to be_empty
        expect(tail_selector).to be_empty
      end
      it "[].properties" do
        head_selector, tail_selector = subject.split_selector("[].properties", regexp)
        expect(head_selector).to be_empty
        expect(tail_selector).to eq("properties")
      end
      it "[name=conco*rse]" do
        head_selector, tail_selector = subject.split_selector("[name=conco*rse]", regexp)
        expect(head_selector).to eq("name=conco*rse")
        expect(tail_selector).to be_empty
      end
      it "[name=conco*rse].networks[].cloud_properties" do
        head_selector, tail_selector = subject.split_selector("[name=conco*rse].networks[].cloud_properties", regexp)
        expect(head_selector).to eq("name=conco*rse")
        expect(tail_selector).to eq("networks[].cloud_properties")
      end

      it "raises error" do
        expect { subject.split_selector("networks[].cloud_properties", regexp) }.to raise_error(subject::ScopeParseError)
      end

    end
  end

  describe "##parse_selector" do
    it "parses hash" do
      parsed_scope = subject.parse_selector("starks[name=aria-stark].name")
      expect(parsed_scope.to_a.map { |s| s.type }).to eq(%i(hash array hash empty))
    end

    it "parses array" do
      parsed_scope = subject.parse_selector("[name=aria-stark].name")
      expect(parsed_scope.to_a.map { |s| s.type }).to eq(%i(array hash empty))
      expect(parsed_scope.scope).to eq("name=aria-stark")
    end

    it "parses nested hashes" do
      parsed_scope = subject.parse_selector("starks.aria.name")
      expect(parsed_scope.to_a.map { |s| s.type }).to eq(%i(hash hash hash empty))
      expect(parsed_scope.scope).to eq("starks")
    end

    it "parses simple hash" do
      parsed_scope = subject.parse_selector("jobs")
      expect(parsed_scope.to_a.map { |s| s.type }).to eq(%i(hash empty))
      expect(parsed_scope.scope).to eq("jobs")
    end

    it "parses simple hash with simple array" do
      parsed_scope = subject.parse_selector("jobs[]")
      expect(parsed_scope.to_a.map { |s| s.type }).to eq(%i(hash array empty))
    end

    it "parses nested arrays" do
      parsed_scope = subject.parse_selector("[name=st*rks][name=aria].name")
      expect(parsed_scope.to_a.map { |s| s.type }).to eq(%i(array array hash empty))
      expect(parsed_scope.scope).to eq("name=st*rks")
    end
  end

  describe "#has_same_type?" do
    let(:array_element) { Mantra::Manifest::Element.create([:a, :b, :c]).child }
    let(:hash_element) { Mantra::Manifest::Element.create({a: :a, b: :b}).child }
    describe "with array scope" do
      let(:scope) { subject.parse("[]") }
      it "returns true for array" do
        expect(scope.has_same_type?(array_element)).to be_truthy
      end
      it "returns false for hash" do
        expect(scope.has_same_type?(hash_element)).to be_falsey
      end
    end

    describe "with hash scope" do
      let(:scope) { subject.parse("jobs[]") }
      it "returns true for array" do
        expect(scope.has_same_type?(array_element)).to be_falsey
      end
      it "returns false for hash" do
        expect(scope.has_same_type?(hash_element)).to be_truthy
      end
    end

    describe "with empty scope" do
      let(:scope) { subject.parse("") }
      it "can create empty scope" do
        expect(scope.type).to eq(:empty)
      end
      it "returns true for array" do
        expect(scope.has_same_type?(array_element)).to be_truthy
      end
      it "returns true for hash" do
        expect(scope.has_same_type?(hash_element)).to be_truthy
      end
    end
  end

  describe "#filter" do
    let(:array) { [{"name" => "john", "properties" => {"knows" => "nothing"}},
                   {"key" => "value"},
                   hash ] }
    let(:hash)  { {"name" => "joffrey", "dead" => true, "body" => { "stomach" => "poison" }, 
                   "lessons_learned" => [ "don't be evil", "karma works", "teens with too much power run amok" ]} }

    let(:array_element) { Mantra::Manifest::Element.create(array).child }
    let(:hash_element) { Mantra::Manifest::Element.create(hash).child }
    let(:root_hash_element) { Mantra::Manifest::Element.create(hash) }

    describe "with array scope" do
      describe "[]" do
        let(:scope) { subject.parse("[]") }
        it "for array" do
          # raise scope.inspect
          result = scope.filter(array_element)
          expect(result).to be_an(Array)
          expect(result.size).to eq(1)
          expect(result.first.map(&:to_ruby_object)).to eq(array)
        end
        it "for hash" do
          result = scope.filter(hash_element)
          expect(result).to be_empty
        end
        it "for root" do
          result = scope.filter(root_hash_element)
          expect(result).to be_empty
        end
      end
      describe "[name=john]" do
        let(:scope) { subject.parse("[name=john]") }
        it "for array" do
          result = scope.filter(array_element)
          expect(result).to be_a(Array)
          expect(result.size).to eq(1)
          expect(result.map(&:to_ruby_object).first).to eq(array.first)
        end
      end
      describe "[name=jo*]" do
        let(:scope) { subject.parse("[name=jo*]") }
        it "for array" do
          result = scope.filter(array_element)
          expect(result).to be_a(Array)
          expect(result.size).to eq(2)
          expect(result.map(&:to_ruby_object).map { |h| h["name"] }).to eq(%w(john joffrey))
        end
      end
      describe "[name=john].properties" do
        let(:scope) { subject.parse("[name=john].properties") }
        it "for array" do
          result = scope.filter(array_element)
          expect(result).to be_a(Array)
          expect(result.map(&:to_ruby_object).first).to eq(array.first["properties"])
        end
      end
      describe "[name=jo*].properties" do
        let(:scope) { subject.parse("[name=jo*].properties") }
        it "for array" do
          result = scope.filter(array_element)
          expect(result).to be_a(Array)
          expect(result.size).to eq(1)
          expect(result.map(&:to_ruby_object).first).to eq(array.first["properties"])
        end
      end
      describe "[::last]" do
        let(:scope) { subject.parse("[::last]") }
        it "for array" do
          result = scope.filter(array_element)          
          expect(result).to be_a(Array)
          expect(result.map(&:to_ruby_object).first).to eq(array.last)
        end
      end
      describe "[::last][]" do
        let(:scope) { subject.parse("[::last][]") }
        it "for nested arrays" do
          result = scope.filter(array_element)          
          expect(result).to be_empty
        end
      end
    end

    describe "with hash scope" do
      describe "b*dy" do
        let(:scope) { subject.parse("b*dy") }
        it "for array" do
          result = scope.filter(hash_element)          
          expect(result).to be_a(Array)
          expect(result.size).to eq(1)
          expect(result.map(&:to_ruby_object).first).to eq(hash["body"])
        end
      end
      describe "b*dy.stomach" do
        let(:scope) { subject.parse("b*dy.stomach") }
        it "for array" do
          result = scope.filter(hash_element)          
          expect(result).to be_a(Array)
          expect(result.size).to eq(1)
          expect(result.map(&:to_ruby_object).first).to eq(hash["body"]["stomach"])
        end
      end
      describe "lessons_learned" do
        let(:scope) { subject.parse("lessons_learned") }
        it "for array" do
          result = scope.filter(hash_element)          
          expect(result).to be_a(Array)
          expect(result.size).to eq(1)
          expect(result.first.map(&:to_ruby_object)).to eq(hash["lessons_learned"])
        end
      end
      # describe "lessons_learned[]" do
      #   let(:scope) { subject.parse("lessons_learned[]") }
      #   it "for array" do
      #     result = scope.filter(hash_element)          
      #     expect(result).to be_a(Array)
      #     expect(result.size).to eq(1)
      #     expect(result.map(&:to_ruby_object).first).to eq(hash["body"]["stomach"])
      #   end
      # end

    end

    describe "with empty scope" do
      let(:scope) { subject.parse("") }
      it "for array" do
        result = scope.filter(array_element)
        expect(result).to be_a(Array)
        expect(result.map(&:to_ruby_object).first).to eq(array)
      end
      it "for hash" do
        result = scope.filter(hash_element)
        expect(result).to be_a(Array)
        expect(result.map(&:to_ruby_object).first).to eq(hash)
      end
      it "for root" do
        result = scope.filter(root_hash_element)
        expect(result).to be_a(Array)
        expect(result.map(&:to_ruby_object).first).to eq(hash)
      end
    end

  end

end
