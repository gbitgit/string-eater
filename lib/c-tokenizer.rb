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

  def tokens
    @tokens ||= self.class.tokens
  end

  def combined_tokens
    @combined_tokens ||= self.class.combined_tokens
  end

  def refresh_tokens
    @combined_tokens = nil
    @tokens = nil
    tokens
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
  end 
end
