require 'test/unit'
require 'matrix'
require 'unit_quaternion'
require_relative '../lib/homogeneous_transformation'

class TestHomogeneousTransformation < Test::Unit::TestCase

  def setup
    @quats = [ ::UnitQuaternion.new(1,2,3,4),
               ::UnitQuaternion.new(0.1, 0.01, 2.3, 4),
               ::UnitQuaternion.new(1234.4134, 689.6124, 134.124, 0.5),
               ::UnitQuaternion.new(1,1,1,1),
             ]
    @angles = [ 2*Math::PI, Math::PI, Math::PI/2, Math::PI/4,
                0.5,  0.25, 0.1234, 0, ]
    @axes = [ Vector[ 1, 1, 1 ], Vector[ 1, 0, 0 ], Vector[ 0, 1, 0 ],
              Vector[ 0, 0, 1 ], Vector[ 1, 2, 3 ], ]
    for angle, axis in @angles.product(@axes)
      @quats << UnitQuaternion.fromAngleAxis(angle, axis)
    end

    positions = (0..1).step(0.2).to_a
    @translations = []
    positions.product(positions, positions).each() do |a, b, c|
      @translations << Vector[a, b, c]
    end
  end

  def test_initialize
    ht = HomTran.new()
    assert_equal(ht.getQuaternion(), UnitQuaternion.new(1, 0, 0, 0))
    assert_equal(ht.getTranslation(), Vector[0, 0, 0])

    q = UnitQuaternion.new(1,2,3,4)
    t = Vector[5,6,7]
    ht = HomTran.new(q, t)
    assert_equal(ht.getQuaternion(), q)
    assert_equal(ht.getTranslation(), t)
    
    @quats.product(@translations).each() do |q2, t2|
      fr = HomTran.new(q2, t2, ht)
      assert_in_delta( (fr.getQuaternion() - q * q2).norm(), 0, 1e-15)
      assert_in_delta( (fr.getTranslation() - (t + q.transform(t2))).norm(),
                       0, 1e-15)

      fr = HomTran.new(q2, t2, ht, false)
      assert_in_delta( (fr.getQuaternion() - q2 * q).norm(), 0, 1e-15)
      assert_in_delta( (fr.getTranslation() - (t + t2)).norm(), 0, 1e-15)
    end
  end

  def test_setQuaternion
    for q in @quats
      fr1 = HomTran.new()
      fr1.setQuaternion(q)
      assert_equal(fr1.getQuaternion(), q)
    end
    for q1, q2 in @quats.product(@quats)
      fr1 = HomTran.new(q1)
      fr2 = HomTran.new()
      fr2.setQuaternion(q2, fr1)
      assert_in_delta( (fr2.getQuaternion() - q1 * q2).norm(), 0, 1e-15 )
      
      fr2.setQuaternion(q2, fr1, false)
      assert_in_delta( (fr2.getQuaternion() - q2 * q1).norm(), 0, 1e-15 )
    end
  end

  def test_setTranslation
    @quats.product(@translations).each() do |q, t|
      fr1 = HomTran.new(q)
      fr1.setTranslation(t)
      assert_in_delta( (fr1.getTranslation() - t).norm(), 0, 1e-15 )

      fr2 = HomTran.new()
      fr2.setTranslation(t, fr1)
      assert_in_delta( (fr1.getTranslation() +
                        fr1.getQuaternion().transform(t) - 
                        fr2.getTranslation()).norm(), 0, 1e-15 )

      fr2.setTranslation(t, fr1, false)
      assert_in_delta( (fr2.getTranslation - 2 * t).norm(), 0, 1e-15)
    end
  end

  def test_transform
    t = Vector[1,2,3]
    fr = HomTran.new(UnitQuaternion.fromAngleAxis(Math::PI/2,
                                                  Vector[0, 0, 1]), t)
    assert_in_delta( (fr.transform(Vector[2, 0, 0]) -
                      (t + Vector[0, 2, 0])).norm(), 0, 1e-15)
    assert_in_delta( (fr.transform(Vector[0, 2, 0]) -
                      (t + Vector[-2, 0, 0])).norm(), 0, 1e-15)

    fr = HomTran.new(UnitQuaternion.fromAngleAxis(Math::PI/2,
                                                  Vector[0, 1, 0]), t)
    assert_in_delta( (fr.transform(Vector[2, 0, 0]) -
                      (t + Vector[0, 0, -2])).norm(), 0, 1e-15)
    assert_in_delta( (fr.transform(Vector[0, 0, 2]) -
                      (t + Vector[2, 0, 0])).norm(), 0, 1e-15)

    fr = HomTran.new(UnitQuaternion.fromAngleAxis(Math::PI/2,
                                                  Vector[1, 0, 0]),
                     t)
    assert_in_delta( (fr.transform(Vector[2, 0, 0]) -
                      (t + Vector[2, 0, 0])).norm(), 0, 1e-15)
    assert_in_delta( (fr.transform(Vector[0, 2, 0]) -
                      (t + Vector[0, 0, 2])).norm(), 0, 1e-15)
    assert_in_delta( (fr.transform(Vector[0, 0, 2]) -
                      (t + Vector[0, -2, 0])).norm(), 0, 1e-15)
  end
end
