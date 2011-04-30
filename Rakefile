require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'
begin
  require 'bundler'
rescue LoadError
  puts 'Bundler not available. Install it with: [sudo] gem install bundler'
end
begin
  require 'jeweler'
rescue LoadError
  puts 'Jeweler not available. Install it with: [sudo] gem install jeweler'
end

task :default => :gemspec

Jeweler::Tasks.new do |gemspec|
  gemspec.name = 'fotki-export'
  gemspec.summary = 'Fotki.com photo export tool.'
  gemspec.description = 'Simple command line to to download all your photos from Fotki.com'
  gemspec.email = 'gene.drabkin@gmail.com'
  gemspec.homepage = 'https://github.com/cloocher/fotki-exporter'
  gemspec.authors = ['Gene Drabkin']
  gemspec.files = FileList['fotki-export.gemspec', 'Rakefile', 'README', 'VERSION', 'lib/**/*', 'bin/**/*']
  gemspec.add_dependency 'watir-webdriver', '>= 0.2.2'
  gemspec.executables = ['fotki-export']
  gemspec.requirements = ['none']
  gemspec.bindir = 'bin'
  gemspec.add_bundler_dependencies
end

desc 'Release gem'
task :'release:gem' do
  %x(
      rake gemspec
      rake build
      rake install
      git add .
  )
  puts 'Commit message:'
  message = STDIN.gets

  version = File.exist?('VERSION') ? File.read('VERSION') : ''

  %x(
    git commit -m '#{message}'
    git push origin master
    gem push pkg/fotki-export-#{version}.gem
  )
end

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "fotki-export #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end