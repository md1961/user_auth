#! /bin/env ruby

require File.dirname(__FILE__) + '/stream_editor'


class SessionStoreModifier < StreamEditor

  TARGET_FILENAME = "config/initializers/session_store.rb"

  def initialize(dirname, creates_backup=true)
    super(dirname + '/' + TARGET_FILENAME, creates_backup)
    initialize_edited_partial(:cookie, :session)
  end

  def modify
    return edit
  end

  private

    def edit
      is_edited = super
      return is_edited
    end

    RE_COOKIE_STORE  = /^\s*\w+::Application\.config\.session_store\s+:cookie_store/
    RE_SESSION_STORE = /^\s*#\s*(\w+::Application\.config\.session_store\s+:active_record_store.*)$/

    # Returns a String, or Array of String's to print
    def edit_line(line)
      if line =~ RE_COOKIE_STORE
        line = '#' + line
        set_edited_partial(:cookie, true)
      elsif line =~ RE_SESSION_STORE
        line = $1 + "\n"
        set_edited_partial(:session, true)
      end
      return line
    end
end


if __FILE__ == $0
  target_filename = SessionStoreModifier::TARGET_FILENAME

  creates_backup = true
  if ARGV[0] == '--nobackup'
    creates_backup = false
    ARGV.shift
  end

  filename = ARGV.shift
  if ARGV.size > 0 || ! File.directory?(filename)
    raise ArgumentError, "Specify directory which has '#{target_filename}'"
  end

  ssm = SessionStoreModifier.new(filename, creates_backup)
  is_modified = ssm.modify
  puts "'#{target_filename}' was #{is_modified ? '' : 'NOT '}modified"
end

