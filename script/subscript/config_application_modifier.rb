#! /bin/env ruby

require File.dirname(__FILE__) + '/../base/file_modifier'


class ConfigApplicationModifier < FileModifier

  TARGET_FILENAME = "config/application.rb"

  def initialize(argv)
    super(argv)

    @is_searching_first  = true
    @is_searching_second = false
    @is_skipping_comment = false
  end

  private

    def target_filename
      return TARGET_FILENAME
    end

    RE_LOCALE  = /^\s*#.*locale/
    RE_COMMENT = /^\s*#/

    #TODO: Do something to default_locale other than :ja setting already there.

    # Returns a String, or Array of String's to print
    def edit_line(line)
      inserting_lines = Array.new
      if line =~ RE_LOCALE && @is_searching_first
        @is_searching_first  = false
        @is_skipping_comment = true
      elsif line !~ RE_COMMENT && @is_skipping_comment
        @is_skipping_comment = false
        @is_searching_second = true
        [:first, :second].each do |index|
          line_to_insert = line_to_insert(index, line)
          break unless line_to_insert
          inserting_lines << line_to_insert
          @is_searching_second = false
        end
      elsif @is_searching_second
        @is_searching_second = false
        line_to_insert = line_to_insert(:second, line)
        inserting_lines << line_to_insert if line_to_insert
      end

      return inserting_lines + [line]
    end

    def line_to_insert(index, line)
      line_to_insert = LINES_TO_INSERT[index == :first ? 0 : 1]
      unless line =~ /#{make_pattern(line_to_insert)}/
        set_edited(true)
        return line_to_insert
      end
      return nil
    end

    def make_pattern(line)
      return Regexp.escape(line.chomp.strip).gsub(/\\\s/, '\s+')
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

