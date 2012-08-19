$:.concat %w[. ./lib ./ext/string-eater]

require 'string-eater'

class Tester < StringEater::CTokenizer
  add_field :first
  look_for " "
  add_field :second
  look_for ", "
  add_field :third
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

s = "Foo Bar, stuff"
t.tokenize!(s) do |t|
  t.each_pair{|k,v| puts "#{k}: #{v}"}
end
puts s
puts t.find_breakpoints(s).inspect

puts "----"

s = "[Bar | Baz]"
t2.tokenize!(s) do |t|
  t.each_pair{|k,v| puts "#{k}: #{v}"}
end
puts s
puts t2.find_breakpoints(s).inspect
