#! /bin/env ruby

PLUGIN_DIR = File.dirname(__FILE__) + '/..'

class OverridingFileChecker

  VIEW_DIR = "app/views"
  VIEW_SUBDIRS = %w(sessions users)

  def initialize(target_dir=".")
    raise IOError, "Cannot find directory '#{target_dir}'" unless target_dir && File.directory?(target_dir)

    @target_dir = target_dir
  end

  UNNECESSARY_FILES = %w(. ..)

  def check
    overriding_files = Array.new
    VIEW_SUBDIRS.each do |subdir|
      source_dir = File.join(PLUGIN_DIR, VIEW_DIR, subdir)
      files = Dir.entries(source_dir).reject { |name| UNNECESSARY_FILES.include?(name) }

      dest_dir = File.join(@target_dir, VIEW_DIR, subdir)
      files.each do |file|
        file_full = File.join(dest_dir, file)
        overriding_files << file_full if File.exist?(file_full)
      end
    end

    indent = "  "
    unless overriding_files.empty?
      puts "The following file(s) are concealing the corresponding file in the plugin:"
      puts overriding_files.map { |name| indent + name}.join("\n")
    end
  end
end


if __FILE__ == $0
  ofc = OverridingFileChecker.new
  ofc.check
end

