require_relative 'spec_helper'

require 'rcs'

describe Rcs do
  it "should be 1.0" do
    assert_equal "1.0", Rcs::Number.new("1.0").to_s
  end
  it "should be 1.1" do
    assert_equal "1.1", Rcs::Number.new("1.0").next.to_s
  end
  it "should be 1.0.0.0" do
    assert_equal "1.0.0.0", Rcs::Number.new("1.0.0.0").to_s
  end
  it "should be 1.0.0.1" do
    assert_equal "1.0.0.1", Rcs::Number.new("1.0.0.0").next.to_s
  end
  it "should be 1.2" do
    assert_equal "1.2", Rcs::Number.new("1.3").prev.to_s
  end
  it "should be 1.0.0.2" do
    assert_equal "1.0.0.2", Rcs::Number.new("1.0.0.3").prev.to_s
  end
end
