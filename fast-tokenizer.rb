class FastToken
  attr_accessor :name, :string, :opts
end

class FastField < FastToken
  def initialize(name, opts)
    @name = name
    @opts = opts
  end

  def extract?
    opts[:extract]
  end
end

class FastSeparator < FastToken
  def initialize(string)
    @string = string
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

puts NginxLogTokenizer.new.describe_line
