# frozen_string_literal: true
RSpec.describe Brandish::Scanner do
  let(:input) { "{:hello world} test \\{" }
  let(:tokens) do
    [t(:"{", 0..1),
      t(:":", 1..2),
      t(:TEXT, 2..7, "hello"),
      t(:SPACE, 7..8, " "),
      t(:TEXT, 8..13, "world"),
      t(:"}", 13..14),
      t(:SPACE, 14..15, " "),
      t(:TEXT, 15..19, "test"),
      t(:SPACE, 19..20, " "),
      t(:ESCAPE, 20..22, "\\{"),
      t(:EOF, 22..22, "")]
  end
  subject { described_class.new(input) }

  it "scans for the tokens" do
    given = subject.call.to_a
    expect(given).to eq tokens
  end

  context "with a new line" do
    let(:input) { "hello\nworld" }

    it "scans properly" do
      given = subject.call.to_a
      expect(given.last.location.line).to eq 2..2
    end
  end

  def t(kind, column, value = kind.to_s, line = 1..1)
    location = Brandish::Location.new("<anon>", line, column)
    Brandish::Scanner::Token.new(kind, value, location)
  end
end
