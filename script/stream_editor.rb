#! /bin/env ruby

require 'tempfile'


class StreamEditor

  TMP_DIR = '/tmp'
  ORIGINAL_EXTENSION = '.original'

  def initialize(filename)
    @filename = filename
    unless File.file?(@filename)
      raise ArgumentError, "Cannot find '#{TARGET_FILENAME}' in directory '#{dirname}'"
    end
  end

  def edit_line
    raise NotImplementedError, "Must be overridden by a subclass"
  end

  def edit
    f_tmp = Tempfile.new(File.basename(@filename), TMP_DIR)
    raise "Failed to make temporary file" unless f_tmp

    begin
      File.open(@filename, 'r') do |f|
        f.each do |line|
          lines = edit_line(line)
          unless lines.is_a?(Array)
            lines = lines.is_a?(String) ? [lines] : []
          end
          lines.each do |ln|
            f_tmp.print ln
          end
        end
      end
      f_tmp.close

      begin
        new_filename = @filename + ORIGINAL_EXTENSION
        File.rename(@filename, new_filename)

        f_tmp.open
        File.open(@filename, 'w') do |f|
          f_tmp.each do |line|
            f.print line
          end
        end
      rescue
        File.rename(new_filename, @filename)
        raise
      end
    ensure
      f_tmp.close(true)
    end
  end
end

