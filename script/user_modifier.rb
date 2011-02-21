#! /bin/env ruby

require File.dirname(__FILE__) + '/stream_editor'


class UserModifier < StreamEditor
  attr_reader :message

  TARGET_FILENAME = "app/models/user.rb"

  def initialize(dirname)
    begin
      super(dirname + '/' + TARGET_FILENAME)
    rescue StreamEditor::FileNotFoundError => e
      raise
    end
    @message = "Nothing done yet"
  end

  def modify
    is_edited = edit
    @message = "'#{target_filename}' was #{is_edited ? '' : 'NOT '}modified"
    return is_edited
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
  if ARGV.size != 1 || ! File.directory?(ARGV[0])
    raise ArgumentError, "Specify directory which has '#{UserModifier::TARGET_FILENAME}'"
  end

  um = UserModifier.new(ARGV[0])
  um.modify
  puts um.message
end

