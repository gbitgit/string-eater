module StringEater
  autoload :Token, 'token'
  autoload :RubyTokenizer, 'ruby-tokenizer'
  autoload :RubyTokenizerEachCHar, 'ruby-tokenizer-each-char'
  autoload :CTokenizer, 'c-tokenizer'

  autoload :VERSION, 'version'

  class Tokenizer < RubyTokenizer; end
end
