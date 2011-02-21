#! /bin/env ruby

require File.dirname(__FILE__) + '/stream_editor'


class UserModifier < StreamEditor
  attr_reader :message

  TARGET_FILENAME = "app/models/user.rb"
  TEMPLATE_FILENAME = File.dirname(__FILE__) + "/templates/user.rb"

  def initialize(dirname)
    @no_target = false
    begin
      super(dirname + '/' + TARGET_FILENAME)
    rescue StreamEditor::FileNotFoundError => e
      @no_target = true
    end
    @message = "Nothing done yet"
  end

  def modify
    if @no_target
      is_modified = true
      begin
        FileUtils.cp(TEMPLATE_FILENAME, target_filename)
        @message = "'#{target_filename}' was creted"
      rescue => e
        is_modified = false
        @message = e.message
      end
    else
      is_modified = edit
      @message = "'#{target_filename}' was #{is_modified ? '' : 'NOT '}modified"
    end
    return is_modified
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

