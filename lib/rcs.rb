require 'date'

module Rcs
  VERSION = "0.0.1"

  # foo,v -> File
  # foo -> Revision
  # 1.1 -> Number
  # rcsdiff -r1.1 -r1.2 foo -> Diff

  # ,v
  class File
    def self.create(path, args = [])
      path = self.commav_path(path)
      if ::File.exist? path
        raise "#{path} already exists"
      end
      revision_path = self.revision_path(path)
      if !::File.exist? revision_path
        FileUtils.touch revision_path
      end
      if args.empty?
        args = ''
      else
        args = "'" + args.join("' '") + "'"
      end
      system("rcs ci -l -t-'' #{args} #{revision_path} >/dev/null 2>&1")
      new(path)
    end

    def self.obtain(path, args = [])
      file = new(path)
      file = create(path, args) if !file.exist?
      file
    end

    def self.commav_path(path)
      if path.end_with? ",v"
        return path
      end
      dir = ::File.dirname(path)
      if ::File.exist?(dir + "/RCS")
        dir + "/RCS/" + ::File.basename(path) + ",v"
      else
        path + ",v"
      end
    end

    def self.revision_path(path)
      return path unless path.end_with?(",v")
      path = path.chomp(",v")
      if ::File.dirname(path).end_with? "/RCS"
        ::File.dirname(::File.dirname(path)) + "/" + ::File.basename(path)
      else
        path
      end
    end

    def initialize(path)
      @path = path
    end

    def exist?
      ::File.exist? @path
    end

    def revise(content, args = [])
      path = revision_path
      ::File.open(path, "w") do |f|
        f.write(content)
      end
      if args.empty?
        args = ''
      else
        args = "'" + args.join("' '") + "'"
      end
      `rcs ci -l -m'' #{args} #{path} 2>/dev/null`
      @rlog = nil
      @latest_number = nil
      revision
    end

    def commav_path
      @path
    end

    def revision_path
      self.class.revision_path(@path)
    end

    def path
      @path
    end

    def rlog
      @rlog ||= `rlog -h #{revision_path} 2>/dev/null`
    end

    def latest_number
      return @latest_number if @latest_number
      rlog.split(/\n/).each do |line|
        mtch = line.match(/^head: (\d[.\d]+)/)
        next unless mtch
        @latest_number = Number.new(mtch[1])
      end
      @latest_number
    end

    def revision(n = latest_number)
      Revision.new(self, n)
    end
  end

  class Number
    def initialize(x)
      if x.is_a? Array
        @ary = x
      else
        @ary = x.to_s.split(/\./).map(&:to_i)
      end
    end

    def next
      ary = @ary.dup
      ary[ary.length - 1] += 1
      Number.new(ary)
    end

    def prev
      ary = @ary.dup
      ary[ary.length - 1] -= 1
      return nil if ary.last < 0
      Number.new(ary)
    end

    def to_s
      @ary.join(".")
    end
  end

  class Diff
    def initialize(a, b, args = [])
      @a = a
      @b = b
      if args.empty?
        @args = "-u"
      else
        @args = "'" + args.join("' '") + "'"
      end
    end

    def content
      @content ||= cached? ?
        File.read(path) :
        `rcsdiff -r#{@a.number} -r#{@b.number} #{@args} #{@a.path} 2>/dev/null`
    end

    def cache!
      ::File.open(cache_path, "w").write(content) if !cached?
    end

    def cached?
      ::File.exist?(path)
    end

    def datetime
      @b.datetime
    end

    def path
      @path ||= @a.commav_path + ",diff,#{@a.number},#{@b.number}"
    end

    def to_s
      content
    end
  end

  class Change
    def initialize(revision)
      @revision = revision
    end

    def content
      diff.content
    end

    def datetime
      @revision.datetime
    end

    def diff
      @diff ||= Diff.new(@revision.prev, @revision) if @revision.prev
    end

    def next
      @revision.next && @revision.next.change
    end

    def prev
      @revision.prev && @revision.prev.change
    end
  end

  class Revision
    def initialize(rcsfile, number)
      @rcsfile = rcsfile
      @number = number
    end

    def content
      @content ||= cached? ?
        File.read(cache_path) :
        `rcs co -p#{@number} #{path} 2>/dev/null`
    end

    def cached?
      ::File.exist?(cache_path)
    end

    def cache_path
      @cache_path ||= @rcsfile.commav_path + ",#{@number}"
    end

    def cache!
      ::File.open(cache_path, "w").write(content) if !cached?
    end

    def commav_path
      @rcsfile.commav_path
    end

    def path
      @path ||= @rcsfile.revision_path
    end

    def next
      return nil if is_latest?
      self.class.new(@rcsfile, @number.next)
    end

    def prev
      prev = @number.prev
      return nil if !prev
      self.class.new(@rcsfile, prev)
    end

    def is_latest?
      @rcsfile.latest_number == @number
    end

    def number
      @number
    end

    def change
      if prev
        Change.new(self)
      else
        nil
      end
    end

    def diff(other, args = [])
      Diff.new(self, other, args)
    end

    def revise(content, args = [])
      @rcsfile.revise(content, args)
    end

    def datetime
      return @datetime if @datetime
      rlog.split("\n").each do |line|
        mtch = line.match %r(^date: (\d\d\d\d/\d\d/\d\d \d\d:\d\d:\d\d);)
        next unless mtch
        @datetime = DateTime.parse(mtch[1])
      end
      @datetime
    end

    def rlog
      @rlog ||= `rlog -r#{number} #{path} 2>/dev/null`
    end
  end
end
