#!/usr/bin/env ruby -w
# test_cli.rb: verify AlwaysBeContributing::CLI works as designed

require 'pathname'

# add lib to loadpath
lib_path = Pathname.new(__FILE__).join('../../lib').expand_path
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include? lib_path

require 'minitest/autorun'
require 'minitest/benchmark'
require 'mocha/setup'

require 'always_be_contributing/org'

class TestOrg < Minitest::Test
  def setup
    @org = AlwaysBeContributing::Org.new('foo')
  end

  def test_name
    assert_equal 'foo', @org.name
  end

  def test_empty_members
    Octokit.expects(:org_members).returns([])

    members = @org.members

    assert_equal [], members
  end

  def test_members
    org_members = [stub(login: 'bob'), stub(login: 'alice')]
    Octokit.expects(:org_members).returns(org_members)

    members = @org.members

    expected = [
      AlwaysBeContributing::User.new('bob'),
      AlwaysBeContributing::User.new('alice'),
    ]
    assert_equal expected, members
  end

  def test_empty_sorted_members
    Octokit.expects(:org_members).returns([])

    sorted_members = @org.sorted_members(Date.today)

    assert_equal [], sorted_members
  end

  # :reek:LongMethod :reek:Duplication: { max_calls: 2 }
  def test_sorted_members
    Octokit.expects(:org_members).
      returns([stub(login: 'bob'), stub(login: 'alice')])
    bob = stub(name: 'bob', contribution_count_since: 3)
    alice = stub(name: 'alice', contribution_count_since: 4)
    AlwaysBeContributing::User.expects(:new).with('bob').returns(bob)
    AlwaysBeContributing::User.expects(:new).with('alice').returns(alice)

    sorted_members = @org.sorted_members(Date.today)

    assert_equal [alice, bob], sorted_members
  end
end
