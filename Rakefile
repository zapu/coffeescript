require 'rubygems'
require 'erb'
require 'fileutils'
require 'rake/testtask'
require 'json'

desc "Build coffee-script-source gem"
task :gem do
  require 'rubygems'
  require 'rubygems/package'

  gemspec = Gem::Specification.new do |s|
    s.name      = 'coffee-script-source'
    s.version   = JSON.parse(File.read('package.json'))["version"].gsub(/-/, '')
    s.date      = Time.now.strftime("%Y-%m-%d")

    s.homepage    = "http://jashkenas.github.com/coffee-script/"
    s.summary     = "The CoffeeScript Compiler"
    s.description = <<-EOS
      CoffeeScript is a little language that compiles into JavaScript.
      Underneath all of those embarrassing braces and semicolons,
      JavaScript has always had a gorgeous object model at its heart.
      CoffeeScript is an attempt to expose the good parts of JavaScript
      in a simple way.
    EOS

    s.files = [
      'lib/coffee_script/coffee-script.js',
      'lib/coffee_script/source.rb'
    ]

    s.authors           = ['Jeremy Ashkenas']
    s.email             = 'jashkenas@gmail.com'
    s.rubyforge_project = 'coffee-script-source'
    s.license           = "MIT"
  end

  file = File.open("coffee-script-source.gem", "w")
  Gem::Package.open(file, 'w') do |pkg|
    pkg.metadata = gemspec.to_yaml

    path = "lib/coffee_script/source.rb"
    contents = <<-ERUBY
module CoffeeScript
  module Source
    def self.bundled_path
      File.expand_path("../coffee-script.js", __FILE__)
    end
  end
end
    ERUBY
    pkg.add_file_simple(path, 0644, contents.size) do |tar_io|
      tar_io.write(contents)
    end

    contents = File.read("extras/coffee-script.js")
    path = "lib/coffee_script/coffee-script.js"
    pkg.add_file_simple(path, 0644, contents.size) do |tar_io|
      tar_io.write(contents)
    end
  end
end
