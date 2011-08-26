#! /bin/env ruby

begin
  require 'highline'
rescue LoadError => e
  $stdout.puts "Gem 'highline' not found\n" \
             + "Please install with the following command\n" \
             + "  $ sudo gem install highline"
end


hl = HighLine.new

username = hl.ask("username: ")
password = hl.ask("password: ") { |q| q.echo = false }

puts "username = " + hl.color(username, :cyan)
puts "password = " + hl.color(password, :red)

