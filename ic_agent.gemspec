# frozen_string_literal: true

require_relative 'lib/ic_agent/version'

Gem::Specification.new do |spec|
  spec.name = 'ic_agent'
  spec.version = IcAgent::VERSION
  spec.authors = ['Terry.Tu']
  spec.email = ['tuminfei1981@gmail.com']

  spec.summary = 'ICP Agent'
  spec.description = 'ICP Agent.'
  spec.homepage = 'https://github.com/tuminfei/ic_agent'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage
  spec.metadata['documentation_uri'] = 'https://tuminfei.github.io/ic_agent.github.com/'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'base32', '~> 0.3.4'
  spec.add_dependency 'bitcoin-ruby', '~> 0.0.20'
  spec.add_dependency 'bls12-381', '~> 0.3.0'
  spec.add_dependency 'cbor', '~> 0.5.9.6'
  spec.add_dependency 'ctf-party', '~> 2.3'
  spec.add_dependency 'ecdsa', '~> 1.2'
  spec.add_dependency 'ed25519', '~> 1.3'
  spec.add_dependency 'faraday', '~> 2.7'
  spec.add_dependency 'leb128', '~> 1.0'
  spec.add_dependency 'rbsecp256k1', '~> 6.0'
  spec.add_dependency 'ruby-enum', '~> 0.9.0'
  spec.add_dependency 'rubytree', '~> 2.0'
  spec.add_dependency 'treetop', '~> 1.6'

  spec.add_development_dependency 'byebug', '~> 11.1'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec', '~> 3.2'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
