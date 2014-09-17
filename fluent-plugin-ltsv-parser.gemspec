# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-ltsv-parser"
  gem.version       = "0.0.4"
  gem.authors       = ["anarcher"]
  gem.email         = ["anarcher@gmail.com"]
  gem.description   = %q{fluentd plugin to ltsv parse single field, or to combine log structure into single field}
  gem.summary       = %q{plugin to parse/combine fluentd log messages}
  gem.homepage      = "https://github.com/anarcher/fluent-plugin-ltsv-parser"
  gem.license       = "APLv2"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_runtime_dependency "fluentd"
end
