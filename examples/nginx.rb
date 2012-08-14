$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

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

  split_field :request do
    add_field :request_verb
    look_for " "
    add_field :request_url
    look_for " "
    add_field :request_etc, :extract => false
  end
end

tokenizer = NginxLogTokenizer.new
puts tokenizer.describe_line

#str = "foo - bar [fing] \"futs\" 1234 asdfasdf asdf "
#puts str
#puts tokenizer.find_breakpoints(str).inspect
#tokenizer.tokenize!(str) do |tokens|
#  puts tokens.inspect
#end
#
#puts tokenizer.ip

