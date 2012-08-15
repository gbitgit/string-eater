class StringEater::Token
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
