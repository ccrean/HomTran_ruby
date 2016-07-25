require 'test/unit'
require 'matrix'
require 'unit_quaternion'
require_relative '../lib/HomogeneousTransformation'

class TestHomogeneousTransformation < Test::Unit::TestCase

  def test_initialize
    ht = HomTran.new()
    assert_equal(ht.getQuaternion(), UnitQuaternion.new(1, 0, 0, 0))
    assert_equal(ht.getTranslation(), Vector[0, 0, 0])

    q = UnitQuaternion.new(1,2,3,4)
    t = Vector[5,6,7]
    ht = HomTran.new(q, t)
    assert_equal(ht.getQuaternion(), q)
    assert_equal(ht.getTranslation(), t)
  end
end
