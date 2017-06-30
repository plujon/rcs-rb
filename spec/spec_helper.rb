# Structure copied from jeremyevans code.

require 'rubygems'
$: << File.expand_path(File.join(__FILE__, '../../lib'))

module Rcs
end

if ENV['COVERAGE']
  ENV.delete('COVERAGE')
  require 'coverage'
  require 'simplecov'

  SimpleCov.instance_eval do
    start do
      add_filter "/spec/"
      add_group('Missing'){|src| src.covered_percent < 100}
      add_group('Covered'){|src| src.covered_percent == 100}
    end
  end
end

gem 'minitest'
require 'minitest/autorun'
require 'minitest/hooks/default'

if ENV['WARNING']
  require 'warning'
  Warning.ignore([:missing_ivar, :fixnum])
end

class Minitest::HooksSpec

  attr_reader :foo

  def foo=(foo)
    @foo = foo
  end

  def foo_setup(arg, &block)
    self.foo = arg
  end

  around do |&block|
    super(&block)
  end

  after do
  end
end
