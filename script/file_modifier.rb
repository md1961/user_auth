#! /bin/env ruby

require File.dirname(__FILE__) + '/stream_editor'


class FileModifier < StreamEditor
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

    USAGE = "Usage: #{$0} [-n|--nobackup] dir"

    def parse_argv(argv)
      creates_backup = true
      if %w(-n --nobackup).include?(argv[0])
        creates_backup = false
        argv.shift
      end

      dirname = argv.shift
      if argv.size > 0 || dirname.nil? || ! File.directory?(dirname)
        raise ArgumentError, "Specify only a directory which has '#{target_filename}'"
      end

      return dirname, creates_backup
    end

    def edit
      is_edited = super
      return is_edited
    end
end

