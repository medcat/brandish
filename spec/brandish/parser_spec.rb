# encoding: utf-8
# frozen_string_literal: true

require "support/parser_helper"

RSpec.describe Brandish::Parser do
  let(:source) { "test <name>do this</name> <@a b=3> foo" }
  let(:scanner) { Brandish::Scanner.new(source) }
  subject { Brandish::Parser.new(scanner.call) }
  let(:tree) do
    n(:Root, children: [
      n(:Text, tokens: [t(:TEXT, 0..4, "test"), t(:SPACE, 4..5, " ")]),
      n(:Block, name: t(:TEXT, 7..11, "name"), body: n(:Root, children: [
        n(:Text, tokens: [
          t(:TEXT, 11..13, "do"), t(:SPACE, 13..14, " "),
          t(:TEXT, 14..18, "this")
        ])
      ]), location: l(5..25)),
      n(:Text, tokens: [t(:SPACE, 25..26, " ")]),
      n(:Command, name: t(:TEXT, 28..29, "a"), arguments: [
        n(:Pair, key: t(:TEXT, 30..31, "b"), value: t(:NUMERIC, 32..33, "3"))
      ], location: l(26..34)),
      n(:Text, tokens: [t(:SPACE, 34..35, " "), t(:TEXT, 35..38, "foo")])
    ])
  end

  it "parses correctly" do
    expect(subject.call).to eq tree
  end

  context "with a string pair" do
    let(:source) { 'a <@a b="3"> b' }
    let(:tree) do
      n(:Root, children: [
        n(:Text, tokens: [t(:TEXT, 0..1, "a"), t(:SPACE, 1..2, " ")]),
        n(:Command, name: t(:TEXT, 4..5, "a"), arguments: [
          n(:Pair, key: t(:TEXT, 6..7, "b"), value:
            n(:String, value: "3", location: l(8..13)))
        ], location: l(2..12)),
        n(:Text, tokens: [t(:SPACE, 12..13, " "), t(:TEXT, 13..14, "b")])
      ])
    end

    it "parses" do
      expect(subject.call).to eq tree
    end
  end

  context "with an invalid input" do
    context "for a meta item" do
      let(:source) { "test <this thing>" }

      it "fails" do
        expect { subject.call }.to raise_error(Brandish::ParseError)
      end
    end

    context "for a command" do
      let(:source) { "test <@a a>" }

      it "fails" do
        expect { subject.call }.to raise_error(Brandish::ParseError)
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
