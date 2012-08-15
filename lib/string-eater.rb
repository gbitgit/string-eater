module StringEater

  class Token
    attr_accessor :name, :string, :opts, :breakpoints, :children

    def initialize
      @opts = {}
      @breakpoints = [nil,nil]
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
      @tokens_to_find ||= tokens.each_with_index.map do |t, i| 
        [i, t.string] if t.string
      end.compact
      @tokens_to_extract_indeces ||= tokens.each_with_index.map do |t, i|
        i if t.extract?
      end.compact

      tokens.first.breakpoints[0] = 0

      find_index = 0

      curr_token = @tokens_to_find[find_index]
      curr_token_index = curr_token[0]
      curr_token_length = curr_token[1].length
      looking_for_index = 0
      looking_for = curr_token[1][looking_for_index]

      #puts @tokens_to_find.inspect

      counter = 0
      string.each_char do |c|
        #puts "'#{c}' == '#{looking_for}'? #{find_index} #{looking_for_index} of #{curr_token_length}"
        if c == looking_for
          #puts "YES"
          if looking_for_index == 0
            # entering new token
            if curr_token_index > 0
              t = tokens[curr_token_index - 1]
              t.breakpoints[1] = counter
              if t.extract?
                @extracted_tokens[t.name] = string[t.breakpoints[0]...t.breakpoints[1]]
              end
            end
            tokens[curr_token_index].breakpoints[0] = counter
          end
          if looking_for_index >= (curr_token_length - 1)
            #puts "A"
            # leaving token
            tokens[curr_token_index].breakpoints[1] = counter

            if curr_token_index >= tokens.size-1
              # we're done!
              break
            else
              tokens[curr_token_index + 1].breakpoints[0] = counter + 1
            end
            
            # next token
            find_index += 1
            if find_index >= @tokens_to_find.length
              # we're done!
              break
            end
            curr_token = @tokens_to_find[find_index]
            curr_token_index = curr_token[0]
            curr_token_length = curr_token[1].length
            looking_for_index = 0
          else
            looking_for_index += 1
          end
        end
        looking_for = curr_token[1][looking_for_index]
        counter += 1
      end

      last_token = tokens.last
      last_token.breakpoints[1] = string.length

      #tokens.each{|t| puts t.inspect}

      if last_token.extract?
        @extracted_tokens[last_token.name] = string[last_token.breakpoints[0]..last_token.breakpoints[1]]
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

  end

end
