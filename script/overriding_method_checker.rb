#! /bin/env ruby


class OverridingMethodChecker

  PLUGIN_LIB_DIR = File.dirname(__FILE__) + '/../lib'

  FILENAMES_WITH_DIR_TO_CHECK = [
    %w(user.rb             app/models     ),
    %w(users_controller.rb app/controllers),
  ]

  H_ROOT_DIRS_AND_NAMESPACES = {
    overriding: ["."           , ""              ],
    overridden: [PLUGIN_LIB_DIR, "user_auth_kuma"],
  }

  INDENT = "  "

  def check
    FILENAMES_WITH_DIR_TO_CHECK.each do |filename, dir|
      h_methods = Hash.new
      H_ROOT_DIRS_AND_NAMESPACES.each do |name, root_and_ns|
        root_dir, namespace = root_and_ns
        full_filename = File.join(root_dir, dir, namespace, filename)
        h_methods[name] = user_defined_methods(full_filename)
      end

      overriding_filename = File.join(dir, filename)
      overriding_methods = Array.new
      h_methods[:overridden].each do |method|
        overriding_methods << method if h_methods[:overriding].include?(method)
      end
      unless overriding_methods.empty?
        puts "The following methods in '#{overriding_filename}' are overriding the ones in the plugin"
        puts overriding_methods.map { |method| INDENT + method.to_s }.join("\n")
      end
    end
  end

  private

    RE_METHOD = /\A\s*def\s+((?:self\.)?\w+\??)/

    def user_defined_methods(filename)
      methods = Array.new
      File.open(filename, 'r') do |fd|
        fd.each do |line|
          if line =~ RE_METHOD
            methods << $1.intern
          end
        end
      end

      return methods
    end
end


if __FILE__ == $0
  omc = OverridingMethodChecker.new
  omc.check
end

