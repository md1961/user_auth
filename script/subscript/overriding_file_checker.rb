#! /bin/env ruby


class OverridingFileChecker
  attr_reader :message

  PLUGIN_DIR = File.dirname(__FILE__) + '/../..'

  VIEW_DIR = "app/views"
  VIEW_SUBDIRS = %w(system sessions users)

  def initialize
    @message = nil
  end

  INDENT = ' ' * 2

  UNNECESSARY_FILES = %w(. ..)

  def check
    @message = nil

    overriding_files = Array.new
    VIEW_SUBDIRS.each do |subdir|
      source_dir = File.join(PLUGIN_DIR, VIEW_DIR, subdir)
      filenames = Dir.entries(source_dir).reject { |name| UNNECESSARY_FILES.include?(name) }

      dest_dir = File.join(VIEW_DIR, subdir)
      filenames.each do |filename|
        full_filename = File.join(dest_dir, filename)
        overriding_files << full_filename if File.exist?(full_filename)
      end
    end

    unless overriding_files.empty?
      @message  = "The following file(s) are concealing the corresponding file in the plugin:\n"
      @message += overriding_files.map { |name| INDENT + name }.join("\n")
    end
  end
end


if __FILE__ == $0
  ofc = OverridingFileChecker.new
  ofc.check
  puts ofc.message
end

