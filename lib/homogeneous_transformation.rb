require_relative 'homogeneous_transformation/version'
require 'unit_quaternion'
require 'matrix'

class HomogeneousTransformation
  # Creates a new HomogeneousTransformation from a quaternion and a vector.
  #
  # Params:
  # +q+:: A UnitQuaternion object representing this frame's orientation relative to the rel_to frame.
  # +translation+:: A 3-vector representing this frame's translation relative to the rel_to frame.
  # +rel_to+:: A HomogeneousTransformation object relative to which the current frame's orientation and translation are specified.  If rel_to is nil, the orientation and translation will be specified relative to the global reference frame.
  # +local+:: A boolean value.  If local is false, the relative position and orientation will be measured in the global reference frame.  If local is true, the relative position and orientation will be meausured in rel_to's reference frame.
  def initialize(q = UnitQuaternion.new(1, 0, 0, 0),
                 translation = Vector[0, 0, 0],
                 rel_to = nil, local = true)
    setQuaternion(q, rel_to, local)
    setTranslation(translation, rel_to, local)
  end

  def getQuaternion()
    return @q
  end

  def getTranslation()
    return @t
  end

  # Sets the quaternion for the homogeneous transformation.
  #
  # Params:
  # +q+:: A UnitQuaternion object representing the orientation of this frame.
  # +rel_to+:: A HomogeneousTransformation object relative to which the orientation is specified.  If rel_to is nil, the orientation will be specified relative to the global reference frame.
  # +local+:: A boolean value.  If local is false, the quaternion q specifies the orientation relative to rel_to as measured in the global coordinate frame.  If local is true, then q specifies the orientation relative to rel_to as measured in rel_to's coordinate frame.
  def setQuaternion(q, rel_to = nil, local = true)
    if rel_to
      if local
        @q = rel_to.getQuaternion() * q
      else
        @q = q * rel_to.getQuaternion()
      end
    else
      @q = q
    end
  end

  # Sets the translation for the homogeneous transformation.
  #
  # Params:
  # +t+:: A vector describing the frame's translation.
  # +rel_to+:: A HomogeneousTransformation object relative to which the translation is specified.  If rel_to is nil, the translation will be specified relative to the global reference frame.
  # +local+:: A boolean value.  If local is false, then t specifies the translation relative to rel_to as measured in the global coordinate frame.  If local is true, then t specifies the translation relative to rel_to as measured in rel_to's coordinate frame.
  def setTranslation(t, rel_to = nil, local = true)
    if rel_to
      if local
        @t = rel_to.getTranslation() +
          rel_to.getQuaternion().transform(t)
      else
        @t = rel_to.getTranslation() + t
      end
    else
      @t = t
    end
  end
end

HomTran = HomogeneousTransformation
