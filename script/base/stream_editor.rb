#! /bin/env ruby

require 'tempfile'

# Implement edit_line() in subclass
# to receive the contents of the file line by line via argument line
# and return a String or an Array of String edited,
# or return an empty Array if deleting the line,
# or return false or nil if aborting the whole editing.
# Call set_edited(true), or set_edited_partial(key, true) for all the keys
# which were given to initialize_edited_partial() to writer back the edited
# result to the target file.
# The original contents of the target file will be saved to a file with
# filename of "#{@filename_to_edit}#{ORIGINAL_EXTENSION}".
class StreamEditor
  class FileNotFoundError < StandardError; end

  TMP_DIR = '/tmp'
  ORIGINAL_EXTENSION = '.original'

  def initialize(filename_to_edit, creates_backup=true)
    @filename_to_edit = filename_to_edit
    @creates_backup = creates_backup

    @is_edited = false
    @h_edited_partial = Hash.new

    unless File.file?(@filename_to_edit)
      raise FileNotFoundError, "Cannot find '#{filename_to_edit}'"
    end
  end

  def filename_to_edit
    return @filename_to_edit
  end

  private

    def edit_line(line)
      raise NotImplementedError, "Must be overridden by a subclass"
    end

    def edit
      f_tmp = Tempfile.new(File.basename(@filename_to_edit), TMP_DIR)
      raise "Failed to make temporary file in directory '#{TMP_DIR}'" unless f_tmp

      begin
        File.open(@filename_to_edit, 'r') do |f|
          edit_each_line(f, f_tmp)
        end
        f_tmp.close

        is_written = false
        if edited?
          begin
            write_back(f_tmp)
            is_written = true
          rescue
            File.rename(@filename_orig, @filename_to_edit)
            raise
          end
        end
      ensure
        f_tmp.close(true)
      end

      return is_written
    end

    def initialize_edited_partial(*keys)
      keys.each do |key|
        @h_edited_partial[key.intern] = false
      end
    end

    def set_edited(bool)
      check_boolean(bool)

      @is_edited = bool
    end

    def set_edited_partial(key, bool)
      check_boolean(bool)
      valid_keys = @h_edited_partial.keys
      msg = "Unknown key '#{key}' (Must be one of #{valid_keys.inspect})"
      raise ArgumentError, msg unless valid_keys.include?(key.intern)

      @h_edited_partial[key.intern] = bool
    end

    def edited?
      return @is_edited || edited_partial_all?
    end

    def edited_partial_all?
      bools = @h_edited_partial.values
      return ! bools.empty? && bools.all?
    end

    def edit_each_line(f_in, f_out)
      f_in.each do |line|
        lines = edit_line(line)
        unless lines
          set_edited(false)
          break
        end
        unless lines.is_a?(Array)
          lines = lines.is_a?(String) ? [lines] : []
        end
        lines.each do |ln|
          f_out.print ln
        end
      end
    end

    def write_back(f_tmp)
      @filename_orig = filename_for_original
      File.rename(@filename_to_edit, @filename_orig)

      f_tmp.open
      File.open(@filename_to_edit, 'w') do |f|
        f_tmp.each do |line|
          f.print line
        end
      end

      File.delete(@filename_orig) unless @creates_backup
    end

    def filename_for_original
      basename = @filename_to_edit + ORIGINAL_EXTENSION
      name = basename
      suffix = 2
      while File.exist?(name)
        name = basename + suffix.to_s
        suffix += 1
      end

      return name
    end

    def check_boolean(value)
      raise ArgumentError, "Argument must be a boolean" unless value.boolean?
    end
end


class Object
  def boolean?
    return [TrueClass, FalseClass].include?(self.class)
  end
end

