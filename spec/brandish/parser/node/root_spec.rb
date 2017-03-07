# encoding: utf-8
# frozen_string_literal: true

RSpec.describe Brandish::Parser::Node::Root do
  let(:data) { { children: [n(:Text, tokens: [t(:TEXT, 0..3, "test")])] } }
  subject { described_class.new(data) }

  context "#==" do
    let(:equiv) { described_class.new(data) }
    let(:different_data) { { children: [] } }
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

  context "#update_children" do
    let(:children) { [n(:Text, tokens: [t(:TEXT, 0..4, "what")])] }
    let(:updated) { subject.update(children: children) }

    it "updates the children" do
      expect(updated.children).to eq children
    end

    it "updates the location" do
      expect(updated.location).to eq l(0..4)
    end

    it "does not modify the original" do
      expect(subject.children).to eq data[:children]
      expect(subject.location).to eq l(0..3)
    end

    context "without an assumed location" do
      let(:data) { super().merge(location: l(0..3)) }

      it "does not update the location" do
        expect(updated.location).to eq l(0..3)
      end
    end
  end

  context "#update_location" do
    let(:location) { l(5..10) }
    let(:updated) { subject.update(location: location) }

    it "updates the location" do
      expect(updated.location).to eq location
    end

    it "does not modify the original" do
      expect(subject.location).to eq l(0..3)
    end

    it "does not update other attributes" do
      expect(updated.children).to eq subject.children
    end
  end
end
