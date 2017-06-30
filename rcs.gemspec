lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rcsb_file'

Gem::Specification.new do |spec|
  spec.name          = "rcsb_file"
  spec.version       = Rcs::VERSION
  spec.author        = "Jon Wilkes"
  spec.email         = "jon@pluckeye.net"
  spec.summary       = %q{wrapper around rcs (Revision Control System)}
  spec.description   = <<-eof
    This gem is a wrapper around the venerable RCS created by Walter F. Tichy.
  eof
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.requirements  = ["rcs"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
end
