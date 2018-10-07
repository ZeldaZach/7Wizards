require 'test_helper'
puts ActiveRecord::VERSION::STRING

class DeltasTest < Test::Unit::TestCase
  include TestHelper
  context "with an blank AR class" do
    setup do
      conn = connection_specification # because it changes context in the block
      @klass = Class.new(ActiveRecord::Base) do
        self.table_name = "widgets"
        establish_connection(conn)
      end
    end
    
    should "should throw exception for deltaing non-number fields" do
      assert_raises(ActiveRecord::Base::InvalidDeltaColumn) do
        @klass.class_eval { delta_attributes :name }
      end
    end
    
    should "override values with latest update" do
      original = @klass.create
      one, two = @klass.find(original.id), @klass.find(original.id)
      one.counter += 2
      two.counter += 3
      one.save
      two.save
      assert_equal 3, original.reload.counter
    end
    
    context "with a delta attribute" do
      setup do
        @klass.class_eval { delta_attributes :counter }
      end
      
      should "update value using delta (additions)" do
        original = @klass.create
        one, two = @klass.find(original.id), @klass.find(original.id)
        one.counter += 2
        two.counter += 3
        one.save
        two.save
        assert_equal 5, original.reload.counter
      end
      
      should "update value using delta (subtractions)" do
        original = @klass.create
        one, two = @klass.find(original.id), @klass.find(original.id)
        one.counter -= 6
        two.counter -= 7
        one.save
        two.save
        assert_equal -13, original.reload.counter
      end
      
      should "exclude delta attribute if explictly specified" do
        original = @klass.create
        one, two = @klass.find(original.id), @klass.find(original.id)
        one.force_clobber(:counter, 100)
        two.force_clobber(:counter, 3000)
        one.save
        two.save
        assert_equal 3000, original.reload.counter
      end
    end
  end
end