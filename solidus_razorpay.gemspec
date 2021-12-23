# frozen_string_literal: true

require_relative 'lib/solidus_razorpay/version'

Gem::Specification.new do |spec|
  spec.name = 'solidus_razorpay'
  spec.version = SolidusRazorpay::VERSION
  spec.authors = ['Piyush Swain']
  spec.email = 'contact@solidus.io'

  spec.summary = 'Solidus extension for using Razorpay Payments in your store'
  spec.homepage = 'https://github.com/nebulab/solidus_razorpay#readme'
  spec.license = 'Apache-2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/nebulab/solidus_razorpay'
  spec.metadata['changelog_uri'] = 'https://github.com/nebulab/solidus_razorpay/blob/master/CHANGELOG.md'

  spec.required_ruby_version = Gem::Requirement.new('~> 2.5')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }

  spec.files = files.grep_v(%r{^(test|spec|features)/})
  spec.test_files = files.grep(%r{^(test|spec|features)/})
  spec.bindir = "exe"
  spec.executables = files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'razorpay', '~> 2.4.1'
  spec.add_dependency 'solidus_core', ['>= 2.0.0', '< 4']
  spec.add_dependency 'solidus_support', '~> 0.5'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'solidus_dev_support', '~> 2.5'
end
