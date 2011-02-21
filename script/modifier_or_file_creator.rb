#! /bin/env ruby

require File.dirname(__FILE__) + '/stream_editor'


class ModifierOrFileCreator < StreamEditor
  attr_reader :message

  def initialize(target_filename, template_filename)
    @template_filename = template_filename
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
          FileUtils.cp(@template_filename, target_filename)
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

