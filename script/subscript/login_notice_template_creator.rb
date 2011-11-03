#! /bin/env ruby
# vi: set fileencoding=utf-8 :

require File.dirname(__FILE__) + '/../base/modifier_or_file_creator'


class LoginNoticeTemplateCreator < ModifierOrFileCreator

  TARGET_FILENAME = "app/views/sessions/_login_notice.html.erb"

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
      return []
    end
end


if __FILE__ == $0
  lntc = LoginNoticeTemplateCreator.new(ARGV)
  lntc.modify
  puts lntc.message
end

