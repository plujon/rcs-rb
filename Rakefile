require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test"
end

desc "Run tests"
task :default => :test

### Specs

spec = ->(env = {}) {
  args = env.delete(:args).to_s
  env.each { |k,v| ENV[k.to_s] = v.to_s }
  sh "#{FileUtils::RUBY} #{args} spec/all.rb"
  env.each { |k,v| ENV.delete(k.to_s) }
}

desc "Run specs"
task "spec" do
  spec.call
end

desc "Run specs with coverage"
task "spec_cov" do
  spec.call :COVERAGE => 1
end

desc "Run specs with -w, some warnings filtered"
task "spec_w" do
  rubyopt = ENV['RUBYOPT']
  spec.call :args => '-w', :WARNING => 1
end
