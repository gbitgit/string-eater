$: << './lib'

require 'string-eater'

class NginxLogTokenizer < StringEater::Tokenizer
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

puts tokenizer.ip

