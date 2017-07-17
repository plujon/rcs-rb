require_relative 'spec_helper'

require 'rcs'

describe Rcs do
  def t
    '/tmp/rcs'
  end

  before do
    Dir.mkdir t
  end

  after do
    FileUtils.rm_rf t
  end

  it "should raise an error" do
    rcs_file = Rcs::File.create(t + "/hi")
    File.unlink rcs_file.path
    begin
      rcs_file.revise("abc")
      assert false
    rescue Rcs::FailedCommand => e
      assert true
    end
  end
end
