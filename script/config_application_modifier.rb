#! /bin/env ruby

require File.dirname(__FILE__) + '/stream_editor'


class ConfigApplicationModifier < StreamEditor

  TARGET_FILENAME = "config/application.rb"

  def initialize(dirname)
    super(dirname + '/' + TARGET_FILENAME)

    @is_searching = true
    @is_skipping_comment = false
  end

  def modify
    return edit
  end

  private

    def edit
      is_edited = super
      return is_edited
    end

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
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
  target_filename = ConfigApplicationModifier::TARGET_FILENAME

  if ARGV.size != 1 || ! File.directory?(ARGV[0])
    raise ArgumentError, "Specify directory which has '#{target_filename}'"
  end

  cam = ConfigApplicationModifier.new(ARGV[0])
  is_modified = cam.modify
  puts "'#{target_filename}' was #{is_modified ? '' : 'NOT '}modified"
end

