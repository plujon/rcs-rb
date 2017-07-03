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

  it "should create a comma-v file" do
    hi = Rcs::File.create("#{t}/hi")
    assert File.exist?("#{t}/hi,v")
  end

  it "should create a comma-v file" do
    hi = Rcs::File.obtain("#{t}/hi")
    assert File.exist?("#{t}/hi,v")
    hi = Rcs::File.obtain("#{t}/hi")
    assert hi
  end

  it "should create a comma-v file in the RCS directory" do
    Dir.mkdir("#{t}/RCS") unless File.exist? "#{t}/RCS"
    hi = Rcs::File.create("#{t}/hi")
    assert File.exist?("#{t}/RCS/hi,v")
    assert !File.exist?("#{t}/hi,v")
  end

  it "should create a comma-v file" do
    hi = Rcs::File.create("#{t}/hi,v")
    assert File.exist?("#{t}/hi,v")
  end

  it "should create a revision file" do
    Dir.mkdir("#{t}/RCS") unless File.exist? "#{t}/RCS"
    hi = Rcs::File.create("#{t}/RCS/hi,v")
    assert File.exist?("#{t}/RCS/hi,v")
    assert File.exist?("#{t}/hi")
  end

  it "should create a new revision" do
    hi = Rcs::File.create("#{t}/hi")
    hi.revise("yo")
    revision = hi.revision
    assert_equal "yo", revision.content
    assert_equal "1.2", revision.number.to_s
    assert File.exist?("#{t}/hi")
  end
end
