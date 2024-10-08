# Lock::Gemfile

![GitHub-Mark-Light](logo-darkmode.svg#gh-dark-mode-only)![GitHub-Mark-Dark](logo.svg#gh-light-mode-only)


Lock::Gemfile is a Ruby library that provides functionality to update a Gemfile with locked versions - typically, from a corresponding Gemfile.lock file, but you can also provide arbitrary versions as well. 

## Installation

Install using RubyGems:

```
$ gem install lock-gemfile
```

Alternatively, if you intend to use this as a library, you can add this to your Gemfile:

```
$ bundle add lock-gemfile
```

## Usage

### Command-line Interface

Lock::Gemfile provides a command-line interface (CLI) through the `bin/lock-gemfile` script. You can run the script with the following command:

```
$ lock-gemfile update GEMFILE [options]
```

Replace `GEMFILE` with the path to your Gemfile.

#### Options

- `-w`, `--[no-]write`: Write the updated Gemfile back to disk (default: `false`).
- `-p`, `--[no-]pessimistic`: Use pessimistic version constraints (`~>`) (default: `true`).

#### Examples

Update a Gemfile and print the result to the console:

```
$ lock-gemfile update Gemfile
```

Update a Gemfile and write the changes back to the file:

```
$ lock-gemfile update Gemfile --write
```

Update a Gemfile using exact version constraints:

```
$ lock-gemfile update Gemfile --no-pessimistic
```

### Library API

You can also use Lock::Gemfile as a library in your own Ruby code.

```ruby
require 'lock/gemfile'

# Read the content of the Gemfile
gemfile_content = File.read('Gemfile')

# Parse the corresponding Gemfile.lock using Bundler's LockfileParser
lockfile = Bundler::LockfileParser.new(Bundler.read_file('Gemfile.lock'))

# Create a hash to store the desired versions of each gem
desired_versions = {}
lockfile.specs.each do |spec|
  desired_versions[spec.name] = spec.version
end

# Create a buffer to hold the Gemfile content
buffer = Parser::Source::Buffer.new('(gemfile)')
buffer.source = gemfile_content

# Create a new Ruby parser
parser = Parser::CurrentRuby.new
# Parse the Gemfile content into an Abstract Syntax Tree (AST)
ast = parser.parse(buffer)

# Create a new instance of the Lock::Gemfile::Rewriter
rewriter = Lock::Gemfile::Rewriter.new
# Set the desired versions from the lockfile
rewriter.lockfile = desired_versions
# Set the pessimistic option
rewriter.pessimistic = true

# Rewrite the Gemfile AST with the locked versions
transformed_code = rewriter.rewrite(buffer, ast)

# Print the transformed Gemfile content
puts transformed_code
```

## How It Works

Lock::Gemfile uses the following steps to update a Gemfile with locked versions:

1. Read the content of the specified Gemfile.
2. Parse the corresponding Gemfile.lock using Bundler's LockfileParser.
3. Create a hash to store the desired versions of each gem based on the lockfile.
4. Create a buffer to hold the Gemfile content and parse it into an AST using the Parser gem.
5. Create an instance of the Lock::Gemfile::Rewriter and set the desired versions and pessimistic option.
6. Rewrite the Gemfile AST with the locked versions using the rewriter.
7. Transform the modified AST back into source code.
8. Print the transformed Gemfile content to the console or write it back to the file, depending on the options.

The core of the library is the Lock::Gemfile::Rewriter class, which is a subclass of Parser::TreeRewriter. It traverses the AST and looks for `gem` method calls. For each `gem` call found, it checks if a version specifier is already present. If not, it retrieves the locked version from the provided lockfile hash and inserts a version specifier string after the gem name. The version specifier can be either pessimistic or exact, depending on the value of the `pessimistic` attribute.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Commercial Support

Commercial support for lock-gemfile and related tools is available from Durable Programming, LLC. You can contact us at [durableprogramming.com](https://www.durableprogramming.com).

![Durable Programming, LLC Logo](https://durableprogramming.com/images/logo.png)

