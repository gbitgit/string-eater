module StringEater
  autoload :Token, 'token'
  autoload :RubyTokenizer, 'ruby-tokenizer'
  autoload :RubyTokenizerEachCHar, 'ruby-tokenizer-each-char'

  class Tokenizer < RubyTokenizer; end
end
