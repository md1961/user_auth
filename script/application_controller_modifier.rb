#! /bin/env ruby

require File.dirname(__FILE__) + '/stream_editor'

require 'digest/sha1'


class ApplicationControllerModifier < StreamEditor

  TARGET_FILENAME = "app/controllers/application_controller.rb"

  def initialize(dirname)
    super(dirname + '/' + TARGET_FILENAME)
  end

  def modify
    return edit
  end

  private

    def edit
      is_edited = super
      return is_edited
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
  target_filename = ApplicationControllerModifier::TARGET_FILENAME

  if ARGV.size != 1 || ! File.directory?(ARGV[0])
    raise ArgumentError, "Specify directory which has '#{target_filename}'"
  end

  acm = ApplicationControllerModifier.new(ARGV[0])
  is_modified = acm.modify
  puts "'#{target_filename}' was #{is_modified ? '' : 'NOT '}modified"
end

