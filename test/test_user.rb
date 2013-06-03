#!/usr/bin/env ruby -w
# test_cli.rb: verify AlwaysBeContributing::CLI works as designed

require 'pathname'

# add lib to loadpath
lib_path = Pathname.new(__FILE__).join('../../lib').expand_path
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include? lib_path

require 'minitest/autorun'
require 'minitest/benchmark'
require 'mocha/setup'

require 'always_be_contributing/user'

class TestUser < Minitest::Test
  def test_name
    user = AlwaysBeContributing::User.new('bob')
    assert_equal 'bob', user.name
  end

  def test_empty_contributions
    user = AlwaysBeContributing::User.new('bob')
    URI.expects(:parse).returns(stub(read: '[]'))

    assert_equal [], user.contributions
  end

  def test_contributions
    user = AlwaysBeContributing::User.new('bob')
    raw_contributions = '[["2012/06/01",1],["2012/06/02",2],["2012/06/03",3]]'
    URI.expects(:parse).returns(stub(read: raw_contributions))

    expected = [
      AlwaysBeContributing::Contribution.new('2012/06/01', 1),
      AlwaysBeContributing::Contribution.new('2012/06/02', 2),
      AlwaysBeContributing::Contribution.new('2012/06/03', 3),
    ]
    assert_equal expected, user.contributions
  end

  def test_contributions_since
    user = AlwaysBeContributing::User.new('bob')
    raw_contributions = '[["2012/06/01",1],["2012/06/02",2],["2012/06/03",3]]'
    URI.expects(:parse).returns(stub(read: raw_contributions))

    expected = [
      AlwaysBeContributing::Contribution.new('2012/06/02', 2),
      AlwaysBeContributing::Contribution.new('2012/06/03', 3),
    ]
    assert_equal expected, user.contributions_since(Date.parse('2012/06/02'))
  end

  def test_contribution_count_since
    user = AlwaysBeContributing::User.new('bob')
    raw_contributions = '[["2012/06/01",1],["2012/06/02",2],["2012/06/03",3]]'
    URI.expects(:parse).returns(stub(read: raw_contributions))

    assert_equal 5, user.contribution_count_since(Date.parse('2012/06/02'))
  end
end
