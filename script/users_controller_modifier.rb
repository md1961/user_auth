#! /bin/env ruby

require File.dirname(__FILE__) + '/modifier_or_file_creator'


class UsersControllerModifier < ModifierOrFileCreator
  TARGET_FILENAME = "app/controllers/users_controller.rb"

  def initialize(dirname)
    target_filename = dirname + '/' + TARGET_FILENAME
    super(target_filename, TEMPLATE_FILE_CONTENTS)
  end

  def modify
    return super
  end

  private

    RE_TARGET = /^(\s*)class\s+UsersController\s+<\s+ApplicationController(.*)$/
    STATEMENT_TO_REPLACE_WITH = "class UsersController < UserAuthKuma::UsersController"

    LINES_TO_APPEND_AFTER = [
      "  before_filter :authenticate, :only => [:change_password, :update_password]\n",
      "  before_filter :authenticate_as_administrator,\n",
      "                             :except => [:change_password, :update_password]\n",
    ].freeze

    TEMPLATE_FILE_CONTENTS = [STATEMENT_TO_REPLACE_WITH + "\n"] + LINES_TO_APPEND_AFTER + ["end\n"]

    # Returns a String, or Array of String's to print
    def edit_line(line)
      lines_to_append = Array.new
      if line =~ RE_TARGET
        line = $1 + STATEMENT_TO_REPLACE_WITH + $2 + "\n"
        lines_to_append = LINES_TO_APPEND_AFTER.map { |ln| $1 + ln }
        set_edited(true)
      end

      return [line] + lines_to_append
    end
end


if __FILE__ == $0
  if ARGV.size != 1 || ! File.directory?(ARGV[0])
    raise ArgumentError, "Specify directory which has '#{UsersControllerModifier::TARGET_FILENAME}'"
  end

  um = UsersControllerModifier.new(ARGV[0])
  um.modify
  puts um.message
end

