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

  renderBrush: (brush, source, destination) ->
    srcContext = source.imca.getContext("2d")
    srcData = @getBrushData(brush, srcContext)
    dstData = @getBrushData(brush, destination)

    @compositeBlock srcData.data, dstData.data, @avgblend  if brush.type is "square"

    @compositeBlock srcData.data, dstData.data, @scrblend  if brush.type is "weird"

    if brush.type is "circle" or "scircle"
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
          i += 4
          ++x
        ++y
    destination.putImageData dstData, brush.x(), brush.y()
    @
