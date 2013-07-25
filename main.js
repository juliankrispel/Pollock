(function() {
    var lastTime = 0;
    var vendors = ['webkit', 'moz'];
    for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
        window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
        window.cancelAnimationFrame =
          window[vendors[x]+'CancelAnimationFrame'] || window[vendors[x]+'CancelRequestAnimationFrame'];
    }

    if (!window.requestAnimationFrame)
        window.requestAnimationFrame = function(callback, element) {
            var currTime = new Date().getTime();
            var timeToCall = Math.max(0, 16 - (currTime - lastTime));
            var id = window.setTimeout(function() { callback(currTime + timeToCall); },
              timeToCall);
            lastTime = currTime + timeToCall;
            return id;
        };

    if (!window.cancelAnimationFrame)
        window.cancelAnimationFrame = function(id) {
            clearTimeout(id);
        };
}());

var Brush = {
    x : 0,
    y : 0,
    size : 0,
    shape : 0,
    setState : function(bx,by,bsize,bform) {
        this.x = bx;
        this.y = by;
        this.size = bsize;
        this.bform = bform;
    }
}

// ImageSource abstracts a set of images, accesible by index
// width and height of ImageSource correspond to 
// the maximal width and height of images it contains
var ImageSource = function() {
    this.images = Array();
    this.W = 0;
    this.H = 0;

    this.getWidth = function() {};
    this.getHeight = function() {};
    this.getNumImages = function() { return 0; };
    this.getImage = function(index) {};
    
    this.addImage = function(img) {
       this.images.push(img);
       if (img.width > this.W) this.W=img.width;
       if (img.height > this.H) this.H=img.height;
    };
};

// a Painter is responsible for what is going to get drawn where
var Painter = function() {
    this.imgSrc = null;
    this.setImageSource = function(input) {  this.imgSrc = input;  };
    // the Painter interface
    this.init   = function() {};
    this.paint  = function(renderer, destination) {};
    this.update = function() {};
}


// the Movingsquarepainter is a simple panter that just copies
// rectangular parts from multiple input images to a destination image
var MovingSquarePainter = _(Painter).extend({
    myBrushes : null,
    N : 10,                 // number of images
    
    setBrushes: function(num) { this.N = num; this.init(); },
    
    // implements painter interface
    init : function() {
        // initialize brushes
        this.myBrushes = [];
        for (i=0;i<this.N;++i) {
            this.myBrushes.push(new Brush());
        }
        _(this.myBrushes).each(function(brush) {
            brush.dx = getRandom(0,imgSrc.getWidth()-1);
            brush.dy = getRandom(0,imgSrc.getHeight()-1);
            brush.setState(0,0,5,'square');
        });
    },

    paint : function(renderer, destination) {
        imgIndex = 0;
        // render each brush, cycling through input images
        _(this.myBrushes).each(function(brush) {
            renderer.renderBrush(brush, imgSrc.getImage(imgIndex), destination);
            imgIndex = imgIndex + 1;
            if (imgIndex == imgSrc.getNumImages) {
               imgIndex = 0;
            }
        });
    },

    update : function() {
        // update the state of each brush
        _(this.myBrushes).each(function(brush)
        {
            // move brush within image area limits
            this.x = this.x + this.dx;
            if (this.x < 0) { this.x = 0; }
            if (this.x > imgSrc.getWidth()) { this.x = imgSrc.getWidth(); }
            this.y = this.y + this.dy;            
            if (this.y < 0) { this.y = 0; }
            if (this.y > imgSrc.getHeight()) { this.x = imgSrc.getHeight(); }
            
            //Reset brush every now and then
            if(percentTrue(30))
            {
                brush.size=getRandom(3,7);
            }

            //Respawn every now and then
            if(percentTrue(.3))
            {
                brush.x = getRandom(1,imgSrc.getWidth());
                brush.y = getRandom(1,imgSrc.getHeight());
            }

            //Change direction every now and then
            if(percentTrue(80)) {
                brush.dx = getRandomInt(-1, 1) * (brush.size/2);
                brush.dy = getRandomInt(-1, 1) * (brush.size/2);
            }
        });
    }
});

var ImageLoader = function(imageFiles, callback){
    var images = [];
    for(var i = 0; i < imageFiles.length; i++){
        var img = new Image();
        img.onload = function(){
            images.push(img);

            // Call callback when done loading images and pass images as argument
            if(images.length == imageFiles.length){
                callback(images);
            }
        }        
        img.src = imageFiles[i];
    }
};

// the renderer is actually responsible for copying pixels

var SimpleRenderer = function(){

   this.composite = function(src, dst, mode)
   {
      for (var i=0; i<src.length; i+=4)
      {
         // just copy for now
         dst[i] = src[i];
         dst[i+1] = src[i+1];
         dst[i+2] = src[i+2];
      }
   },
   
   this.renderBrush = function (brush, source, destination) {
     if (brush.shape=='square') 
     {
        var srcData = source.getImageData(brush.x, brush.y, brush.size, brush.size);
        var destImageData = this.canvas.getImageData(brush.x, brush.y, brush.size, brush.size);
        composite(imageData.data, destImageData.data, 'copy');
        destination.putImageData(imageData, this.x, this.y);
     }
   }
};

var MainLoop = function(images){
   
    imgSource = new ImageSource();
    for(i=0;i<images.length;++i)
        imgSource.addImage(images[i]);

    myPainter = new MovingSquarePainter();
    myPainter.setImageSource( ImageSource );
    
    myRenderer = new SimpleRenderer();

    // - start main loop
    window.requestAnimationFrame(function(){
       myPainter.paint(myRenderer, dstCanvas);
       myPainter.update();
    });
};

var dstCanvas = null;

// main application
var StartApp = function(renderTarget){
    dstCanvas = renderTarget;
    ImageLoader( new Array("img/01.jpg","img/02.jpg","img/03.jpg","img/04.jpg"), MainLoop );
};

StartApp(document.getElementById('canvas'));
