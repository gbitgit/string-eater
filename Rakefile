require 'rake/clean'

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

task :compile => ext_file

CLEAN.include('ext/**/*{.o,.log,.so,.bundle}')
CLEAN.include('ext/**/Makefile')
