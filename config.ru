require 'rubygems'
require 'bundler'

Bundler.require

require File.join(File.dirname(__FILE__), 'focacha')

run Focacha::Application
