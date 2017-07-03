require_relative 'spec_helper'

require 'rcs'

describe Rcs do
  def t
    '/tmp/rcs'
  end

  def create_file(args = [])
    Rcs::File.create(t + "/hi", args)
  end

  before do
    Dir.mkdir t
  end

  after do
    FileUtils.rm_rf t
  end

  it "should should have content" do
    file = create_file
    revision = file.revise("hello")
    assert_equal revision.content, "hello"
    assert_equal file.revision.content, "hello"
  end

  it "should should be diff-able" do
    file = create_file(["-dJan 1"])
    a = file.revise("hello\n", ["-dJan 1"])
    b = file.revise("world\n", ["-dJan 1"])
    assert_equal \
"--- /tmp/rcs/hi\t2017/01/01 00:00:00\t1.2
+++ /tmp/rcs/hi\t2017/01/01 00:00:00\t1.3
@@ -1 +1 @@
-hello
+world
", a.diff(b).to_s
  end

  it "should should have date" do
    file = create_file(["-dJan 1"])
    revision = file.revise("hello\n", ["-dJan 1"])
    assert_equal Date.parse("2017-01-01"), revision.datetime
  end

  it "should have a change" do
    file = create_file(["-dJan 1"])
    r1 = file.revise("hello\n", ["-dJan 1"])
    r2 = r1.revise("world\n", ["-dJan 1"])
    assert_equal r2.change.content, r1.diff(r2).content
  end
end
