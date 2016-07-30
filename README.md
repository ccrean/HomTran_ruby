# HomogeneousTransformation

Homogeneous transformations are common in robotics, where each of the
bodies that make up the robot has a coordinate frame associated with
it.  In general, the coordinate frames for two different bodies will
have different orientations and different locations in space.  If you
have a vector that describes the location of a point relative to one
reference frame, the question arises of how to find a vector that
describes the location of the same point relative to a different
reference frame.  A homogeneous transformation provides a
straightforward way to perform the conversion.  See the usage
instructions below for more details.

## Installation

Add this line to your application's Gemfile:

    gem 'homogeneous_transformation'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install homogeneous_transformation

## Usage

To use the HomogeneousTransformation class in your program, include
the following line:

```
require 'homogeneous_transformation
```

The following typedef has bee provided for your convenience:

```
HomTran = HomogeneousTransformation
```

We will use it throughout the remainder of this readme for the sake of
brevity.

In order to initialize a HomogeneousTransformation, you need to create
a UnitQuaternion object that represents the HomTran's orientation, and
you need to provide a vector that gives the HomTran's location in
space.  The [unit_quaternion
gem](https://rubygems.org/gems/unit_quaternion) is required
automatically when you require the homogeneous_transformation gem.

```
q = UnitQuaternion.fromAngleAxis(Math::PI/2, Vector[1,1,1])
t = Vector[1,2,3]
frame = HomTran.new(q, t)
=> #<HomogeneousTransformation:0x00000002595a68 @q=(0.7071067811865476, Vector[0.408248290463863, 0.408248290463863, 0.408248290463863]), @t=Vector[1, 2, 3]>
```

You can recover the orientation or translation for a given HomTran
object using the following methods:

```
frame.getQuaternion()
=> (0.7071067811865476, Vector[0.408248290463863, 0.408248290463863, 0.408248290463863])

frame.getTranslation()
=> Vector[1, 2, 3]
```

You can get the 4x4 matrix representation of the HomTran as follows:

```
frame.getMatrix()
=> Matrix[[0.3333333333333335, -0.24401693585629253, 0.9106836025229592, 1], [0.9106836025229592, 0.3333333333333335, -0.24401693585629253, 2], [-0.24401693585629253, 0.9106836025229592, 0.3333333333333335, 3], [0, 0, 0, 1]]
```

You can also set the orientation, translation, or matrix
representation for an existing HomTran object using the setQuaternion,
setTranslation, and setMatrix methods.

Now for the useful part.  If you have a HomTran object that describes
the location of a child frame relative to its parent frame, and you
have a vector expressed in the child frame, you can get the
corresponding vector in the parent frame using the transform method:

```
v = Vector[1, 2, 3]
frame.transform(v)
=> Vector[3.577350269189626, 2.8452994616207485, 5.577350269189626]
```

If you want the inverse of a HomTran, for example, to transform a
vector from its representation in the parent frame to its
representation in the child frame, you can use the inverse method:

```
frame.inverse()
=> #<HomogeneousTransformation:0x000000025a7a10 @q=(0.7071067811865476, Vector[-0.408248290463863, -0.408248290463863, -0.408248290463863]), @t=Vector[-1.4226497308103743, -3.154700538379252, -1.4226497308103747]>
```

Finally, to compose two transformations described by HomTran objects,
use the multiplication operator:

```
frame2 = HomTran.new(UnitQuaternion.new(1,2,3,4), Vector[1, 0, 0])
=> #<HomogeneousTransformation:0x000000025bc820 @q=(0.18257418583505536, Vector[0.3651483716701107, 0.5477225575051661, 0.7302967433402214]), @t=Vector[1, 0, 0]>

frame2 * frame
#<HomogeneousTransformation:0x00000002334648 @q=(-0.5417209483763564, Vector[0.25819888974716115, 0.6109051323707207, 0.5163977794943223]), @t=Vector[2.7999999999999994, 2.0, 2.5999999999999996]>
```

Note that for any frame, frame * frame.inverse() (or frame.inverse() *
frame) must yield the identity transformation:

```
result = frame * frame.inverse()
=> #<HomogeneousTransformation:0x000000024c0a20 @q=(1.0, Vector[0.0, 0.0, 0.0]), @t=Vector[-4.440892098500626e-16, -4.440892098500626e-16, -8.881784197001252e-16]>

result.getMatrix()
=> Matrix[[1.0, 0.0, 0.0, -4.440892098500626e-16], [0.0, 1.0, 0.0, -4.440892098500626e-16], [0.0, 0.0, 1.0, -8.881784197001252e-16], [0, 0, 0, 1]]
```

## Advanced Features

The initialize, setQuaternion, and setTranslation all accept two
additional parameters: a HomTran object called rel_to, and a boolean
value called local.  The value of local is only used if rel_to is not
nil.

By default, when initializing a HomTran object, or setting its
orientation or position, this class assumes that the transformation is
being specified relative to the "global" or "inertial" reference
frame, or some other common parent frame.  However, if a value for
rel_to is passed to any of the methods mentioned above, the
orientation and rotation are specified relative to the rel_to frame.

If local is true (its default value), then the location and
orientation should be specified in the rel_to frame.  If local is
false, they should be specified in the "global" (or rel_to's parent)
frame.

Perhaps an example will clarify things.  Consider the following frame:

```
frame1 = HomTran.new(UnitQuaternion.fromAngleAxis(Math::PI/2, Vector[0, 0, 1]), Vector[1, 0, 0])
=> #<HomogeneousTransformation:0x00000002451490 @q=(0.7071067811865476, Vector[0.0, 0.0, 0.7071067811865475]), @t=Vector[1, 0, 0]>
```

The frame is rotated by PI/2 radians about the global z-axis, and
offset by 1 unit along the global x-axis.  Next, say we want to create
a new frame with the same orientation, but offset by another 1 unit
along the global z-axis.  We could create such a frame as follows:

```
frame2 = HomTran.new(UnitQuaternion.new(), Vector[1, 0, 0], frame1, false)
=> #<HomogeneousTransformation:0x000000025d62c0 @q=(0.7071067811865476, Vector[0.0, 0.0, 0.7071067811865475]), @t=Vector[2, 0, 0]>

frame2.getTranslation()
=> Vector[2, 0, 0]
```

Notice that we specified [1, 0, 0] for frame2's translation, but,
since we passed in frame1 for the rel_to argument, the resulting
translation is [1, 0, 0] plus frame1's translation.  Also, notice that
local was false, so we translated frame2 along the global x-axis.
Since frame1 is rotated by PI/2 about the global z-axis, frame2's
x-axis is aligned with the global y-axis.  So, if we create a new
frame similar to frame2, but with local = true, we will translate it
along frame1's x-axis, which aligns with the global y-axis.  So, the
resulting translation should be [1, 1, 0].  Let's try it:

```
frame3 = HomTran.new(UnitQuaternion.new(), Vector[1, 0, 0], frame1, true)
=> #<HomogeneousTransformation:0x000000025e7228 @q=(0.7071067811865476, Vector[0.0, 0.0, 0.7071067811865475]), @t=Vector[1.0000000000000002, 1.0, 0.0]>

frame3.getTranslation()
=> Vector[1.0000000000000002, 1.0, 0.0]
```

Exactly what we expected!

A note of caution: when you create a HomTran using the rel_to
parameter, this class calculates the resulting offset relative to the
"global" frame and returns the corresponding HomTran.  So, any
subsequent changes to the rel_to frame will not affect the child
frame, unless you update it manually using the setQuaternion or
setTranslation methods with the rel_to parameter.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
