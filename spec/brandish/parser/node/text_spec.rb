# encoding: utf-8
# frozen_string_literal: true

RSpec.describe Brandish::Parser::Node::Text do
  let(:data) { { tokens: [t(:TEXT, 0..3, "test")] } }
  subject { described_class.new(data) }

  context "with invalid data" do
    let(:data) { super().merge(tokens: nil) }

    it "fails" do
      expect { subject }.to raise_error(::ArgumentError)
    end
  end

  context "with an invalid token" do
    let(:data) { { tokens: [t(:"<", 0..1)] } }

    it "fails" do
      expect { subject }.to raise_error(::ArgumentError)
    end
  end

  context "#==" do
    let(:equiv) { described_class.new(data) }
    let(:different_data) { data.merge(tokens: [t(:TEXT, 0..3, "what")]) }
    let(:different) { described_class.new(different_data) }

    it "equals itself" do
      expect(subject).to eq subject
    end

    it "equals an equivalent object" do
      expect(subject).to eq equiv
    end

    it "does not equal a different object" do
      expect(subject).to_not eq different
    end
  end

  context "#update_value" do
    let(:value) { "what" }
    let(:updated) { subject.update(value: value) }

    it "updates the value" do
      expect(updated.value).to eq value
    end

    it "does not update the original" do
      expect(subject.value).to eq "test"
    end

    it "does not update other attributes" do
      expect(updated.location).to eq subject.location
    end
  end

  context "#update_tokens" do
    let(:tokens) { [t(:TEXT, 0..3, "what")] }
    let(:updated) { subject.update(tokens: tokens) }

    it "updates the value" do
      expect(updated.value).to eq "what"
    end

    it "does not update the original" do
      expect(subject.value).to eq "test"
    end

    it "does not update other attributes" do
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
      expect(subject.location).to eq l(0..3)
    end

    it "does not update other attributes" do
      expect(updated.value).to eq subject.value
    end
  end
end
