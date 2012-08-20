# String Eater

A fast ruby string tokenizer.  It eats strings and dumps tokens.

## License

String Eater is released under the 
[MIT license](http://en.wikipedia.org/wiki/MIT_License). 
See the LICENSE file.

## Requirements

String Eater probably only works in Ruby 1.9.2+ with MRI.  It's been
tested with Ruby 1.9.3p194. 

String Eater uses a C extension, so it will only work on Ruby
implemenatations that provide support for C extensions.

## Installation

If your system is set up to allow it, you can just do

    gem install string-eater

Or,  if you prefer a more hands-on approach or want to hack at the source:

    git clone git://github.com/dantswain/string-eater.git 
    cd string-eater 
    rake install

If you are working on a system where you need to `sudo gem install`
you can do

    rake gem 
    sudo gem install string-eater

As always, you can `rake -T` to find out what other rake tasks we have
provided.

## Basic Usage

Suppose we want to tokenize a string that contains address information
for a person and is consistently formatted like

    Last Name, First Name | Street address, City, State, Zip

Suppose we only want to extract the last name, city, and state.

To do this using String Eater, create a subclass of
`StringEater::Tokenizer` like this

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

Note the use of `:extract => false` to specify fields that are important
to the structure of the line but that we don't necessarily need to
extract.

Then, we can tokenize the string like this:

    tokenizer = PersonTokenizer.new
    string = "Flinstone, Fred | 301 Cobblestone Way, Bedrock, NA, 00000" 
    tokenizer.tokenize! string

    puts tokenizer.last_name # => "Flinestone" 
    puts tokenizer.city      # => "Bedrock" 
    puts tokenizer.state     # => "NA"

We can also do something like this:

    tokenizer.tokenize!(string) do |tokens| 
      puts "The #{tokens[:last_name]}s live in #{tokens[:city]}"
    end

For another example, see `examples/nginx.rb`, which defines an
[nginx](http://nginx.org) log line tokenizer.

## Implementation

There are actually three tokenizer algorithms provided here.  The
three algorithms should be interchangeable.

1. `StringEater::CTokenizer` - A C extension implementation.  The
   fastest of the three.  This is the default implementation for
   `StringEater::Tokenizer`.

2. `StringEater::RubyTokenizer` - A pure-Ruby implementation.  This is
   a slightly different implementation of the algorithm - an
   implementation that is faster on Ruby than a translation of the C
   algorithm.  Probably not as fast (or not much faster) than using
   Ruby regular expressions. 

3. `StringEater::RubyTokenizerEachChar` - A pure-Ruby implementation.
   This is essentially the same as the C implementation, but written
   in pure Ruby.  It uses `String#each_char` and is therefore VERY
   SLOW!  It provides a good way to hack the algorithm, though.

The main algorithm works by finding the start and end points of tokens
in a string.  The search is done incrementally (i.e., loop through the
string and look for each sequence of characters).  The algorithm is
"lazy" in the sense that only the required tokens are copied for
output ("extracted").

## Performance

Soon I'll add some code here to run your own benchmarks.

I've run my own benchmarks comparing String Eater to some code that does the
same task (both tokenizing nginx log lines) using Ruby regular expressions.  So
far, String Eater is about 200% faster; able to process over 100,000 lines per
second on my laptop vs less than 50,000 lines per second for the regular
expression version.  I'm working to further optimize the String Eater code.

## Contributing

The usual github process applies here:

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

You can also contribute to the author's ego by letting him know that
you find String Eater useful ;)
