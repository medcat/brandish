# encoding: utf-8
# frozen_string_literal: true

require "support/parser_helper"

RSpec.describe Brandish::Parser::Node do
  let(:data) { { location: l(0..1) } }
  subject { described_class.new(data) }

  context "with an invalid update" do
    it "fails" do
      expect { subject.update(foo: :bar) }.to raise_error(Brandish::NodeError)
    end
  end
end
