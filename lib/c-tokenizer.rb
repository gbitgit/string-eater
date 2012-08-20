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
    @tokens_to_extract_names = tokens.map{|t| t.name}

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

  def tokenize! string, &block
    @string = string
    @extracted_tokens ||= {}
    @extracted_tokens.clear

    tokens.first.breakpoints[0] = 0

    @extracted_tokens = ctokenize!(@string, 
                                   @tokens_to_find_indexes,
                                   @tokens_to_find_strings,
                                   @tokens_to_extract_names)

#   last_token = tokens.last
#   last_token.breakpoints[1] = string.length

#   if last_token.extract?
#     puts "last_token"
#     puts last_token.breakpoints.inspect
#     @extracted_tokens[last_token.name] = string[last_token.breakpoints[0]..last_token.breakpoints[1]]
#   end

    combined_tokens.each do |combiner|
      name = combiner[0]
      from = @tokens[combiner[1]].breakpoints[0]
      to = @tokens[combiner[2]].breakpoints[1]
      @extracted_tokens[name] = string[from...to]
    end

    if block_given?
      yield @extracted_tokens
    end

    # return self for chaining
    self
  end 
end
