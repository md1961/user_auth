#! /bin/env ruby

require File.dirname(__FILE__) + '/stream_editor'


class ModifierOrFileCreator < StreamEditor
  attr_reader :message

  def initialize(target_filename, template_file_contents)
    @template_file_contents = template_file_contents
    @template_file_contents = [@template_file_contents] unless @template_file_contents.is_a?(Array)

    @no_target = false
    begin
      super(target_filename)
    rescue StreamEditor::FileNotFoundError => e
      @no_target = true
    end

    @message = "Nothing done yet"
  end

  private

    def modify
      if @no_target
        is_modified = true
        begin
          File.open(target_filename, 'w') do |f|
            @template_file_contents.each do |line|
              f.puts line.chomp
            end
          end
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

    def edit
      is_edited = super
      return is_edited
    end
end

