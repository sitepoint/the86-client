#!/usr/bin/env rake
require "bundler/gem_tasks"

task default: :test

# MiniTest
require "rake/testtask"
Rake::TestTask.new do |t|
  ENV["TESTOPTS"] = "-v"
  t.pattern = "spec/*_spec.rb"
end
