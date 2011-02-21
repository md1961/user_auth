#! /bin/env ruby

require File.dirname(__FILE__) + '/modifier_or_file_creator'


class UserModifier < ModifierOrFileCreator
  TARGET_FILENAME = "app/models/user.rb"

  def initialize(dirname)
    target_filename = dirname + '/' + TARGET_FILENAME
    super(target_filename, TEMPLATE_FILE_CONTENTS)
  end

  def modify
    return super
  end

  private

    RE_TARGET = /^(\s*)class\s+User\s+<\s+ActiveRecord::Base(.*)$/
    STATEMENT_TO_REPLACE_WITH = "class User < UserAuthKuma::User"

    TEMPLATE_FILE_CONTENTS = STATEMENT_TO_REPLACE_WITH + "\nend\n"

    # Returns a String, or Array of String's to print
    def edit_line(line)
      if line =~ RE_TARGET
        line = $1 + STATEMENT_TO_REPLACE_WITH + $2 + "\n"
        set_edited(true)
      end

      return line
    end
end


if __FILE__ == $0
  if ARGV.size != 1 || ! File.directory?(ARGV[0])
    raise ArgumentError, "Specify directory which has '#{UserModifier::TARGET_FILENAME}'"
  end

  um = UserModifier.new(ARGV[0])
  um.modify
  puts um.message
end

