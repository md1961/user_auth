#! /bin/env ruby

require File.dirname(__FILE__) + '/stream_editor'
require File.dirname(__FILE__) + '/command_line_argument_parser'


class FileModifier < StreamEditor
  include CommandLineArgumentParser

  attr_reader :message

  def initialize(argv)
    dirname, creates_backup = parse_argv(argv)
    super(dirname + '/' + target_filename, creates_backup)

    @message = "Nothing done yet"
  end

  # Return a relative path to a directory to be given via argument argv of initialize()
  def target_filename
    raise NotImplementedError, "Must be overridden by a subclass"
  end

  def modify
    is_modified = edit
    @message = "'#{target_filename}' was #{is_modified ? '' : 'NOT '}modified"
    return is_modified
  end

  private

    def edit
      is_edited = super
      return is_edited
    end
end

