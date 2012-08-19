# once the gem is installed, you don't need this
$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'ext/string-eater'))

# this is the example from the README
require 'string-eater'

class PersonTokenizer < StringEater::Tokenizer 
  add_field :last_name 
  look_for ", "
  add_field :first_name, :extract => false
  look_for " | "
  add_field :street_address, :extract => false 
  look_for ", " 
  add_field :city
  look_for ", " 
  add_field :state 
  look_for ", " 
end

if __FILE__ == $0
  tokenizer = PersonTokenizer.new
  puts tokenizer.describe_line

  string = "Flinstone, Fred | 301 Cobblestone Way, Bedrock, NA, 00000" 
  tokenizer.tokenize! string

  puts tokenizer.last_name # => "Flinestone" 
  puts tokenizer.city      # => "Bedrock" 
  puts tokenizer.state     # => "NA"

  tokenizer.tokenize!(string) do |tokens| 
    puts "The #{tokens[:last_name]}s live in #{tokens[:city]}"
  end
end
