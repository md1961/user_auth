#! /bin/env ruby

CURRENT_DIRNAME = File.dirname(__FILE__)
SUBSCRIPT_DIRNAME = CURRENT_DIRNAME + '/subscript'

require SUBSCRIPT_DIRNAME + '/session_store_modifier'
require SUBSCRIPT_DIRNAME + '/application_controller_modifier'
require SUBSCRIPT_DIRNAME + '/routes_adder'
require SUBSCRIPT_DIRNAME + '/user_auth_kuma_constant_creator'
require SUBSCRIPT_DIRNAME + '/constant_yml_creator'
require SUBSCRIPT_DIRNAME + '/layout_template_modifier'
require SUBSCRIPT_DIRNAME + '/config_application_modifier'
require SUBSCRIPT_DIRNAME + '/locale_ja_creator'
require SUBSCRIPT_DIRNAME + '/css_user_auth_creator'
require SUBSCRIPT_DIRNAME + '/login_disabled_template_creator'
require SUBSCRIPT_DIRNAME + '/login_notice_template_creator'

require CURRENT_DIRNAME + '/base/command_line_argument_parser'

require CURRENT_DIRNAME + '/overriding_check'


class PrepareUserAuth

  MODIFIERS = [
    [SessionStoreModifier         , :modify],
    [ApplicationControllerModifier, :modify],
    [RoutesAdder                  , :modify],
    [UserAuthKumaConstantCreator  , :modify],
    [ConstantYmlCreator           , :modify],
    [LayoutTemplateModifier       , :modify],
    [ConfigApplicationModifier    , :modify],
    [LocaleJaCreator              , :modify],
    [CssUserAuthCreator           , :modify],
    [LoginDisabledTemplateCreator , :modify],
    [LoginNoticeTemplateCreator   , :modify],
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

  INDEX_EXECUTOR  = "Executor: "
  INDEX_TARGET    = "Target:   "
  INDEX_RESULT    = "Result:   "
  INDENT          = ' ' * 4
  SEPARATING_LINE = '-' * 8

  def prepare
    is_first = true
    MODIFIERS.each do |modifyingClass, action|
      begin
        if is_first
          is_first = false
        else
          puts SEPARATING_LINE
        end

        argv = @argv + [@rails_root]
        modifier = modifyingClass.new(argv)
        puts message_before_action(modifier)

        is_modified = modifier.send(action)
        puts INDEX_RESULT + (is_modified ? modifier.message : "NOTHING to be done")
      rescue => e
        raise e

        puts INDEX_RESULT + "Failed due to #{e.message}"
      end
    end

    check_override
  end

  private

    def check_override
      oc = OverridingChecker.new
      oc.check
      message = oc.message 
      if message && ! message.empty?
        puts
        puts message
        puts "Check whether the above files/methods are OK to exist"
      end
    end

    def message_before_action(modifier)
      filename = remove_dirname(modifier.filename_to_edit, @rails_root)
      return INDEX_EXECUTOR + "#{modifier.class}\n" \
           + INDEX_TARGET   + "#{filename}"
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

