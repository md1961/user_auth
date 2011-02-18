#! /bin/env ruby

CURRENT_DIRNAME = File.dirname(__FILE__)

require CURRENT_DIRNAME + '/session_store_modifier'
=begin
application_controller_modifier.rb
config_application_modifier.rb
prepare.rb
routes_adder.rb
=end


class PrepareUserAuth

  UP = '/..'

  MODIFIERS = [
    [SessionStoreModifier, :modify],
  ]

  def initialize
    @rails_root = search_rails_root(CURRENT_DIRNAME)
    raise RuntimeError, "Cannot find Rails root directory" unless @rails_root
  end

  def prepare
    MODIFIERS.each do |modifyingClass, action|
      begin
        modifier = modifyingClass.new(@rails_root)
        puts "#{modifyingClass} to modify file '#{File.expand_path(modifier.target_filename)}' ..."
        is_modified = modifier.send(action)
        puts is_modified ? "  Done." : "  The file was NOT modified"
      rescue => e
        puts "  Failed due to #{e.message}"
      end
    end
  end

  private

    def search_rails_root(dirname_start)
      dirname = dirname_start
      while File.directory?(dirname)
        return dirname if rails_root?(dirname)
        dirname += UP
      end

      return nil
    end

    MARKER_FILENAMES_IN_RAILS_ROOT = %w(app config db Gemfile public Rakefile script vendor)

    def rails_root?(dirname)
      filenames = Dir.entries(dirname)
      MARKER_FILENAMES_IN_RAILS_ROOT.each do |marker_filename|
        return false unless filenames.include?(marker_filename)
      end

      return true
    end
end


if __FILE__ == $0
  pua = PrepareUserAuth.new
  pua.prepare
end

