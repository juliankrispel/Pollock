# the renderer is actually responsible for copying pixels
class SimpleRenderer extends Base

  getBrushData: (brush, context) ->
    x = brush.x()
    y = brush.y()
    s = brush.size()
    context.getImageData(x,y,s,s)

  alphablend: (src, dst, alpha) ->
    alpha * src + (1 - alpha) * dst | 0

  avgblend: (src, dst) ->
    (src+dst)/2.0 | 0

  scrblend: (src, dst) ->
    255.0*(1-(1-src/255.0)*(1-dst/255.0)) | 0

  compositeBlock: (src, dst, bmode) ->
    for i in [0..src.length] by 4
      dst[i] = bmode(src[i],dst[i])
      dst[i+1] = bmode(src[i+1],dst[i+1])
      dst[i+2] = bmode(src[i+2],dst[i+2])
      dst[i+3] = 255
    @

  rgb2luminance : (RGB, i) ->
    0.299 * RGB[i] + 0.587 * RGB[i+1] + 0.114 * RGB[i+2]

  quickSortStep: (array, offset, length) ->
    pindex = getRandomInt(0,length-1)
    pivot = @rgb2luminance(array, offset+pindex*4)
    left  = new Uint8ClampedArray(length*4)
    right = new Uint8ClampedArray(length*4)
    li = 0
    ri = 0
    for i in [0..((length-1)*4)] by 4
      if @rgb2luminance(array, offset+i) < pivot
        left[li+0] = array[offset+i+0]
        left[li+1] = array[offset+i+1]
        left[li+2] = array[offset+i+2]
        left[li+3] = array[offset+i+3]
        li += 4
      else
        right[ri+0] = array[offset+i+0]
        right[ri+1] = array[offset+i+1]
        right[ri+2] = array[offset+i+2]
        right[ri+3] = array[offset+i+3]
        ri += 4
    if li > 0
      array.set( left.subarray(0,li-1), offset+0)
    if ri > 0
      array.set( right.subarray(0,ri-4), offset+li)

  renderBrush: (brush, source, destination) ->

    # get brush image data and background image data
    srcContext = source.imca.getContext("2d")
    srcData = @getBrushData(brush, srcContext)
    dstData = @getBrushData(brush, destination)

    switch brush.type

      when 'square' then @compositeBlock srcData.data, dstData.data, @avgblend
      when 'weird' then @compositeBlock srcData.data, dstData.data, @scrblend
      when 'circle', 'scircle'
        x = 0
        y = 0
        cnt = brush.size() / 2
        i = 0
        y = 0

        # take color of center pixel
        if brush.type is "scircle"
          midoff = (cnt+cnt*brush.size())*4
          R = srcData.data[midoff+0]
          G = srcData.data[midoff+1]
          B = srcData.data[midoff+2]

        while y < brush.size()
          x = 0

          while x < brush.size()
            dx = x - cnt
            dy = y - cnt
            d = Math.sqrt(dx * dx + dy * dy)
            alpha = (cnt - d) / cnt
            alpha = 0  if alpha < 0
            if brush.type is "circle"
              R = srcData.data[i+0]
              G = srcData.data[i+1]
              B = srcData.data[i+2]
            dstData.data[i]     = @alphablend(R, dstData.data[i], alpha)   # srcData.data[i+..]
            dstData.data[i + 1] = @alphablend(G, dstData.data[i + 1], alpha)
            dstData.data[i + 2] = @alphablend(B, dstData.data[i + 2], alpha)
            dstData.data[i + 3] = 255
            i += 4
            ++x
          ++y

      when 'sort'
        y = 0
        offset = 0
        while y < brush.size()
          @quickSortStep(dstData.data, offset, brush.size())
          offset += brush.size()*4
          ++y
    #/switch brush.type

    # write brush back to image
    destination.putImageData dstData, brush.x(), brush.y()
    @

   