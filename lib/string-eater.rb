module StringEater

  class Token
    attr_accessor :name, :string, :opts, :breakpoints, :children

    def initialize
      @opts = {}
      @children = []
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
      @current_node ||= self.root_token
      @current_node.children
    end

    def self.add_field name, opts={}
      self.tokens << Token::new_field(name, opts)
      define_method(name) {@extracted_tokens[name]}
    end

    def self.look_for tokens
      self.tokens << Token::new_separator(tokens)
    end

    def self.split_field parent_name
      @current_node = self.tokens.find{|t| t.name == parent_name}

      yield

      @current_node = self.root_token
    end

    def tokens
      @tokens ||= self.class.root_token.children
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

    def find_breakpoints_for tokens, string, starting_at
      previous = nil
      tokens.each do |t|
        t.breakpoints = [starting_at, nil]
        if t.children.size > 0
          starting_at = find_breakpoints_for t.children, string, starting_at
        else
          if t.string
            p1, p2 = find_end_of(t, string, starting_at)
            if previous
              previous.breakpoints[1] = p1
            end
            t.breakpoints = [p1, p2]
            starting_at = p2
          end
        end
        previous = t
      end
      tokens.last.breakpoints[1]
    end

    def find_breakpoints(string)
      breakpoints = tokens.select{|t| t.string }.inject([0]) do |breakpoints, t|
        start_point = breakpoints.last
        breakpoints.concat(
          find_end_of(t, string, start_point)
        )
      end
      breakpoints << string.length unless breakpoints.last == string.length
      breakpoints
    end

    def tokenize! string, &block
      @extracted_tokens ||= {}
      @extracted_tokens.clear

      breakpoints = find_breakpoints(string)
      last_important_bp = [breakpoints.length, tokens.size].min
      (0...last_important_bp).each do |i|
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

    def self.root_token
      @root_token ||= Token.new
    end

    def find_end_of token, string, start_at
      start = string.index(token.string, start_at) || string.length
      [start, [start + token.string.length, string.length].min]
    end

  end

end
