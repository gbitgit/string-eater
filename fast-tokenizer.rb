class FastToken
  attr_accessor :name, :string, :opts, :breakpoints

  def extract?
    @opts[:extract]
  end
end

class FastField < FastToken
  def initialize(name, opts)
    @name = name
    @opts = {:extract => true}.merge(opts)
  end
end

class FastSeparator < FastToken
  def initialize(string)
    @string = string
    @opts = {}
  end
end

class FastTokenizer

  def self.tokens
    @tokens ||= []
  end

  def self.add_field name, opts={}
    self.tokens << FastField.new(name, opts)
  end

  def self.look_for tokens
    self.tokens << FastSeparator.new(tokens)
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
    breakpoints = find_breakpoints(string)
    breakpoints[0...-1].each_index do |i|
      tokens[i].breakpoints = [breakpoints[i], breakpoints[i+1]]
    end
    tokens.select{|t| t.extract?}.inject([]) do |extracted_tokens, t|
      extracted_string = string[t.breakpoints[0]...t.breakpoints[1]]
      extracted_tokens << extracted_string
    end
  end

end

class NginxLogTokenizer < FastTokenizer
  add_field :ip
  look_for " - "
  add_field :remote_user, :extract => false
  look_for " ["
  add_field :timestamp, :extract => false
  look_for "] \""
  add_field :request
  look_for "\" "
  add_field :status, :type => :integer
  look_for " "
end

tokenizer = NginxLogTokenizer.new
puts tokenizer.describe_line

str = "foo - bar [fing] \"futs\" 1234 asdfasdf asdf "
puts str
puts tokenizer.find_breakpoints(str).inspect
puts tokenizer.tokenize!(str).inspect


