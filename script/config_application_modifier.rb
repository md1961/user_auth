#! /bin/env ruby

require File.dirname(__FILE__) + '/file_modifier'


class ConfigApplicationModifier < FileModifier

  TARGET_FILENAME = "config/application.rb"

  def initialize(argv)
    super(argv)

    @is_searching = true
    @is_skipping_comment = false
  end

  private

    def target_filename
      return TARGET_FILENAME
    end

    RE_LOCALE  = /^\s*#.*locale/
    RE_COMMENT = /^\s*#/

    # Returns a String, or Array of String's to print
    def edit_line(line)
      inserting_lines = Array.new
      if line =~ RE_LOCALE && @is_searching
        @is_searching = false
        @is_skipping_comment = true
      elsif line !~ RE_COMMENT && @is_skipping_comment
        @is_skipping_comment = false
        pattern = LINES_TO_INSERT[0].chomp.strip.gsub(/\s+/, '\s+')
        unless line =~ /#{pattern}/
          inserting_lines = LINES_TO_INSERT
          set_edited(true)
        end
      end

      return inserting_lines + [line]
    end

  LINES_TO_INSERT = [
    "    config.i18n.default_locale = :ja\n",
    "    config.i18n.load_path += Dir[Rails.root.join('vendor/plugins/user_auth/locales/**/*.{rb,yml}')]\n",
  ]
end


if __FILE__ == $0
  cam = ConfigApplicationModifier.new(ARGV)
  cam.modify
  puts cam.message
end

