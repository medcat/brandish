# encoding: utf-8
# frozen_string_literal: true
RSpec.describe Brandish::Scanner do
  let(:input) { "<hello world /> test \\{" }
  let(:tokens) do
    [t(:<, 1..2),
      t(:TEXT, 2..7, "hello"),
      t(:SPACE, 7..8, " "),
      t(:TEXT, 8..13, "world"),
      t(:SPACE, 13..14, " "),
      t(:"/", 14..15),
      t(:>, 15..16),
      t(:SPACE, 16..17, " "),
      t(:TEXT, 17..21, "test"),
      t(:SPACE, 21..22, " "),
      t(:ESCAPE, 22..24, "\\{"),
      t(:EOF, 24..24, "")]
  end
  subject { described_class.new(input) }

  it "scans for the tokens" do
    given = subject.call.to_a
    expect(given).to eq tokens
  end

  context "when called multiple times" do
    it "produces the same result" do
      first = subject.call.to_a
      10.times { expect(subject.call.to_a).to eq first }
    end
  end

  context "with a new line" do
    let(:input) { "hello\nworld" }

    it "scans properly" do
      given = subject.call.to_a
      expect(given.last.location.line).to eq 2..2
    end
  end
end
