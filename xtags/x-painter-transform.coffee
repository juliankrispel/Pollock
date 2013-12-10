PI = Math.PI

radiansToDegrees = (radians) ->
    return radians * (180 / Math.PI);

# Taken from http://stackoverflow.com/a/1480137/1333809
cumulativeOffset = (element) ->
    top = 0
    left = 0

    while element
        top += element.offsetTop  || 0
        left += element.offsetLeft || 0
        element = element.offsetParent

    { top: top, left: left }

template = '<div data-type="translate" class="transformation-handle__translate"></div>
  <div data-type="origin" class="anchorpoint"></div>
  <div data-type="rotate" class="transformation-handle transformation-handle__top-left tranformation-handle__rotate"><div data-type="scale" class="transformation-handle__scale"></div></div>
  <div data-type="rotate" class="transformation-handle transformation-handle__top-right transformation-handle__rotate"><div data-type="scale" class="transformation-handle__scale"></div></div>
  <div data-type="rotate" class="transformation-handle transformation-handle__bottom-left transformation-handle__rotate"><div data-type="scale" class="transformation-handle__scale"></div></div>
  <div data-type="rotate" class="transformation-handle transformation-handle__bottom-right transformation-handle__rotate"><div data-type="scale" class="transformation-handle__scale"></div></div>'

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

matrixToCss = (m) ->
  # Mat3 is row-oriented, the CSS Matrix is column-oriented
  # and has the last rows cut off, getting a correct CSS Matrix
  # involves reordering the matrix
  [m[0], m[3], m[1], m[4], m[2], m[5]]

transformMatrix = (t)->
  # get dot product of all matrices in the correct 
  # order ( scale * rotate * translate )
  t['translate'].multMat(t['rotate'].multMat(t['scale']))

transformCoordinates = (coord, matrix) ->
  v = [
    coord[0]
    coord[1]
    1
  ]
  matrix.multVec(v)

getCenterPoint = (tValues, width, height) ->
  [(tValues['scale'][0]*width/2),
  (tValues['scale'][1]*height/2)]

getAngleBetweenVectors = (a, b) ->
  Math.acos getDotProduct(a, b) / (getVectorLength(a) * getVectorLength(b))

getVectorOrientation = (a, b, c) ->
  direction = (a[0]-c[0]) * (b[1]-c[1]) - (a[1]-c[1]) * (b[0]-c[0])
  if direction > 0
    -1
  else if direction < 0
    1
  else
    0

prefixes = ["-moz-", "-webkit-", "-ms-", "-khtml-", "-o-", ""]

xtag.register "x-painter-transform",
  lifecycle:
    created: ->
      @mousedown = false

      @container = document.createElement('div')
      @container.className = 'transformation-container'
      @container.innerHTML = @innerHTML
      @innerHTML = template

      @appendChild(@container)

      @handles = {
        'transformation-handle__top-left': [0, 0]
        'transformation-handle__top-right': [@container.offsetWidth, 0]
        'transformation-handle__bottom-right': [@container.offsetWidth, @container.offsetHeight]
        'transformation-handle__bottom-left': [0, @container.offsetHeight]
      }

      @t = {
        'rotate': new Mat3
        'scale': new Mat3
        'translate': new Mat3
      }

      @matrix = new Mat3
      @inverseMatrix = @matrix.inverse()

      @tValues = {
        rotate: 0
        scale: [1, 1]
        translate: [0, 0]
      }

      @dataset.width = @container.offsetWidth
      @dataset.height = @container.offsetHeight

      #set default anchorPoint
      @anchorPoint = [@dataset.width/2, @dataset.height/2]
      @querySelector('.anchorpoint').style.setProperty('left', @anchorPoint[0] + @tValues['translate'][0])
      @querySelector('.anchorpoint').style.setProperty('top', @anchorPoint[1] + @tValues['translate'][1])
      @transform()

      # bind to window for debugging - 
      # TODO: Remove as soon as this is more or lessa working
      window.el = @

  methods:
    transform: ()->
      @querySelector('.anchorpoint').style.setProperty('left', @anchorPoint[0] + @tValues['translate'][0])
      @querySelector('.anchorpoint').style.setProperty('top', @anchorPoint[1] + @tValues['translate'][1])

      @matrix = transformMatrix(@t)
      @inverseMatrix = @matrix.inverse()
      css = "matrix(#{matrixToCss(@matrix._m)})"

      for handle of @handles
        coord = transformCoordinates(@handles[handle], @matrix)
        @querySelector(".#{handle}").style.setProperty('left', coord[0])
        @querySelector(".#{handle}").style.setProperty('top', coord[1])

      @container.style.setProperty 'background-color', 'red'
      for prefix in prefixes
        @container.style.setProperty("#{prefix}transform", css)

    processMouseMovement: (type, fromX, fromY, toX, toY, isShiftPressed) ->

      #Convert mouse coordinates to the picture plane
      start = @inverseMatrix.multVec([fromX, fromY, 1])
      startX = start[0]
      startY = start[1]

      end = @inverseMatrix.multVec([toX, toY, 1])
      endX = end[0]
      endY = end[1]

      switch type
        when 'origin'
          @anchorPoint[0] += toX-fromX
          @anchorPoint[1] += toY-fromY
          @translateEl(fromX-toX, fromY-toY)
          @translateEl(toX-fromX, toY-fromY)

        when 'scale'
          origin = @anchorPoint
          sx = (endX - origin[0])/(startX - origin[0])
          sy = (endY - origin[1])/(startY - origin[1])

          if(isShiftPressed)
            if(sx && sy > 1)
              if(sx > sy) 
                sy = sx
              else 
                sx = sy
            else
              if(sx < sy) 
                sy = sx
              else 
                sx = sy

          @scaleEl(sx, sy)

        when 'rotate'
          a = @anchorPoint
          b = [startX, startY]
          c = [endX, endY]

          direction = getVectorOrientation(a,b,c)

          vektorA = [b[0] - a[0], b[1] - a[1]]
          vektorB = [c[0] - a[0], c[1] - a[1]]

          angle = radiansToDegrees(getAngleBetweenVectors(vektorA, vektorB))

          if(direction != 0)
            @rotateEl(direction*angle)
        when 'translate'
          # translation is carried out in mouse coordinate system
          @translateEl(toX-fromX, toY-fromY)

    translateEl: (x, y) ->
      @tValues['translate'][0] += x
      @tValues['translate'][1] += y
      m = new Mat3
      @t['translate'] = m.translate(@tValues['translate'][0], @tValues['translate'][1])
      @transform()

    scaleEl: (sx, sy) ->
      @tValues['scale'][0]*=sx
      @tValues['scale'][1]*=sy
      m = new Mat3
      @t['scale'] = m.scale(@anchorPoint[0], @anchorPoint[1], @tValues['scale'][0], @tValues['scale'][1])
      @transform()

    rotateEl: (angle, px, py) ->
      px = @anchorPoint[0]
      py = @anchorPoint[1]
      @t['rotate'] = @t['rotate'].rotate(px, py, angle)
      @transform()

  events: 
    'mousedown': (e)->
      if(e.target.dataset.type)
        @mousedown = {
          type: e.target.dataset.type
          e: e
        }

    'mousemove': (e)->
      if(@mousedown)
        @processMouseMovement(@mousedown.type, @mousedown.e.pageX, @mousedown.e.pageY, e.pageX, e.pageY, e.shiftKey)
        @mousedown.e = e

    'mouseup': (e)->
      @mousedown = false
