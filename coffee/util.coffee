lastTime = 0
vendors = ["webkit", "moz"]
x = 0

while x < vendors.length and not window.requestAnimationFrame
  window.requestAnimationFrame = window[vendors[x] + "RequestAnimationFrame"]
  window.cancelAnimationFrame = window[vendors[x] + "CancelAnimationFrame"] or window[vendors[x] + "CancelRequestAnimationFrame"]
  ++x

unless window.requestAnimationFrame
  window.requestAnimationFrame = (callback, element) ->
    currTime = new Date().getTime()
    timeToCall = Math.max(0, 16 - (currTime - lastTime))
    id = window.setTimeout
    (->
      callback currTime + timeToCall
      , timeToCall
    )
    lastTime = currTime + timeToCall
    id

unless window.cancelAnimationFrame
  window.cancelAnimationFrame = (id) ->
    clearTimeout id

# Get a random number
getRandom = (lo, hi) ->
  Math.random() * (hi - lo) + lo

# Return True on a @p percent chance
percentTrue = (p) ->
  Math.random() < (p / 100.0)

# Returns a random integer
getRandomInt = (lo, hi) ->
  Math.round getRandom(lo, hi)

# Extend function taken from underscore
extend = (obj) ->
  for source in Array::slice.call(arguments, 1)
    if source
      for prop of source
        obj[prop] = source[prop]
  obj

useArrayAsDirectory = (obj, paths) ->
  # Because it can be declared as a string
  # 'brush.size.value': 'brushMinSize' we have
  # to split up the path and loop over it 
  # to find the variable.
  publicMember = obj
  # Don't loop over an array smaller than 1
  # don't loop over last item in array which needs
  # to be passed on to publish
  for path in paths 
    # Catch invalid variable names
    if(!publicMember[path])
        throw new Error('object ' + publicMember.constructor.name + ' has no member called ' + path)
    publicMember = publicMember[path]
  publicMember

