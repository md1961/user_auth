module CommandLineArgumentParser

  USAGE = "Usage: #{$0} [-n|--nobackup] dir"

  def parse_argv(argv)
    creates_backup = true
    if %w(-n --nobackup).include?(argv[0])
      creates_backup = false
      argv.shift
    end

    dirname = argv.shift
    if argv.size > 0 || dirname.nil? || ! File.directory?(dirname)
      raise ArgumentError, "Specify only a directory which has '#{target_filename}'"
    end

    return dirname, creates_backup
  end
end

