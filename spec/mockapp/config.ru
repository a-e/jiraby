# config.ru

require 'rubygems'
require File.join(File.dirname(__FILE__), 'jira')

run MockJira
