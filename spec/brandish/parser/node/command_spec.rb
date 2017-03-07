# encoding: utf-8
# frozen_string_literal: true

RSpec.describe Brandish::Parser::Node::Command do
  let(:data) do
    {
      name: t(:TEXT, 2..6, "test"),
      arguments: [n(:Pair, key: t(:TEXT, 7..10, "foo"),
        value: n(:Text, tokens: [t(:TEXT, 11..14, "bar")]))]
    } # "<@test foo=bar>"
  end

  subject { described_class.new(data) }

  context "with no arguments" do
    let(:data) { super().merge(arguments: nil) }

    it "fails" do
      expect { subject }.to raise_error(::ArgumentError)
    end
  end

  context "#==" do
    let(:different_data) { data.merge(name: t(:TEXT, 2..6, "what")) }
    let(:equiv) { described_class.new(data) }
    let(:different) { described_class.new(different_data) }

    it "equals itself" do
      expect(subject).to eq subject
    end

    it "equals an equivalent object" do
      expect(subject).to eq equiv
    end

    it "doesn't equal a different object" do
      expect(subject).to_not eq different
    end
  end

  context "#update_name" do
    let(:name) { "fake" }
    let(:updated) { subject.update(name: name) }

    it "updates the name" do
      expect(updated.name).to eq name
    end

    it "does not modify the original" do
      expect(subject.name).to eq data[:name].value
    end

    it "does not update other attributes" do
      expect(updated.pairs).to eq subject.pairs
      expect(updated.location).to eq subject.location
    end
  end

  context "#update_pairs" do
    let(:pairs) { { "bar" => "baz" } }
    let(:updated) { subject.update(pairs: pairs) }

    it "updates the pair" do
      expect(updated.pairs).to eq pairs
    end

    it "does not modify the original" do
      expect(subject.pairs).to eq "foo" => "bar"
    end

    it "does not update other attributes" do
      expect(updated.name).to eq subject.name
      expect(updated.location).to eq subject.location
    end
  end

  context "#update_arguments" do
    let(:arguments) do
      [n(:Pair, key: t(:TEXT, 7..10, "bar"),
        value: n(:Text, tokens: [t(:TEXT, 11..14, "baz")]))]
    end
    let(:updated) { subject.update(arguments: arguments) }

    it "updates the pair" do
      expect(updated.pairs).to eq "bar" => "baz"
    end

    it "does not modify the original" do
      expect(subject.pairs).to eq "foo" => "bar"
    end

    it "does not update other attributes" do
      expect(updated.name).to eq subject.name
      expect(updated.location).to eq subject.location
    end
  end

  context "#update_location" do
    let(:location) { l(5..10) }
    let(:updated) { subject.update(location: location) }

    it "updates the location" do
      expect(updated.location).to eq location
    end

    it "does not modify the original" do
      expect(subject.location).to eq l(2..14)
    end

    it "does not update other attributes" do
      expect(updated.name).to eq subject.name
      expect(updated.pairs).to eq subject.pairs
    end
  end
end
