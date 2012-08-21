require 'spec_helper'
require 'string-eater'

TestedClass = StringEater::CTokenizer

describe StringEater do
  it "should have a version" do
    StringEater::VERSION::STRING.split(".").size.should >= 3
  end
end

# normal use
class Example1 < TestedClass
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
    @second_word1 = "bar"
    @third_word1 = "baz"
    @bp1 = [0, 3,4,7,8,11]
  end

  describe "find_breakpoints" do
    it "should return an array of the breakpoints" do
      @tokenizer.find_breakpoints(@str1).should == @bp1 if @tokenizer.respond_to?(:find_breakpoints)
    end
  end

  describe "#extract_all_fields" do
    it "should extract all of the fields" do
      @tokenizer.extract_all_fields
      @tokenizer.tokenize!(@str1)
      @tokenizer.first_word.should == @first_word1
      @tokenizer.second_word.should == @second_word1
      @tokenizer.third_word.should == @third_word1
    end
  end

  describe "#extract_no_fields" do
    it "should not extract any of the fields" do
      @tokenizer.extract_no_fields
      @tokenizer.tokenize!(@str1)
      @tokenizer.first_word.should be_nil
      @tokenizer.second_word.should be_nil
      @tokenizer.third_word.should be_nil
    end
  end

  describe "#extract_fields" do
    it "should allow us to set which fields get extracted" do
      @tokenizer.extract_fields :second_word
      @tokenizer.tokenize!(@str1)
      @tokenizer.first_word.should be_nil
      @tokenizer.second_word.should == @second_word1
      @tokenizer.third_word.should be_nil
    end
  end

  describe "tokenize!" do
    it "should return itself" do
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
class Example2 < TestedClass
  add_field :first_word, :extract => false
  look_for " "
  add_field :second_word
  look_for " "
  add_field :third_word, :extract => false
  look_for "-"
end

describe Example2 do

  before(:each) do
    @tokenizer = Example2.new
    @str1 = "foo bar baz-"
    @second_word1 = "bar"
  end

  describe "tokenize!" do
    it "should find the token when there is extra stuff at the end of the string" do
      @tokenizer.tokenize!(@str1).second_word.should == @second_word1
    end
  end

end

# CTokenizer doesn't do combine_fields because
#  writing out breakpoints is a significant slow-down
if TestedClass.respond_to?(:combine_fields)
  # an example where we combine fields
  class Example3 < TestedClass
    add_field :first_word, :extract => false
    look_for " \""
    add_field :part1, :extract => false
    look_for " "
    add_field :part2
    look_for " "
    add_field :part3, :extract => false
    look_for "\""

    combine_fields :from => :part1, :to => :part3, :as => :parts
  end

  describe Example3 do
    before(:each) do
      @tokenizer = Example3.new
      @str1 = "foo \"bar baz bang\""
      @part2 = "baz"
      @parts = "bar baz bang"
    end

    it "should extract like normal" do
      @tokenizer.tokenize!(@str1).part2.should == @part2
    end

    it "should ignore like normal" do
      @tokenizer.tokenize!(@str1).part1.should be_nil
    end

    it "should extract the combined field" do
      @tokenizer.tokenize!(@str1).parts.should == @parts
    end

  end
end
