# Author:: Cory Crean (mailto:cory.crean@gmail.com)
# Copyright:: Copyright (c) 2016 Cory Crean
# License:: BSD
#
# A homogeneous transformation class, for converting between the
# representations of vectors in different reference frames.

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

  # Creates a homogeneous transformation given a suitable 4x4 matrix.
  #
  # Params:
  # +m+:: A 4x4 matrix.  The upper left 3x3 submatrix must be orthonormal, and the final row must be [0, 0, 0, 1].
  def self.fromMatrix(m)
    h = HomogeneousTransformation.new()
    h.setMatrix(m)
    return h
  end

  # Returns the quaternion that represents the orientation of the homogeneous transformation.
  def getQuaternion()
    return @q
  end

  # Returns the 3-vector that specifies the translation of the homogeneous transformation.
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

  # Sets the value of the homogeneous transformation given a suitable 4x4 matrix.
  #
  # Params:
  # +m+:: A 4x4 matrix.  The upper left 3x3 submatrix must be orthonormal, and the final row must be [0, 0, 0, 1].
  def setMatrix(m)
    if m.row_size() != 4 or m.column_size() != 4
      raise(ArgumentError, "Matrix must be 4x4")
    end
    if (m.row(3) - Vector[0,0,0,1]).norm() > 1e-15
      raise(ArgumentError, "Final row must be [0, 0, 0, 1]")
    end
    @q.setRotationMatrix(m.minor(0..2, 0..2))
    @t = m.column(3)[0..2]
  end

  # Takes a vector v representing a point in the local frame and returns the
  # vector to that same point relative to the global frame.
  #
  # Params:
  # +v+:: A vector in the local reference frame.
  #
  # Returns:
  # The representation of v in the global reference frame.
  def transform(v)
    return @t + @q.transform(v)
  end

  # Returns the inverse of the homogeneous transformation.
  def inverse
    q_inv = @q.inverse()
    t_inv = q_inv.transform(-1 * @t)
    return HomogeneousTransformation.new(q_inv, t_inv)
  end

  # Returns the 4x4 matrix representation of the homogeneous transformation.
  def getMatrix
    rot_mat = @q.getRotationMatrix()
    m = Matrix.columns([*rot_mat.transpose(), @t])
    m = Matrix.rows([*m, [0, 0, 0, 1]])
    return m
  end

  # Compose two homogeneous transformations.
  def *(other)
    q_result = self.getQuaternion() * other.getQuaternion()
    t_result = self.getQuaternion().transform(other.getTranslation()) +
      self.getTranslation()
    result = HomogeneousTransformation.new(q_result, t_result)
    return result
  end
end

HomTran = HomogeneousTransformation
