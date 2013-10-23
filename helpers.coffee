class Helpers
  @squareDistanceBetweenVectors: (v1, v2)->
    x = v2[0]-v1[0]
    y = v2[1]-v1[1]
    x*x+y*y

  @multVector: (v, scalar) ->
    [v[0]*scalar, v[1]*scalar]

  @addVectors: (v1, v2)->
    [v1[0]+v2[0], v1[1]+v2[1]]


module.exports = Helpers