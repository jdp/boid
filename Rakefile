$LOAD_PATH.unshift 'lib'

require 'rake/testtask'
require 'rake/clean'

task :default => [:docs]

# Bring in Rocco tasks
begin
  require 'rocco/tasks'
  Rocco::make 'docs/'
rescue LoadError
  warn "#$! -- rocco tasks not loaded."
  task :rocco
end
Rocco::make 'docs/', 'Boid/*.io', { :language => 'io' }

desc 'Build Boid annotations'
task :docs => :rocco
directory 'docs/'

# Make index.html a copy of Boid.html
file 'docs/index.html' => 'docs/Boid.html' do |f|
  cp 'docs/Boid.html', 'docs/index.html', :preserve => true
end
task :docs => 'docs/index.html'
CLEAN.include 'docs/index.html'

# Alias for docs task
task :doc => :docs

# GITHUB PAGES ===============================================================

desc 'Update gh-pages branch'
task :pages => ['docs/.git', :docs] do
  rev = `git rev-parse --short HEAD`.strip
  Dir.chdir 'docs' do
    sh "git add *.html"
    sh "git commit -m 'rebuild pages from #{rev}'" do |ok,res|
      if ok
        verbose { puts "gh-pages updated" }
        sh "git push -q o HEAD:gh-pages"
      end
    end
  end
end

# Update the pages/ directory clone
file 'docs/.git' => ['docs/', '.git/refs/heads/gh-pages'] do |f|
  sh "cd docs && git init -q && git remote add o ../.git" if !File.exist?(f.name)
  sh "cd docs && git fetch -q o && git reset -q --hard o/gh-pages && touch ."
end
CLOBBER.include 'docs/.git'
