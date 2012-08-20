require 'c_tokenizer_ext'

class StringEater::CTokenizer
  def self.tokens
    @tokens ||= []
  end

  def self.add_field name, opts={}
    self.tokens << StringEater::Token::new_field(name, opts)
    define_method(name) {@extracted_tokens[name]}
  end

  def self.look_for tokens
    self.tokens << StringEater::Token::new_separator(tokens)
  end

  def initialize
    refresh_tokens
  end

  def tokens
    @tokens
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
    @tokens_to_extract_names = tokens.map{|t| t.name}
  end

  def describe_line
    tokens.inject("") do |desc, t|
      desc << (t.string || t.name.to_s || "xxxxxx")
    end
  end

  def do_extra_parsing
  end

  def tokenize! string, &block
    @string = string
    @extracted_tokens ||= {}
    @extracted_tokens.clear

    tokens.first.breakpoints[0] = 0

    @extracted_tokens = ctokenize!(@string, 
                                   @tokens_to_find_indexes,
                                   @tokens_to_find_strings,
                                   @tokens_to_extract_indexes,
                                   @tokens_to_extract_names)

    # extra parsing hook
    do_extra_parsing

    if block_given?
      yield @extracted_tokens
    end

    # return self for chaining
    self
  end 
  
  private

  def set_token_startpoint ix, startpoint
    @tokens[ix].breakpoints[0] = startpoint
  end

  def get_token_startpoint ix
    @tokens[ix].breakpoints[0]
  end

  def set_token_endpoint ix, endpoint
    @tokens[ix].breakpoints[1] = endpoint
  end

  def extract_token? ix
    @tokens[ix].extract?
  end

end
