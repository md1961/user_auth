# vi: set fileencoding=utf-8 :

require 'test_helper'
require File.dirname(__FILE__) + "/../script/templates/00_user_auth_kuma_constant"


class ConstantTest < ActiveSupport::TestCase

  def setup
    Constant.instance_eval do
      alias :_orig_read_yaml :read_yaml
    end
    override_read_yaml_of_class_constant
  end

  def teardown
    Constant.instance_eval do
      alias :read_yaml :_orig_read_yaml
    end
  end

  def test_get_for_non_existence
    assert_raise(KeyError) do
      Constant.get(:non_existence)
    end
  end

  def test_get
    [
      [:name  , 'Nao', String],
      [:weight, 70.9 , Float ],
      [:age   , 49   , Fixnum],
    ].each do |name, expected, clazz|
      actual = Constant.get(name)
      assert_equal(clazz   , actual.class, "class of :#{name}")
      assert_equal(expected, actual      , ":#{name}")

      actual = Constant.get(name.to_s)
      assert_equal(clazz   , actual.class, "class of :#{name}")
      assert_equal(expected, actual      , ":#{name}")
    end
  end

    def override_read_yaml_of_class_constant
      Constant.class_eval do
        def self.read_yaml
          YAML.load("
            name   : Nao
            age    : 49
            weight : 70.9
          ")
        end
      end
    end
    private :override_read_yaml_of_class_constant
end

