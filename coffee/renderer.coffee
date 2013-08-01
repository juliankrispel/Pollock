# the renderer is actually responsible for copying pixels
class SimpleRenderer extends Base
  blendBlock: (src, dst) ->
    i = 0

    while i < src.length

      # simple blend: use dst[i] for everyone for a interesting effect
      dst[i] = (src[i] + dst[i]) / 2
      dst[i + 1] = (src[i + 1] + dst[i + 1]) / 2
      dst[i + 2] = (src[i + 2] + dst[i + 2]) / 2
      i += 4

  getBrushData: (brush, context) ->
    context.getImageData Math.round(brush.x), 
      Math.round(brush.y), 
      Math.round(brush.size), 
      Math.round(brush.size)

  blend: (src, dst, alpha) ->
    Math.round alpha * src + (1 - alpha) * dst

  renderBrush: (brush, source, destination) ->
    srcContext = source.imca.getContext("2d")
    srcData = @getBrushData(brush, srcContext)
    dstData = @getBrushData(brush, destination)
    @blendBlock srcData.data, dstData.data  if brush.shape is "square"
    if brush.shape is "circle"
      x = 0
      y = 0
      cnt = brush.size / 2
      i = 0
      y = 0

      while y < brush.size
        x = 0

        while x < brush.size
          dx = x - cnt
          dy = y - cnt
          d = Math.sqrt(dx * dx + dy * dy)
          alpha = (cnt - d) / cnt
          alpha = 0  if alpha < 0
          r = @blend(srcData.data[i], dstData.data[i], alpha)
          g = @blend(srcData.data[i + 1], dstData.data[i + 1], alpha)
          b = @blend(srcData.data[i + 2], dstData.data[i + 2], alpha)
          dstData.data[i] = r
          dstData.data[i + 1] = g
          dstData.data[i + 2] = b
          i += 4
          ++x
        ++y
    destination.putImageData dstData, brush.x, brush.y
    @
