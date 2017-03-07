# encoding: utf-8
# frozen_string_literal: true

require "support/parser_helper"

RSpec.  describe Brandish::Parser::Node::Block do
  let(:data) do
    { name: t(:TEXT, 0..1, "a"),
      body: n(:Root, children: [
        n(:Text, tokens: [t(:TEXT, 2..3, "b")])
      ]) } # "<a>b</a>"
  end
  subject { described_class.new(data) }

  it "inspects" do
    expect(subject.inspect).to be_a ::String
  end

  context "#==" do
    let(:different_data) { data.merge(name: t(:TEXT, 0..1, "b")) }
    let(:equiv) { described_class.new(data) }
    let(:different) { described_class.new(different_data) }

    it "equals itself" do
      expect(subject).to eq subject
    end

    it "equals an equvalent object" do
      expect(subject).to eq equiv
    end

    it "doesn't equal a different object" do
      expect(subject).to_not eq different
    end
  end

  context "#update_name" do
    let(:name) { "b" }
    let(:updated) { subject.update(name: name) }

    it "updates the name" do
      expect(updated.name).to eq name
    end

    it "does not modify the original" do
      updated
      expect(subject.name).to eq data[:name].value
    end

    it "does not update other attributes" do
      expect(updated.body).to eq subject.body
      expect(updated.location).to eq subject.location
    end
  end

  context "#update_body" do
    let(:body) { n(:Root, children: []) }
    let(:updated) { subject.update(body: body) }

    it "updates the body" do
      expect(updated.body).to eq body
    end

    it "does not modify the original" do
      updated
      expect(subject.body).to eq data[:body]
    end

    it "does not update other attributes" do
      expect(updated.name).to eq subject.name
      expect(updated.location).to eq subject.location
    end
  end

  context "#update_location" do
    let(:location) { l(3..3) }
    let(:updated) { subject.update(location: location) }

    it "updates the location" do
      expect(updated.location).to eq location
    end

    it "does not modify the original" do
      updated
      expect(subject.location).to eq l(0..3)
    end

    it "does not update other attributes" do
      expect(updated.name).to eq subject.name
      expect(updated.body).to eq subject.body
    end
  end
end
