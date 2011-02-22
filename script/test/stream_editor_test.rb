#! /bin/env ruby

require 'test/unit'
require 'tempfile'

require File.dirname(__FILE__) + '/../stream_editor'


class StreamEditorTest < Test::Unit::TestCase

  TARGET_FILENAME = File.dirname(__FILE__) + "/stream_editor_test_target.txt"
  TARGET_FILE_CONTENTS = [
    "abc",
    "def",
  ]

  def setup
    @f_target = File.open(TARGET_FILENAME, 'w')
    TARGET_FILE_CONTENTS.each do |line|
      @f_target.puts line
    end
  end

  def teardown
    @f_target.close if @f_target
    File.delete(TARGET_FILENAME)
  end

  def test_initialize_with_no_existence_file
    assert_raise(StreamEditor::FileNotFoundError) do
      StreamEditor.new('impossible_to_exist')
    end
  end
end

