require 'spec_helper'
require 'did_parser'
require 'byebug'

describe IcAgent::Canister do
  before(:all) do
    iden = IcAgent::Identity.new
    client = IcAgent::Client.new
    @agent = IcAgent::Agent.new(iden, client)
    @subnet_key = '308182301d060d2b0601040182dc7c0503010201060c2b0601040182dc7c05030201036100b31b406c9f6648695a88154ae2e4f5fe87883d4ad81c2844c5571b2d91d401cdd40836e763a7c18dccb84629b0d808f7142c3175bc8231dc09bd53637efd6f2568801385ec973d34e6eef9c8c8280a9f4a114163a43a8540941ba367f0c7cb28'
    a = IcAgent::Ast::Parser.new
    @gov_didl = <<~DIDL_DOC
# this is a comment1
service : (Governance) -> {
  update1_node_provider : (UpdateNodeProvider1) -> (Result1) query;
  update2_node_provider : (UpdateNodeProvider2) -> (Result2) query;
  update3_node_provider : (UpdateNodeProvider3) -> (Result3) query;
}
# this is a comment2
    DIDL_DOC
    tree = a.parse(@gov_didl)

    @pp = <<~DOCKFILE
FROM jeremiahishere/sample

MAINTAINER Jeremiah Hemphill <jeremiah@cloudspace.com>

RUN echo 'hello world'
RUN['echo', 'hello world']
    DOCKFILE
  end

  it 'IcAgent::Canister call' do
    # didl = DIDParser::Parser.parse(@gov_didl)
    # byebug
    # puts didl.actor
    #
    Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), '../../lib/ic_agent/ast/', 'did_grammar.treetop')))

    parser = DIDGrammarParser.new

    parsed = parser.parse(@gov_didl)
    byebug
    pp parsed
  end
end



