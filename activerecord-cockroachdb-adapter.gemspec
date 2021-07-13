# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'particles-activerecord-cockroachdb-adapter'
  spec.version       = '1.0.2'
  spec.licenses      = ['Apache-2.0']
  spec.authors       = ['Cockroach Labs', 'Eric-Christian Koch']
  spec.email         = ['cockroach-db@googlegroups.com', 'eric.koch@sumcumo.com']

  spec.summary       = 'CockroachDB adapter for ActiveRecord.'
  spec.description   = 'Allows the use of CockroachDB as a backend for ActiveRecord and Rails apps.'
  spec.homepage      = 'https://github.com/sumcumo/activerecord-cockroachdb-adapter'

  spec.add_dependency 'activerecord', '~> 6.0'
  spec.add_dependency 'pg', '>= 0.20', '< 2.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://artifactory7.sumcumo.net'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 1.14', '< 2.3'
  spec.add_development_dependency 'rake', '~> 10.0'
end
