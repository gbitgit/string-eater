module StringEater

  class Token
    attr_accessor :name, :string, :opts, :breakpoints

    def extract?
      @opts[:extract]
    end
  end

  class Field < Token
    def initialize(name, opts)
      @name = name
      @opts = {:extract => true}.merge(opts)
    end
  end

  class Separator < Token
    def initialize(string)
      @string = string
      @opts = {}
    end
  end

  class Tokenizer

    def self.tokens
      @tokens ||= []
    end

    def self.add_field name, opts={}
      self.tokens << Field.new(name, opts)
      define_method(name) {@extracted_tokens[name]}
    end

    def self.look_for tokens
      self.tokens << Separator.new(tokens)
    end

    def tokens
      @tokens ||= self.class.tokens
    end

    def refresh_tokens
      @tokens = nil
      tokens
    end

    def describe_line
      tokens.inject("") do |desc, t|
        desc << (t.string || t.name.to_s || "xxxxxx")
      end
    end

    def find_breakpoints(string)
      breakpoints = tokens.select{|t| t.string }.inject([0]) do |breakpoints, t|
        start_point = breakpoints.last
        breakpoints.concat(
          find_end_of(t, string, start_point)
        )
      end
      breakpoints << string.length unless breakpoints.last == string.length
    end

    def tokenize! string, &block
      @extracted_tokens ||= {}
      @extracted_tokens.clear

      breakpoints = find_breakpoints(string)
      breakpoints[0...-1].each_index do |i|
        tokens[i].breakpoints = [breakpoints[i], breakpoints[i+1]]
      end

      @tokens.select{|t| t.extract?}.each do |t|
        @extracted_tokens[t.name] = string[t.breakpoints[0]...t.breakpoints[1]]
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
