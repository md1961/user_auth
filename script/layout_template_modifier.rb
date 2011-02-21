#! /bin/env ruby

require File.dirname(__FILE__) + '/stream_editor'


class LayoutTemplateModifier < StreamEditor

  TARGET_FILENAME = "app/views/layouts/application.html.erb"

  def initialize(dirname)
    super(dirname + '/' + TARGET_FILENAME)

    @is_searching = true

    @logout_found = false
    @notice_found = false
    @alert_found  = false
  end

  def modify
    return edit
  end

  private

    def edit
      is_edited = super
      return is_edited
    end

    RE_YIELD = /^\s*<%=\s+yield\s+%>/

    RE_LINK_LOGOUT = /<%=\s+link_to.+,\s+logout_path/
    RE_NOTICE      = /<%=.+notice/
    RE_ALERT       = /<%=.+alert/

    # Returns a String, or Array of String's to print
    def edit_line(line)
      inserting_lines = Array.new

      if @is_searching
        case line
        when RE_LINK_LOGOUT
          @logout_found = true
        when RE_NOTICE
          @notice_found = true
        when RE_ALERT
          @alert_found  = true
        end
      end

      # Abort editing if all of them found
      return false if @logout_found && @notice_found && @alert_found

      if line =~ RE_YIELD && @is_searching
        @is_searching = false

        inserting_lines.concat(["\n", LINE_REMARK] + LINES_LOGOUT) unless @logout_found
        inserting_lines.concat(["\n", LINE_REMARK] + LINES_NOTICE) unless @notice_found
        unless @alert_found
          lines_before = @notice_found ? ["\n", LINE_REMARK] : []
          inserting_lines.concat(lines_before + LINES_ALERT)
        end
        inserting_lines << "\n"

        set_edited(true)
      end

      return inserting_lines + [line]
    end

  LINE_REMARK = "  <%# Added by plugin 'user_auth' on #{Time.now.strftime("%Y-%m-%d %H:%M")} -%>\n"

  LINES_LOGOUT = [
    "  <% if logged_in? -%>\n",
    "    <%= link_to t(""helpers.link.logout""), logout_path %>\n",
    "  <% end -%>\n",
  ]
  LINES_NOTICE = [
    "  <%= content_tag :p, notice, :class => ""notice"" if notice.present? %>\n",
  ]
  LINES_ALERT = [
    "  <%= content_tag :p, alert , :class => ""alert""  if alert .present? %>\n",
  ]
end


if __FILE__ == $0
  target_filename = LayoutTemplateModifier::TARGET_FILENAME

  if ARGV.size != 1 || ! File.directory?(ARGV[0])
    raise ArgumentError, "Specify directory which has '#{target_filename}'"
  end

  cam = LayoutTemplateModifier.new(ARGV[0])
  is_modified = cam.modify
  puts "'#{target_filename}' was #{is_modified ? '' : 'NOT '}modified"
end

