#! /bin/env ruby

require File.dirname(__FILE__) + '/stream_editor'


class UserModifier < StreamEditor

  TARGET_FILENAME = "app/models/user.rb"

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

    RE_TARGET = /^(\s*)class\s+User\s+<\s+ActiveRecord::Base(.*)$/
    STATEMENT_TO_INSERT = "class User < UserAuthKuma::User"

    # Returns a String, or Array of String's to print
    def edit_line(line)
      if line =~ RE_TARGET
        line = $1 + STATEMENT_TO_INSERT + $2 + "\n"
        set_edited(true)
      end

      return line
    end
end


if __FILE__ == $0
  target_filename = UserModifier::TARGET_FILENAME

  if ARGV.size != 1 || ! File.directory?(ARGV[0])
    raise ArgumentError, "Specify directory which has '#{target_filename}'"
  end

  um = UserModifier.new(ARGV[0])
  is_modified = um.modify
  puts "'#{target_filename}' was #{is_modified ? '' : 'NOT '}modified"
end

