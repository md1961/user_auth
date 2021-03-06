#! /bin/env ruby
# vi: set fileencoding=utf-8 :

require File.dirname(__FILE__) + '/../base/modifier_or_file_creator'


class LoginDisabledTemplateCreator < ModifierOrFileCreator

  TARGET_FILENAME = "app/views/sessions/_login_disabled.html.erb"

  def initialize(argv)
    super(argv, no_modify=true)
  end

  def modify
    return super
  end

  private

    def target_filename
      return TARGET_FILENAME
    end

    def template_file_contents
      return ["<h2>ログイン禁止時のメッセージ</h2>"]
    end
end


if __FILE__ == $0
  ldtc = LoginDisabledTemplateCreator.new(ARGV)
  ldtc.modify
  puts ldtc.message
end

