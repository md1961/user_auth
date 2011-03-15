#! /bin/env ruby

require File.dirname(__FILE__) + '/../base/modifier_or_file_creator'


class UserModifier < ModifierOrFileCreator

  TARGET_FILENAME = "app/models/user.rb"

  def initialize(argv)
    super(argv)
  end

  def modify
    return super
  end

  private

    def target_filename
      return TARGET_FILENAME
    end

    def template_file_contents
      return [
        STATEMENT_TO_REPLACE_WITH + "\n",
        "end\n",
      ]
    end

    RE_TARGET = /^(\s*)class\s+User\s+<\s+ActiveRecord::Base(.*)$/
    STATEMENT_TO_REPLACE_WITH = "class User < UserAuthKuma::User"

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
  um = UserModifier.new(ARGV)
  um.modify
  puts um.message
end

