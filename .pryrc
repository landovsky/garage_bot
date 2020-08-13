require 'rubygems'
require 'bundler/setup'

require_relative 'app/slack_app'

include SlackApp::DSL
