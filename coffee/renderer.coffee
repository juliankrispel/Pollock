# the renderer is actually responsible for copying pixels
class SimpleRenderer extends Base
  
  getBrushData: (brush, context) ->
    x = brush.x()
    y = brush.y()
    s = brush.size()
    context.getImageData(x,y,s,s)

  alphablend: (src, dst, alpha) ->
    Math.round( alpha * src + (1 - alpha) * dst )

  avgblend: (src, dst) ->
    Math.round((src+dst)/2.0)

  scrblend: (src, dst) ->
    Math.round(255.0*(1-(1-src/255.0)*(1-dst/255.0)))

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

    if brush.type is "circle"
      x = 0
      y = 0
      cnt = brush.size() / 2
      i = 0
      y = 0

      while y < brush.size()
        x = 0

        while x < brush.size()
          dx = x - cnt
          dy = y - cnt
          d = Math.sqrt(dx * dx + dy * dy)
          alpha = (cnt - d) / cnt
          alpha = 0  if alpha < 0
          dstData.data[i]     = @alphablend(srcData.data[i], dstData.data[i], alpha)
          dstData.data[i + 1] = @alphablend(srcData.data[i + 1], dstData.data[i + 1], alpha)
          dstData.data[i + 2] = @alphablend(srcData.data[i + 2], dstData.data[i + 2], alpha)
          i += 4
          ++x
        ++y
    destination.putImageData dstData, brush.x(), brush.y()
    @
