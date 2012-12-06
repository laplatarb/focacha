require 'rubygems'
require 'bundler'

Bundler.require :default, ENV['RACK_ENV']

require File.join(File.dirname(__FILE__), 'focacha')

run Focacha::Application
