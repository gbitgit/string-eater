require 'spec_helper'
require 'string-eater'

# normal use
class Example1 < StringEater::Tokenizer
  add_field :first_word
  look_for " "
  add_field :second_word, :extract => false
  look_for "|"
  add_field :third_word
end

describe Example1 do

  before(:each) do
    @tokenizer = Example1.new
    @str1 = "foo bar|baz"
    @first_word1 = "foo"
    @third_word1 = "baz"
    @bp1 = [0, 3,4,7,8,11]
  end

  describe "find_breakpoints" do
    it "should return an array of the breakpoints" do
      @tokenizer.find_breakpoints(@str1).should == @bp1
    end
  end

  describe "tokenize!" do
    it "should itself" do
      @tokenizer.tokenize!(@str1).should == @tokenizer
    end

    it "should set the first word" do
      @tokenizer.tokenize!(@str1).first_word.should == "foo"
    end

    it "should set the third word" do
      @tokenizer.tokenize!(@str1).third_word.should == "baz"
    end

    it "should not set the second word" do
      @tokenizer.tokenize!(@str1).second_word.should be_nil
    end

    it "should yield a hash of tokens if a block is given" do
      @tokenizer.tokenize!(@str1) do |tokens|
        tokens[:first_word].should == "foo"
      end
    end

    it "should return everything to the end of the line for the last token" do
      s = "c defg asdf | foo , baa"
      @tokenizer.tokenize!("a b|#{s}").third_word.should == s
    end

  end

end

# an example where we ignore after a certain point in the string
class Example2 < StringEater::Tokenizer
  add_field :first_word, :extract => false
  look_for " "
  add_field :second_word
  look_for " "
end

describe Example2 do

  before(:each) do
    @tokenizer = Example2.new
    @str1 = "foo bar baz"
    @second_word1 = "bar"
  end

  describe "tokenize!" do
    it "should find the token when there is extra stuff at the end of the string" do
      @tokenizer.tokenize!(@str1).second_word.should == @second_word1
    end
  end

end


