require 'rake/clean'

desc "Run rspec spec/ (compile if needed)"
task :test => :compile do
  sh "rspec spec/"
end

so_ext = RbConfig::CONFIG['DLEXT']
ext_dir = "ext/string-eater"
ext_file = ext_dir + "/c_tokenizer_ext.#{so_ext}"

file ext_file => Dir.glob("ext/string-eater/*{.rb,.c}") do
  Dir.chdir("ext/string-eater") do
    ruby "extconf.rb"
    sh "make"
  end
end

desc "Create gem"
task :gem => "string-eater.gemspec" do
  sh "gem build string-eater.gemspec"
end

desc "Install using 'gem install'"
task :install => :gem do
  sh "gem install string-eater"
end

desc "Compile the extension"
task :compile => ext_file

CLEAN.include('ext/**/*{.o,.log,.so,.bundle}')
CLEAN.include('ext/**/Makefile')
