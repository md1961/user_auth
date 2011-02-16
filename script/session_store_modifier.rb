#! /bin/env ruby

require 'tempfile'


class SessionStoreModifier

  TARGET_FILENAME = 'config/initializers/session_store.rb'
  TMP_DIR = '/tmp'
  ORIGINAL_EXTENSION = '.original'

  def initialize(dirname)
    @filename = dirname + '/' + TARGET_FILENAME
    unless File.file?(@filename)
      raise ArgumentError, "Cannot find '#{TARGET_FILENAME}' in directory '#{dirname}'"
    end
  end

  RE_COOKIE_STORE  = /^\s*\w+::Application\.config\.session_store\s+:cookie_store/
  RE_SESSION_STORE = /^\s*#\s*(\w+::Application\.config\.session_store\s+:active_record_store.*)$/

  def modify
    f_tmp = Tempfile.new(File.basename(@filename), TMP_DIR)
    raise "Failed to make temporary file" unless f_tmp
    begin
      File.open(@filename, 'r') do |f|
        f.each do |line|
          if line =~ RE_COOKIE_STORE
            line = '#' + line
          elsif line =~ RE_SESSION_STORE
            line = $1 + "\n"
          end
          f_tmp.print line
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


if __FILE__ == $0
  if ARGV.size != 1 || ! File.directory?(ARGV[0])
    raise ArgumentError, "Specify directory which has 'config/initializers/session_store.rb'"
  end

  ssm = SessionStoreModifier.new(ARGV[0])
  ssm.modify
end

