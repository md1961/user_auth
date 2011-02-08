module UserAuthKuma

module UsersHelper

  YES_DISPLAY = 'V'
  NO_DISPLAY  = '-'

  def attribute_value(user, attr_name)
    value = user.attributes[attr_name.to_s]

    if value.boolean?
      return value ? YES_DISPLAY : NO_DISPLAY
    end

    return value
  end

  def attribute_align(attr_name)
    case attr_name.to_sym
    when :id
      return 'right'
    when :name
      return 'left'
    end

    return 'center'
  end
end

end


class Object

  def boolean?
    return [TrueClass, FalseClass].include?(self.class)
  end
end

