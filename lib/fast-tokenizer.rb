module FastTokenizer

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
      self.class.tokens
    end

    def describe_line
      tokens.inject("") do |desc, t|
        desc << (t.string || t.name.to_s || "xxxxxx")
      end
    end

    def find_end_of token, string, start_at
      start = string.index(token.string, start_at) || string.length
      [start, [start + token.string.length, string.length].min]
    end

    def find_breakpoints(string)
      tokens.inject([]) do |breakpoints, t|
        start_point = breakpoints.size > 0 ? breakpoints.last.last : 0
        breakpoints << if t.string.nil?
                         [start_point]
        else
          find_end_of(t, string, start_point)
        end
      end.flatten.uniq
    end

    def tokenize! string
      @extracted_tokens ||= {}
      @extracted_tokens.clear
      breakpoints = find_breakpoints(string)
      breakpoints[0...-1].each_index do |i|
        tokens[i].breakpoints = [breakpoints[i], breakpoints[i+1]]
      end
      @extracted_tokens = tokens.select{|t| t.extract?}.
        inject({}) do |extracted_tokens, t|
        extracted_tokens[t.name] = string[t.breakpoints[0]...t.breakpoints[1]]
        extracted_tokens
      end
    end

  end

end
