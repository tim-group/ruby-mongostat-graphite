require 'rake'

hash    = `git rev-parse --short HEAD`.chomp
v_part  = ENV['BUILD_NUMBER'] || "0.pre.#{hash}"
version = "0.1.#{v_part}"
files   = `git ls-files`.split($/)

Gem::Specification.new do |s|
  s.name          = 'mongostat-graphite'
  s.version       = version
  s.date          = Time.now.strftime("%Y-%m-%d")
  s.summary       = "Mongostat Graphite"
  s.description   = "Log mongostat output to Graphite"
  s.authors       = ["Richard Pearce", "Mehul Shah"]
  s.email         = 'infra@timgroup.com'
  s.homepage      = "https://github.com/youdevise/ruby-mongostat-graphite"
  s.license       = "GNU"
  s.files         = `git ls-files`.split($/)
  s.files         = s.files.grep(%r{^(bin|lib)})
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  %w{graphite}.each { |gem| s.add_dependency gem }
end

