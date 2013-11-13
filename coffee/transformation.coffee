class Mat3
  # 012
  # 345
  # 678
  constructor: (init) ->
    if init is undefined
    	@_m = new Float32Array([1,0,0,0,1,0,0,0,1]);
    else
    	@_m = new Float32Array(init)

  multVec: (v) ->
    r=new Float32Array([0,0,0]);
    r[0] = @_m[0]*v[0]+@_m[1]*v[1]+@_m[2]*v[2];
    r[1] = @_m[4]*v[0]+@_m[5]*v[1]+@_m[6]*v[2];
    r[2] = @_m[7]*v[0]+@_m[8]*v[1]+@_m[9]*v[2];
    r

   multVecH(v) ->
     r = multVec(v)
     r[0]=r[0]/r[2]
     r[1]=r[1]/r[2]
     r[2]=undefined
     r

  multMat: (mat) ->
    m = new Mat3()
    m._m[0] = @_m[0]*mat._m[0]+@_m[1]*mat._m[3]+@_m[2]*mat._m[6];
    m._m[1] = @_m[0]*mat._m[1]+@_m[1]*mat._m[4]+@_m[2]*mat._m[7];
    m._m[2] = @_m[0]*mat._m[2]+@_m[1]*mat._m[5]+@_m[2]*mat._m[8];
    m._m[3] = @_m[3]*mat._m[0]+@_m[4]*mat._m[3]+@_m[5]*mat._m[6];
    m._m[4] = @_m[3]*mat._m[1]+@_m[4]*mat._m[4]+@_m[5]*mat._m[7];
    m._m[5] = @_m[3]*mat._m[2]+@_m[4]*mat._m[5]+@_m[5]*mat._m[8];
    m._m[6] = @_m[6]*mat._m[0]+@_m[7]*mat._m[3]+@_m[8]*mat._m[6];
    m._m[7] = @_m[6]*mat._m[1]+@_m[7]*mat._m[4]+@_m[8]*mat._m[7];
    m._m[8] = @_m[6]*mat._m[2]+@_m[7]*mat._m[5]+@_m[8]*mat._m[8];
    m

  determinant: () ->
    @_m[0]*@_m[4]*@_m[8]+@_m[1]*@_m[5]*@_m[6]+
    @_m[2]*@_m[3]*@_m[7]-@_m[2]*@_m[4]*@_m[6]-
    @_m[1]*@_m[3]*@_m[8]-@_m[0]*@_m[5]*@_m[7]

  # 012 abc
  # 345 def
  # 678 ghi
  inverse: () ->
    d = 1.0/determinant()
    m = new Mat3()
    m._m[0] = d*(@_m[4]*@_m[8]-@_m[5]*@_m[7])
    m._m[1] = d*(@_m[2]*@_m[7]-@_m[1]*@_m[8])
    m._m[2] = d*(@_m[1]*@_m[5]-@_m[2]*@_m[4])
    m._m[3] = d*(@_m[5]*@_m[6]-@_m[3]*@_m[8])
    m._m[4] = d*(@_m[0]*@_m[8]-@_m[2]*@_m[6])
    m._m[5] = d*(@_m[2]*@_m[3]-@_m[0]*@_m[5])
    m._m[6] = d*(@_m[3]*@_m[7]-@_m[4]*@_m[6])
    m._m[7] = d*(@_m[1]*@_m[6]-@_m[0]*@_m[7])
    m._m[8] = d*(@_m[0]*@_m[4]-@_m[1]*@_m[3])
    m

  createTranslation: (tx, ty) ->
    new Mat3([0,0,tx,0,0,ty,0,0,1])

  createScale: (sx, sy) ->
    new Mat3([sx,0,0,0,sy,0,0,0,1])

  createRotation: (angle) ->
    c=Math.cos(angle)
    s=Math.sin(angle)
    new Mat3([c,-s,0,s,c,0,0,0,1])

  # translates by the translation vector (tx,ty)
  translate: (tx, ty) ->
    createTranslation(tx,ty).multMat(@)

  # scales by (sx,sy) around a point P=(px,py)
  scale: (px, py, sx, sy) ->
    createTranslation(px,py).multMat(
    	createScale(sx,sy).multMat(
    		createTranslation(-tx,-ty).multMat(@)
    	)
    )

  # rotates around a point
  rotate: (px, py, angle) ->
    createTranslation(px,py).multMat(
    	createRotation(angle).multMat(
    		createTranslation(-tx,-ty).multMat(@)
    	)
    )

class ImageTransform
  transformImage: (image, transformation, width, height) ->
  
  img = {
    width: width
    height: height
    data: new Uint8ClampedArray(width*height*4)
  }

  dstoff=0
  y=0
  while y<height
  	x=0
    while x<width
    	pos = transformation.multVecH([x,y,1])
        # nearest neighbour
        offset = (Math.round(pos.x) + Math.round(pos.y)*image.width)*4
        img.data[dstoff++] = image.data[offset+0]
        img.data[dstoff++] = image.data[offset+1]
        img.data[dstoff++] = image.data[offset+2]
        img.data[dstoff++] = image.data[offset+3]
    	++x
    ++y

