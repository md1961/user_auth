#! /bin/env ruby

require File.dirname(__FILE__) + '/subscript/overriding_file_checker'
require File.dirname(__FILE__) + '/subscript/overriding_method_checker'


class OverridingChecker
  attr_reader :message

  def initialize
    @ofc = OverridingFileChecker  .new
    @omc = OverridingMethodChecker.new
  end

  def check
    @ofc.check
    @omc.check

    strs = Array.new
    [@ofc, @omc].each do |checker|
      message = checker.message
      strs << message if message && ! message.empty?
    end
    @message = strs.join("\n")
  end
end


if __FILE__ == $0
  oc = OverridingChecker.new
  oc.check
  message = oc.message
  puts message if message && ! message.empty?
end

