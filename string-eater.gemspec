require File.expand_path('../lib/version', __FILE__)
require 'rake'

Gem::Specification.new do |gem|
  gem.name = "string-eater"
  gem.authors = ["Dan Swain"]
  gem.email = ["dan@simpli.fi"]
  gem.description = "Fast string tokenizer. Nom strings."
  gem.summary = "Fast string tokenizer.  Nom strings."
  gem.homepage = "http://github.com/simplifi/string-eater"

  gem.files = FileList['lib/*.rb', 'lib/**/*.rb/', 'ext/**/*.rb',
                       'ext/**/*.c', 'spec/**/*.rb', 'examples/*.rb',
                       '[A-Z]*'].to_a
  gem.test_files = FileList['spec/**/*.rb'].to_a

  gem.require_paths = ["lib", "ext/string-eater"]

  gem.extensions = ['ext/string-eater/extconf.rb']

  gem.version = StringEater::VERSION::STRING
end
