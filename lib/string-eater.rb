module StringEater

  class Token
    attr_accessor :name, :string, :opts, :breakpoints, :children

    def initialize
      @opts = {}
    end

    def extract?
      @opts[:extract]
    end

    def self.new_field(name, opts)
      t = new
      t.name = name
      t.opts = {:extract => true}.merge(opts)
      t
    end

    def self.new_separator(string)
      t = new
      t.string = string
      t
    end
  end

  class Tokenizer

    def self.tokens
      @tokens ||= []
    end

    def self.combined_tokens
      @combined_tokens ||= []
    end

    def self.add_field name, opts={}
      self.tokens << Token::new_field(name, opts)
      define_method(name) {@extracted_tokens[name]}
    end

    def self.look_for tokens
      self.tokens << Token::new_separator(tokens)
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

    def find_breakpoints(string)
      @literal_tokens ||= tokens.select{|t| t.string}
      @breakpoints ||= Array.new(2*@literal_tokens.size + 2)
      @breakpoints[0] = 0
      @breakpoints[-1] = string.length
      start_point = 0
      @literal_tokens.each_with_index do |t, i|
        @breakpoints[2*i+1],start_point = find_end_of(t, string, start_point)
        @breakpoints[2*i+2] = start_point
      end
      @breakpoints
    end

    def tokenize! string, &block
      @extracted_tokens ||= {}
      @extracted_tokens.clear
      @tokens_to_extract ||= tokens.select{|t| t.extract?}

      find_breakpoints(string)
      last_important_bp = [@breakpoints.length, tokens.size].min
      (0...last_important_bp).each do |i|
        tokens[i].breakpoints = [@breakpoints[i], @breakpoints[i+1]]
      end

      @tokens_to_extract.each do |t|
        @extracted_tokens[t.name] = string[t.breakpoints[0]...t.breakpoints[1]]
      end

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

    protected

    def find_end_of token, string, start_at
      start = string.index(token.string, start_at) || string.length
      [start, [start + token.string.length, string.length].min]
    end

  end

end
