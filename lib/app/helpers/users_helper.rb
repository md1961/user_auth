module UsersHelper
  include FormHelper

  def attribute_value(user, attr_name)
    value = user.attributes[attr_name.to_s]

    if value.boolean?
      key = value ? 'owns' : 'not_own'
      return t("helpers.symbol.user.#{key}")
    end

    return value
  end

  def attribute_align(attr_name)
    case attr_name.to_sym
    when :id
      return 'right'
    when :name, :real_name, :email, :time_limit
      return 'left'
    end

    return 'center'
  end

  def args_for_form_for(user)
    url, method = user.new_record? ? [users_path, :post] : [user_path, :put]
    return {:as => :user, :url => url, :html => {:method => method}}
  end

  def eval_or_nil(expr)
    begin
      return eval(expr)
    rescue
    end

    return nil
  end

  def browse_back_by_javascript
    return 'javascript:history.go(-1);'
  end
end


class Object

  def boolean?
    return [TrueClass, FalseClass].include?(self.class)
  end
end

