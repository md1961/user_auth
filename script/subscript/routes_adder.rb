#! /bin/env ruby

require File.dirname(__FILE__) + '/../base/file_modifier'


class RoutesAdder < FileModifier

  TARGET_FILENAME = "config/routes.rb"

  def initialize(argv)
    super(argv)

    @status = SearchingKeyword.new
  end

  private

    def target_filename
      return TARGET_FILENAME
    end

    RE_COMMENTED_OUT_NAMED_ROUTE    = /^\s*#\s*Sample\s+.*\s*named\s+route/
    RE_COMMENTED_OUT_RESOURCE_ROUTE = /^\s*#\s*Sample\s*resource\s*route/
    RE_COMMENTED_OUT_ROOT_ROUTE     = /^\s*#\s*root\s+:to\s*=>\s*"/
    RE_COMMENT                      = /^\s*#/

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
        when RE_COMMENTED_OUT_NAMED_ROUTE
          InsertingRoute.instance(InsertingNamedRoute)
        when RE_COMMENTED_OUT_RESOURCE_ROUTE
          InsertingRoute.instance(InsertingResourceRoute)
        when RE_COMMENTED_OUT_ROOT_ROUTE
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
        unless line =~ regexp_for_already_inserted(lines_to_insert)  # Not to insert same lines again
          inserting_lines = lines_to_insert
          self.is_edited = true
        end
      end

      return inserting_lines + [line]
    end

    private

      def regexp_for_already_inserted(lines)
        regexp = regexp_for_root_route(lines)
        return regexp if regexp
        raise ArgumentError, "Argument lines must be an Array" unless lines.is_a?(Array)
        pattern = lines[0].chomp.strip.gsub(/\s+/, '\s+').gsub(/\[/, '\[').gsub(/\]/, '\]')
        return /#{pattern}/
      end

      def regexp_for_root_route(lines)
        if lines.size == 1 && lines[0] =~ RE_ROOT_ROUTE
          return RE_ROOT_ROUTE
        end
        return nil
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
    "\n",
    "  resources :users, :except => [:show] do\n",
    "    member do\n",
    "      get 'change_password', 'reset_password'\n",
    "      put 'update_password'\n",
    "    end\n",
    "  end\n",
  ]

  RE_ROOT_ROUTE = /\A\s*root\s+:to\s*=>/

  LINES_ROOT_ROUTE = [
    "  root :to => \"controller_name#action_name\"\n",
  ]

end


if __FILE__ == $0
  ra = RoutesAdder.new(ARGV)
  ra.modify
  puts ra.message
end

