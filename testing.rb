$:.concat %w[. ./lib ./ext/string-eater]

require 'string-eater'

class Tester < StringEater::CTokenizer
  add_field :first
  look_for " "
  add_field :second
  look_for ", "
end

class Tester2 < StringEater::CTokenizer
  look_for "["
  add_field :first
  look_for " | "
  add_field :second
  look_for "]"
end

t = Tester.new
t2 = Tester2.new

puts t.tokenize!("Foo Bar, stuff").inspect

puts "----"

puts t2.tokenize!("[Bar | Baz]").inspect
