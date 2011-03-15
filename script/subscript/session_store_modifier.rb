#! /bin/env ruby

require File.dirname(__FILE__) + '/../base/file_modifier'


class SessionStoreModifier < FileModifier

  TARGET_FILENAME = "config/initializers/session_store.rb"

  def initialize(argv)
    super(argv)

    initialize_edited_partial(:cookie, :session)
  end

  private

    def target_filename
      return TARGET_FILENAME
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
  ssm = SessionStoreModifier.new(ARGV)
  ssm.modify
  puts ssm.message
end

