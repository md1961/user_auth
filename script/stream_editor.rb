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

  # Implement to return line(String) or lines(Array of String) after editing,
  # or return nil, or an empty Array if deleting the line.
  def edit_line(line)
    raise NotImplementedError, "Must be overridden by a subclass"
  end

  def edit
    f_tmp = Tempfile.new(File.basename(@filename), TMP_DIR)
    raise "Failed to make temporary file in directory '#{TMP_DIR}'" unless f_tmp

    begin
      File.open(@filename, 'r') do |f|
        edit_each_line(f, f_tmp)
      end
      f_tmp.close

      begin
        write_back(f_tmp)
      rescue
        File.rename(@new_filename, @filename)
        raise
      end
    ensure
      f_tmp.close(true)
    end
  end

  private

    def edit_each_line(f_in, f_out)
      f_in.each do |line|
        lines = edit_line(line)
        unless lines.is_a?(Array)
          lines = lines.is_a?(String) ? [lines] : []
        end
        lines.each do |ln|
          f_out.print ln
        end
      end
    end

    def write_back(f_tmp)
      @new_filename = @filename + ORIGINAL_EXTENSION
      File.rename(@filename, @new_filename)

      f_tmp.open
      File.open(@filename, 'w') do |f|
        f_tmp.each do |line|
          f.print line
        end
      end
    end
end

