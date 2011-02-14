module UserAuthKuma

module FormHelper

  def uak_error_messages_for(object)
    raise RuntimeError, "Argument object must have method errors()" unless object.respond_to?(:errors)
    return nil if object.errors.empty?

    model_name = object.class.name.demodulize.underscore
    render :partial => 'system/error_messages_for',
              :locals => {:object => object, :model_name => model_name}
  end
end

end

