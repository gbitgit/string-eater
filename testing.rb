$:.concat %w[. ./lib ./ext/string-eater]

require 'string-eater'

class Tester < StringEater::CTokenizer
  add_field :first
  look_for " "
  add_field :second
end

t = Tester.new

t.ctokenize("Foo");
