#! /bin/env ruby

PLUGIN_DIR = File.dirname(__FILE__) + '/..'


class OverridingMethodChecker

  FILES_WITH_DIR_TO_CHECK = [
    %w(user.rb             app/models     ),
    %w(users_controller.rb app/controllers),
  ]

  ROOT_DIRS_AND_NAMESPACES = [
    ["."                 , ""              ],
    [PLUGIN_DIR + "/lib" , "user_auth_kuma"],
  ]

  def check
    FILES_WITH_DIR_TO_CHECK.each do |file, dir|
      ROOT_DIRS_AND_NAMESPACES.each do |root_dir, namespace|
        file_full = File.join(root_dir, dir, namespace, file)
        methods = user_defined_methods(file_full)
        puts "#{file_full} : #{methods.map { |m| "  " + m.to_s }.join("\n")}"
      end
    end
  end

  private

    RE_METHOD = /\A\s*def\s+((?:self\.)?\w+\??)/

    def user_defined_methods(file)
      methods = Array.new
      File.open(file, 'r') do |fd|
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

