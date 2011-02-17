#! /bin/env ruby

require File.dirname(__FILE__) + '/stream_editor'


class RoutesAdder < StreamEditor

  TARGET_FILENAME = "config/routes.rb"

  def initialize(dirname)
    super(dirname + '/' + TARGET_FILENAME)

    @status = SearchingKeyword.new
  end

  def modify
    return edit
  end

  private

    def edit
      is_edited = super
      return is_edited
    end

    RE_NAMED_ROUTE    = /^\s*#\s*Sample\s+.*\s*named\s+route/
    RE_RESOURCE_ROUTE = /^\s*#\s*Sample\s*resource\s*route/
    RE_ROOT_ROUTE     = /^\s*#\s*root\s+:to\s*=>\s*"/
    RE_COMMENT        = /^\s*#/

    # Returns a String, or Array of String's to print
    def edit_line(line)
      lines = @status.edit_line(line)
      is_edited = @status.edited?
      set_edited(true) if is_edited
      @status = @status.next_status

      return lines
    end

  class ParseStatus
    attr_accessor :next_status
    attr_writer :is_edited

    def initialize
      @next_status = nil
      @is_edited = false
    end

    def edited?
      return @is_edited
    end

    def edit_line(line)
      raise NotImplementedError, "Must be overridden by a subclass"
    end
  end

  class SearchingKeyword < ParseStatus
    def edit_line(line)
      self.next_status = case line
        when RE_NAMED_ROUTE
          InsertingRoute.instance(InsertingNamedRoute)
        when RE_RESOURCE_ROUTE
          InsertingRoute.instance(InsertingResourceRoute)
        when RE_ROOT_ROUTE
          InsertingRoute.instance(InsertingRootRoute)
        else
          SearchingKeyword.new
        end

      return line
    end
  end

  MAX_TIMES_OF_INSERTION = 1

  class InsertingRoute < ParseStatus
    @@h_times_of_insertion = Hash.new(0)

    def self.instance(clazz)
      unless clazz.superclass == InsertingRoute
        raise ArgumentError, "Argument clazz must be a subclass of InsertingRoute"
      end
      
      key = clazz.name.intern
      return SearchingKeyword.new if @@h_times_of_insertion[key] >= MAX_TIMES_OF_INSERTION
      return clazz.new
    end

    def edit_line(line)
      inserting_lines = Array.new
      if line =~ RE_COMMENT
        self.next_status = self.class.new
      else
        self.next_status = SearchingKeyword.new
        key = self.class.name.intern
        @@h_times_of_insertion[key] += 1
        unless line =~ search_pattern(lines_to_insert)  # Not to insert same lines again
          inserting_lines = lines_to_insert
          self.is_edited = true
        end
      end

      return inserting_lines + [line]
    end

    private

      def search_pattern(lines)
        raise ArgumentError, "Argument lines must be an Array" unless lines.is_a?(Array)
        pattern = lines[0].chomp.strip.gsub(/\s+/, '\s+').gsub(/\[/, '\[').gsub(/\]/, '\]')
        return /#{pattern}/
      end
  end

  class InsertingNamedRoute < InsertingRoute
    def lines_to_insert
      return LINES_NAMED_ROUTE
    end
  end

  class InsertingResourceRoute < InsertingRoute
    def lines_to_insert
      return LINES_RESOURCE_ROUTE
    end
  end

  class InsertingRootRoute < InsertingRoute
    def lines_to_insert
      return LINES_ROOT_ROUTE
    end
  end

  LINES_NAMED_ROUTE = [
    "  match '/login'  => \"sessions#new\"    , :as => :login\n",
    "  match '/logout' => \"sessions#destroy\", :as => :logout\n",
  ]

  LINES_RESOURCE_ROUTE = [
    "  resource :session, :only => [:new, :create, :destroy]\n",
    "  \n",
    "  resources :users, :except => [:show] do\n",
    "    member do\n",
    "      get 'change_password'\n",
    "      put 'update_password'\n",
    "    end\n",
    "  end\n",
  ]

  LINES_ROOT_ROUTE = [
    "  root :to => \"controller_name#action_name\"\n",
  ]

end


if __FILE__ == $0
  target_filename = RoutesAdder::TARGET_FILENAME

  if ARGV.size != 1 || ! File.directory?(ARGV[0])
    raise ArgumentError, "Specify directory which has '#{target_filename}'"
  end

  ra = RoutesAdder.new(ARGV[0])
  is_modified = ra.modify
  puts "'#{target_filename}' was #{is_modified ? '' : 'NOT '}modified"
end

