#! /bin/env ruby

require File.dirname(__FILE__) + '/../base/modifier_or_file_creator'


class UserAuthKumaConstantCreator < ModifierOrFileCreator

  TARGET_FILENAME = "config/initializers/00_user_auth_kuma_constant.rb"
  TEMPLATE_FILENAME = File.dirname(__FILE__) + "/../templates/00_user_auth_kuma_constant.rb"

  def initialize(argv)
    super(argv, no_modify=true)

    @template_file_contents = make_template_file_contents
  end

  def modify
    return super
  end

  private

    def target_filename
      return TARGET_FILENAME
    end

    def template_file_contents
      return @template_file_contents
    end

    def make_template_file_contents
      return File.open(TEMPLATE_FILENAME, 'r').readlines
    end
end


if __FILE__ == $0
  uakcc = UserAuthKumaConstantCreator.new(ARGV)
  uakcc.modify
  puts uakcc.message
end

