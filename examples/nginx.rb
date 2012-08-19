# once the gem is installed, you don't need this
$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'ext/string-eater'))

require 'string-eater'

class NginxLogTokenizer < StringEater::CTokenizer
  add_field :ip
  look_for " - "
  add_field :remote_user, :extract => false
  look_for " ["
  add_field :timestamp, :extract => false
  look_for "] \""
  add_field :request
  look_for "\" "
  add_field :status_code
  look_for " "
  add_field :bytes_sent, :extract => false
  look_for " \""
  add_field :referrer_url
  look_for "\" \""
  add_field :user_agent
  look_for "\" \""
  add_field :compression, :extract => false
  look_for "\" "
  add_field :remainder
end

if __FILE__ == $0
  tokenizer = NginxLogTokenizer.new
  puts tokenizer.describe_line

  str = '73.80.217.212 - - [01/Aug/2012:09:14:25 -0500] "GET /this_is_a_url HTTP/1.1" 304 152 "http://referrer.com" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)" "-" "there could be" other "stuff here"'

  puts "input string: " + str
  puts "Tokens: "

  # use a block to work with the extracted tokens
  tokenizer.tokenize!(str) do |tokens|
    tokens.each do |token|
      puts "\t" + token.inspect
    end
  end

  # use the token's name as a method to get its value
  puts tokenizer.ip
end
