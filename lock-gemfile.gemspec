# frozen_string_literal: true

require_relative "lib/lock/gemfile/version"

Gem::Specification.new do |spec|
  spec.name = "lock-gemfile"
  spec.version = Lock::Gemfile::VERSION
  spec.authors = ["Durable Programming Team"]
  spec.email = ["djberube@durableprogramming.com"]

  spec.summary = "A tool to update Gemfile with locked versions"
  spec.description = "This gem provides a command-line tool to update a Gemfile with locked versions from the corresponding Gemfile.lock file."
  spec.homepage = "https://github.com/durableprogramming/lock-gemfile"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/durableprogramming/lock-gemfile"
  spec.metadata["changelog_uri"] = "https://github.com/durableprogramming/lock-gemfile/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end

  spec.bindir = "bin"
  spec.executables = ["lock-gemfile"]
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler", ">= 1.0"
  spec.add_dependency "parser", ">= 3.0"
  spec.add_dependency "thor", ">= 1.0"
end
