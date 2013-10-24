class Helpers
  @squareDistanceBetweenVectors: (v1, v2)->
    x = v2[0]-v1[0]
    y = v2[1]-v1[1]
    x*x+y*y

  @multVector: (v, scalar) ->
    [v[0]*scalar, v[1]*scalar]

  @addVectors: (v1, v2)->
    [v1[0]+v2[0], v1[1]+v2[1]]

  @subVectors: (v1, v2) ->
    [v1[0]-v2[0], v1[1]-v2[1]]

  @normalizeVector: (v) ->
    length = @vecLength(v)
    [v[0]/length, v[1]/length]

  @vecLength: (v) ->
    Math.sqrt(v[0]*v[0]+v[1]*v[1])

  @dot: (v1, v2) ->
    v1[0]*v2[0]+v1[1]*v2[1]

  @reflectVector: (v, normal) ->
    v = @normalizeVector(v)
    normal = @normalizeVector(normal)
    @normalizeVector(@subVectors(@multVector(v, 2*@dot(v, normal)), v))

  @getNanoSec = ->
    time = process.hrtime()
    time[0] * 1e9 + time[1]

  @printVec: (v) ->
    "#{v[0]}, #{v[1]}"


module.exports = Helpers
