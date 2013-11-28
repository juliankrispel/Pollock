PI = Math.PI
transformImage = (el, obj) ->
  css = ""
  string = ""
  for x of obj
    transformString = obj[x].join(",")
    string += x + "(" + transformString + ")"
  for i of prefixes
    el.style.setProperty prefixes[i] + "transform", string, "important"

getDotProduct = (a, b) ->
  n = 0
  lim = Math.min(a.length, b.length)
  i = 0

  while i < lim
    n += a[i] * b[i]
    i++
  n

getVectorLength = (v) ->
  sum = 0
  i = 0

  while i < v.length
    sum += v[i] * v[i]
    i++
  Math.sqrt sum

getAngleBetweenVectors = (a, b) ->
  Math.acos getDotProduct(a, b) / (getVectorLength(a) * getVectorLength(b))

getVectorOrientation = (a, b, c) ->
  direction = (a[0] - c[0]) * (b[1] - c[1]) - (a[1] - c[1]) * (b[0] - c[0])
  if direction > 0
    "right"
  else if direction < 0
    "left"
  else if direction is 0
    "none"
  else
    throw (new Error(""))

prefixes = ["-moz-", "-webkit-", "-ms-", "-khtml-", "-o-", ""]

defaultMatrix = [1,0,0
                1,0,0,
                0,0,1]

multVect = (v,a,b,c) ->
  v*a + v*b + v*c

xtag.register "x-painter-transform",
  lifecycle:
    created: ->
      @el = document.createElement('div')
      @el.className = 'transform-object'

      #set default anchorPoint
      @anchorPoint = [@el.offsetWidth/2, @el.offsetHeight/2]

      @m = defaultMatrix
      @t = {
        'rotate': new Mat3
        'scale': new Mat3
        'translate': new Mat3
      }

      @appendChild(@el)
      window.el = @

  methods:
    transform: ()->
      css = "matrix(#{@getTransformedCSSMatrix()})"
      @el.style.setProperty 'background-color', 'red'
      for prefix in prefixes
        @el.style.setProperty("#{prefix}transform", css)

    getTransformedCSSMatrix: () ->
      # get dot product of all matrices in the correct 
      # order ( scale * rotate * translate )
      m = @t['translate'].multMat(@t['rotate'].multMat(@t['scale']))._m

      # Mat3 is row-oriented, the CSS Matrix is column-oriented
      # and has the last rows cut off, getting a correct CSS Matrix
      # involves reordering the matrix
      [m[0], m[3], m[1], m[4], m[2], m[5]]


    translateMatrix: (x, y) ->
      if(!x || !y)
        throw new Error 'translateMatrix() - x and y are required'

      @t['translate'] = @t['translate'].translate(x,y)
      @transform()

    scaleMatrix: (sx, sy, px, py) ->
      if(!sx || !sy)
        throw new Error 'scaleMatrix() - sx and sy are required'

      px = px || @anchorPoint[0]
      py = py || @anchorPoint[1]
      @t['scale'] = @t['scale'].scale()
      @transform()

    rotateMatrix: (angle, px, py) ->
      if(!angle)
        throw new Error 'scaleMatrix() - sx and sy are required'

      px = px || @anchorPoint[0]
      py = py || @anchorPoint[1]
      @t['rotate'] = @t['rotate'].rotate(px, py, angle)
      @transform()
