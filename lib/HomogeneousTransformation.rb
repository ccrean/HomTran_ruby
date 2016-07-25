require_relative 'homogeneous_transformation/version'
require 'unit_quaternion'
require 'matrix'

class HomogeneousTransformation
  def initialize(q = UnitQuaternion.new(1, 0, 0, 0),
                 translation = Vector[0, 0, 0])
    @q = q
    @t = translation
  end

  def getQuaternion()
    return @q
  end

  def getTranslation()
    return @t
  end
end

HomTran = HomogeneousTransformation
