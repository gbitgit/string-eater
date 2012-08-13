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

  end

end
