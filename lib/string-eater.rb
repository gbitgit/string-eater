module StringEater
  autoload :Token, 'token'
  autoload :RubyTokenizer, 'ruby-tokenizer'
  autoload :RubyTokenizerEachCHar, 'ruby-tokenizer-each-char'

  autoload :VERSION, 'version'

  class Tokenizer < RubyTokenizer; end
end
