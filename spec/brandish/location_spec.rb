# frozen_string_literal: true
RSpec.describe Brandish::Location do
  let(:file) { "some/file.br" }
  let(:line) { 1..2 }
  let(:column) { 3..10 }
  subject { described_class.new(file, line, column) }

  context "when equating" do
    let(:other) { described_class.new(file, line, column) }
    it "equals itself" do
      expect(subject).to eq subject
    end

    it "equals a similar object" do
      expect(subject).to eq other
    end

    it "it doesn't equal a non-location" do
      expect(subject).to_not eq nil
    end
  end

  context "when unioning" do
    let(:other_file) { file }
    let(:other_line) { 3..4 }
    let(:other_column) { 2..5 }
    let(:other) { described_class.new(other_file, other_line, other_column) }
    let(:union) { subject.union(other) }

    context "with a mismatched file" do
      let(:other_file) { "some/test.br" }

      it "fails" do
        expect { union }.to raise_error(::ArgumentError)
      end
    end

    context "with an invalid instance" do
      let(:other) { nil }

      it "fails" do
        expect { union }.to raise_error(::ArgumentError)
      end
    end

    it "unions correctly" do
      expect(union.line).to eq 1..4
      expect(union.column).to eq 2..10
      expect(union.file).to eq file
    end
  end

  context "with single line" do
    let(:line) { 1..1 }
    it "outputs correctly" do
      expect(subject.to_s).to eq "#{file}:1.3-10"
    end
  end

  context "with an invalid line" do
    let(:line) { "1" }
    it "fails" do
      expect { subject.to_s }.to raise_error(::ArgumentError)
    end
  end

  it "initializes correctly" do
    expect(subject.file).to be file
    expect(subject.line).to be line
    expect(subject.column).to be column
    expect(subject).to be_frozen
  end

  it "outputs correctly" do
    expect(subject.to_s).to eq "#{file}:1-2.3-10"
  end
end
