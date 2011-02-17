#! /bin/env ruby

require File.dirname(__FILE__) + '/stream_editor'


class SessionStoreModifier < StreamEditor

  TARGET_FILENAME = 'config/initializers/session_store.rb'

  def initialize(dirname)
    super(dirname + '/' + TARGET_FILENAME)
    initialize_edited_partial(:cookie, :session)
  end

  def modify
    edit
  end

  private

    def edit
      super
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
  if ARGV.size != 1 || ! File.directory?(ARGV[0])
    raise ArgumentError, "Specify directory which has 'config/initializers/session_store.rb'"
  end

  ssm = SessionStoreModifier.new(ARGV[0])
  ssm.modify
end

