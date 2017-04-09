# encoding: utf-8
# frozen_string_literal: true

require "support/parser_helper"

RSpec.describe Brandish::Parser do
  let(:source) { "test <name>do this</name> <a b=3 /> foo" }
  let(:scanner) { Brandish::Scanner.new(source) }
  subject { Brandish::Parser.new(scanner.call) }
  let(:tree) do
    n(:Root, children: [
      n(:Text, tokens: [t(:TEXT, 1..5, "test"), t(:SPACE, 5..6, " ")]),
      n(:Block, name: t(:TEXT, 8..12, "name"), pairs: [], body: n(:Root, children: [
        n(:Text, tokens: [
          t(:TEXT, 12..14, "do"), t(:SPACE, 14..15, " "),
          t(:TEXT, 15..19, "this")
        ])
      ]), location: l(6..26)),
      n(:Text, tokens: [t(:SPACE, 26..27, " ")]),
      n(:Command, name: t(:TEXT, 28..29, "a"), arguments: [
        n(:Pair, key: t(:TEXT, 30..31, "b"), value: t(:NUMERIC, 32..33, "3"))
      ], location: l(27..36)),
      n(:Text, tokens: [t(:SPACE, 36..37, " "), t(:TEXT, 37..40, "foo")])
    ])
  end

  it "parses correctly" do
    expect(subject.call).to eq tree
  end

  context "with a string pair" do
    let(:source) { 'a <a b="3" /> b' }
    let(:tree) do
      n(:Root, children: [
        n(:Text, tokens: [t(:TEXT, 1..2, "a"), t(:SPACE, 2..3, " ")]),
        n(:Command, name: t(:TEXT, 4..5, "a"), arguments: [
          n(:Pair, key: t(:TEXT, 6..7, "b"), value:
            n(:String, value: "3", location: l(8..11)))
        ], location: l(3..14)),
        n(:Text, tokens: [t(:SPACE, 14..15, " "), t(:TEXT, 15..16, "b")])
      ])
    end

    it "parses" do
      expect(subject.call).to eq tree
    end
  end

  context "with an invalid input" do
    context "for a block item" do
      let(:source) { "test <this>" }

      it "fails" do
        expect { subject.call }.to raise_error(Yoga::ParseError)
      end
    end

    context "for a command" do
      let(:source) { "test <a a />" }

      it "fails" do
        expect { subject.call }.to raise_error(Yoga::ParseError)
      end
    end

    context "for a mismatched block tag" do
      let(:source) { "a <b>c</d> e" }

      it "fails" do
        expect { subject.call }.to raise_error(Brandish::ParseError)
      end
    end
  end
end
