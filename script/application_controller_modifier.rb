#! /bin/env ruby

require File.dirname(__FILE__) + '/base/file_modifier'

require 'digest/sha1'


class ApplicationControllerModifier < FileModifier

  TARGET_FILENAME = "app/controllers/application_controller.rb"

  def initialize(argv)
    super(argv)
  end

  private

    def target_filename
      return TARGET_FILENAME
    end

    RE_TARGET = /^(\s*protect_from_forgery)\s*(?:#.*)?$/

    # Returns a String, or Array of String's to print
    def edit_line(line)
      if line =~ RE_TARGET
        line = $1 + " :secret => '#{random_string}'\n"
        set_edited(true)
      end

      return line
    end

    TIMES_RAND = 10

    def random_string
      sha1 = Digest::SHA1.new
      TIMES_RAND.times do
        sha1 << rand.to_s
      end

      return sha1.hexdigest
    end
end


if __FILE__ == $0
  acm = ApplicationControllerModifier.new(ARGV)
  acm.modify
  puts acm.message
end

