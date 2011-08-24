#! /bin/env ruby

require File.dirname(__FILE__) + '/file_modifier'
require File.dirname(__FILE__) + '/stream_editor'
require File.dirname(__FILE__) + '/command_line_argument_parser'


class ModifierOrFileCreator < FileModifier

  def initialize(argv, no_modify=false)
    @no_modify = no_modify

    dirname, __dump = parse_argv(argv.dup)
    target_filename_full = dirname + '/' + target_filename
    dirname_full = File.dirname(target_filename_full)
    Dir.mkdir(dirname_full) unless File.exist?(dirname_full)

    @no_target_found = false
    begin
      super(argv)
    rescue StreamEditor::FileNotFoundError => e
      @no_target_found = true
    end
  end

  private

    def modify
      if @no_target_found
        is_modified = true
        begin
          File.open(filename_to_edit, 'w') do |f|
            template_file_contents.each do |line|
              f.puts line.chomp
            end
          end
          @message = "created"
        rescue => e
          is_modified = false
          @message = e.message
        end
      elsif @no_modify
        is_modified = false
        @message = "Nothing done because the target file already exists"
      else
        is_modified = edit
        @message = "#{is_modified ? '' : 'NOT '}modified"
      end
      return is_modified
    end
end

