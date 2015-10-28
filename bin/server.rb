#! /usr/bin/env ruby

require 'webrick'
require_relative '../lib/router'

router = Router.new
router.draw do
  # Routes are drawn here. For example, to get the index of users:
  # get Regexp.new("^/$"), UsersController, :index
end

PORT = ARGV[0] || 3000
server = WEBrick::HTTPServer.new(Port: PORT)
server.mount_proc('/') do |req, res|
  router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
