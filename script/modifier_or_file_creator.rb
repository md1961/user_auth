#! /bin/env ruby

require File.dirname(__FILE__) + '/stream_editor'
require File.dirname(__FILE__) + '/command_line_argument_parser'


class ModifierOrFileCreator < StreamEditor
  include CommandLineArgumentParser

  attr_reader :message

  def initialize(argv, no_modify=false)
    dirname, creates_backup = parse_argv(argv)
    @no_modify = no_modify

    @no_target = false
    begin
      super(dirname + '/' + target_filename, creates_backup)
    rescue StreamEditor::FileNotFoundError => e
      @no_target = true
    end

    @message = "Nothing done yet"
  end

  # Return a relative path to a directory to be given via argument argv of initialize()
  def target_filename
    raise NotImplementedError, "Must be overridden by a subclass"
  end

  private

    def modify
      if @no_target
        is_modified = true
        begin
          File.open(target_filename, 'w') do |f|
            template_file_contents.each do |line|
              f.puts line.chomp
            end
          end
          @message = "'#{target_filename}' was creted"
        rescue => e
          is_modified = false
          @message = e.message
        end
      elsif @no_modify
        is_modified = false
        @message = "Nothing done because '#{target_filename}' already exists"
      else
        is_modified = edit
        @message = "'#{target_filename}' was #{is_modified ? '' : 'NOT '}modified"
      end
      return is_modified
    end

    def edit
      is_edited = super
      return is_edited
    end
end

