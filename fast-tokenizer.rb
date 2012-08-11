require 'awesome_print'

class FastTokenizer
  def self.fields
    @fields ||= []
  end

  def self.token_separators
    @token_separators ||= []
  end

  def self.token_names
    @token_names ||= {}
  end

  def self.add_field name, opts={}
    opts[:inside] = "\"\"" if (opts[:inside] == :quotes)
    look_for(opts[:inside][0]) if opts[:inside]

    capture(name, opts[:type]) unless opts[:ignore]

    look_for(opts[:inside][-1]) if opts[:inside]
    look_for(" ")
  end

  def self.look_for tokens
    tokens.each_char do |token|
      look_for_token token
    end
  end

  def self.look_for_token token
    puts "look_for_token: #{token}"
    token_separators << token
    token_names << nil
  end

  def self.capture name, ignore=nil, type=:string
    token_names[] = [ignore, name, type, position]
  end

  def token_separators
    self.class.token_separators.dup
  end

  def self.describe_line
    desc = ""
    token_separators.each_with_index do |sep, i|
      t = (token_names[i] || "xxxx").to_s
      puts "[#{t}]"
      desc << t
      desc << sep
    end
    desc
  end
end

class NginxTokenizer < FastTokenizer
  add_field :ip
  look_for "- "
  add_field :remote_user, :ignore => true
  add_field :local_time, :inside => "[]", :ignore => true
  add_field :request, :inside => :quotes
  add_field :status, :type => :integer
  add_field :rest, :ignore => true

  ap self.token_separators
  ap self.token_names
  puts self.token_separators.join

end

puts NginxTokenizer.describe_line

