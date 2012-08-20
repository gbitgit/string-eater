require 'spec_helper'
require 'string-eater'

$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'examples'))

require 'nginx'

describe NginxLogTokenizer do
  before(:each) do
    @tokenizer = NginxLogTokenizer.new
    @str = '73.80.217.212 - - [01/Aug/2012:09:14:25 -0500] "GET /this_is_a_url HTTP/1.1" 304 152 "http://referrer.com" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)" "-" "there could be" other "stuff here"'
   end

   {
      :ip => "73.80.217.212",
      :request => "GET /this_is_a_url HTTP/1.1",
      :status_code => "304",
      :referrer_url => "http://referrer.com",
      :user_agent => "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)",
      :remainder => "\"there could be\" other \"stuff here\"",
   }.each_pair do |token,val|
        it "should find the right value for #{token}" do
          @tokenizer.tokenize!(@str).send(token).should == val
        end
      end

end
