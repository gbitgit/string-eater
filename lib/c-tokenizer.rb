require 'c_tokenizer_ext'

class StringEater::CTokenizer
  def self.tokens
    @tokens ||= []
  end

  def self.combined_tokens
    @combined_tokens ||= []
  end

  def self.add_field name, opts={}
    self.tokens << StringEater::Token::new_field(name, opts)
    define_method(name) {@extracted_tokens[name]}
  end

  def self.look_for tokens
    self.tokens << StringEater::Token::new_separator(tokens)
  end

  def self.combine_fields opts={}
    from_token_index = self.tokens.index{|t| t.name == opts[:from]}
    to_token_index = self.tokens.index{|t| t.name == opts[:to]}
    self.combined_tokens << [opts[:as], from_token_index, to_token_index]
    define_method(opts[:as]) {@extracted_tokens[opts[:as]]}
  end

  def initialize
    refresh_tokens
  end

  def tokens
    @tokens
  end

  def combined_tokens
    @combined_tokens ||= self.class.combined_tokens
  end

  def refresh_tokens
    @tokens = self.class.tokens
    tokens_to_find = tokens.each_with_index.map do |t, i|
      [i, t.string] if t.string
    end.compact

    @tokens_to_find_indexes = tokens_to_find.map{|t| t[0]}
    @tokens_to_find_strings = tokens_to_find.map{|t| t[1]}

    tokens_to_extract = tokens.each_with_index.map do |t, i|
      [i, t.name] if t.extract?
    end.compact

    @tokens_to_extract_indexes = tokens_to_extract.map{|t| t[0]}
    @tokens_to_extract_names = tokens_to_extract.map{|t| t[1]}

    @combined_tokens = nil
  end

  def describe_line
    tokens.inject("") do |desc, t|
      desc << (t.string || t.name.to_s || "xxxxxx")
    end
  end

  def find_breakpoints string
    tokenize!(string) unless @string == string
    tokens.inject([]) do |bp, t|
      bp << t.breakpoints
      bp
    end.flatten.uniq
  end

  def tokenize! string, &block
    @string = string
    @extracted_tokens ||= {}
    @extracted_tokens.clear

    @extracted_tokens = ctokenize!(@string, 
                                   @tokens_to_find_indexes,
                                   @tokens_to_find_strings,
                                   @tokens_to_extract_indexes,
                                   @tokens_to_extract_names)
  end 
end
