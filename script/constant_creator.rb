#! /bin/env ruby

require File.dirname(__FILE__) + '/modifier_or_file_creator'


class ConstantCreator < ModifierOrFileCreator

  TARGET_FILENAME = "config/initializers/00_user_auth_kuma_constant.rb"
  TEMPLATE_FILENAME = File.dirname(__FILE__) + "/templates/00_user_auth_kuma_constant.rb"

  def initialize(dirname)
    target_filename = dirname + '/' + TARGET_FILENAME
    super(target_filename, make_template_file_contents, no_modify=true)
  end

  def modify
    return super
  end

  private

    def make_template_file_contents
      lines = Array.new
      File.open(TEMPLATE_FILENAME, 'r') do |f|
        f.each do |line|
          lines << line
        end
      end

      return lines.join
    end
end


if __FILE__ == $0
  if ARGV.size != 1 || ! File.directory?(ARGV[0])
    raise ArgumentError, "Specify directory which has '#{ConstantCreator::TARGET_FILENAME}'"
  end

  um = ConstantCreator.new(ARGV[0])
  um.modify
  puts um.message
end

