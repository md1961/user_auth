#! /bin/env ruby

CURRENT_DIRNAME = File.dirname(__FILE__)

require CURRENT_DIRNAME + '/session_store_modifier'
require CURRENT_DIRNAME + '/application_controller_modifier'
require CURRENT_DIRNAME + '/routes_adder'
require CURRENT_DIRNAME + '/user_modifier'
require CURRENT_DIRNAME + '/users_controller_modifier'
require CURRENT_DIRNAME + '/constant_creator'
require CURRENT_DIRNAME + '/layout_template_modifier'
require CURRENT_DIRNAME + '/config_application_modifier'

require CURRENT_DIRNAME + '/command_line_argument_parser'


class PrepareUserAuth

  MODIFIERS = [
    [SessionStoreModifier         , :modify],
    [ApplicationControllerModifier, :modify],
    [RoutesAdder                  , :modify],
    [UserModifier                 , :modify],
    [UsersControllerModifier      , :modify],
    [ConstantCreator              , :modify],
    [LayoutTemplateModifier       , :modify],
    [ConfigApplicationModifier    , :modify],
  ]

  OPTIONS_NOBACKUP = CommandLineArgumentParser::OPTIONS_NOBACKUP

  def initialize(argv)
    if argv.size > 1 || (argv.size == 1 && ! OPTIONS_NOBACKUP.include?(argv[0]))
      exit_with_message("Unknown options '#{argv.join(' ')}'.  Only take [#{OPTIONS_NOBACKUP.join('|')}]")
    end
    @argv = argv

    @rails_root = search_rails_root(CURRENT_DIRNAME)
    exit_with_message("Cannot find Rails root directory") unless @rails_root
  end

  INDENT = ' ' * 4

  def prepare
    MODIFIERS.each do |modifyingClass, action|
      begin
        argv = @argv + [@rails_root]
        modifier = modifyingClass.new(argv)
        puts message_before_action(modifier)
        is_modified = modifier.send(action)
        puts INDENT + (is_modified ? "Done." : "There is nothing to be done")
      rescue => e
        puts INDENT + "Failed due to #{e.message}"
      end
    end
  end

  private

    def message_before_action(modifier)
      filename = remove_dirname(modifier.filename_to_edit, @rails_root)
      return "'#{filename}' is being modified by #{modifier.class} ..."
    end

    def remove_dirname(filename, dirname)
      abs_file = File.expand_path(filename)
      abs_dir  = File.expand_path( dirname)
      abs_dir  = abs_dir + (abs_dir[-1] == '/' ? '' : '/')
      return abs_file.gsub(/\A#{abs_dir}/, '')
    end

    DIR_UP = '/..'

    def search_rails_root(dirname_start)
      dirname = dirname_start
      while File.directory?(dirname)
        return dirname if rails_root?(dirname)
        dirname += DIR_UP
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

    def exit_with_message(message)
      $stderr.puts message
      exit
    end
end


if __FILE__ == $0
  pua = PrepareUserAuth.new(ARGV)
  pua.prepare
end

