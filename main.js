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

// ----------------------- utility

var getRandom = function(lo,hi) {
    return Math.random()*(hi-lo)+lo;
}

var percentTrue = function(p) {
    return (Math.random() < (p/100.0))
}

var getRandomInt = function(lo,hi)
{
    Math.round(getRandom(lo,hi));
}

// ---------------------------------


var Brush = {
    createNew : function() {
        var brush={};
        brush.x = 0;
        brush.y = 0;
        brush.size = 0;
        brush.shape = 0;
        brush.setState = function(bx,by,bsize,bform) {
            this.x = bx;
            this.y = by;
            this.size = bsize;
            this.shape = bform;
        }
        return brush;
    }
}

// ImageSource abstracts a set of images, accesible by index
// width and height of ImageSource correspond to 
// the maximal width and height of images it contains
var ImageSource = {
    createNew : function(){
        var imgSrc = {};
        imgSrc.images = Array();
        imgSrc.W = 0;
        imgSrc.H = 0;
        imgSrc.setSize = function(width,height) {
            this.W = width;
            this.H = height;
        }
        imgSrc.getNumImages = function() { return this.images.length; };
        imgSrc.getImage = function(index) { return this.images[index]; };
        imgSrc.addImage = function(img) {
           this.images.push(img);
        };

        return imgSrc;
    }
};

// a Painter is responsible for what is going to get drawn where
// this object just defines the interface
var Painter = {
    createNew: function() {
        var painter = {};
        painter.imgSrc = null;
        painter.setImageSource = function(input) {  this.imgSrc = input;  };
        // the Painter interface
        painter.init   = function() {};
        painter.paint  = function(renderer, destination) { };
        painter.update = function() {};
        return painter;
    }
}


// the Movingsquarepainter is a simple panter that just copies
// rectangular parts from multiple input images to a destination image
var MovingSquarePainter =  { 
    createNew: function() {
        var painter = Painter.createNew();
        painter.myBrushes = null;
        painter.N = 10;

        painter.setBrushes = function(num) { this.N = num; this.init(); },

        // implements painter interface
        // ------------------------------- init
        painter.init = function() {
            // initialize brushes
            this.myBrushes = [];
            for (i=0;i<this.N;++i) { 
                this.myBrushes.push(Brush.createNew()); 
                this.myBrushes[i].dx = 1;
                this.myBrushes[i].dy = 1;
                this.myBrushes[i].setState(
                    getRandom(0,this.imgSrc.W-1),
                    getRandom(0,this.imgSrc.H-1),
                    5,'square');
            }
        };
        // ------------------------------- paint
        painter.paint = function(renderer, dest) {
            var imgIndex = 0;
            // render each brush, cycling through input images
            for (i=0;i<this.N;++i)
            {
                var src = this.imgSrc.getImage(imgIndex);
                renderer.renderBrush(this.myBrushes[i], src , dest);
                imgIndex = imgIndex + 1;
                if (imgIndex == this.imgSrc.getNumImages()) {
                   imgIndex = 0;
                }
            }
        };
        // ------------------------------- update

       painter.update = function() {
            // update the state of each brush
            for (i=0;i<this.N;++i)
            {
                var brush=this.myBrushes[i];
                // move brush within image area limits
                brush.x = brush.x + brush.dx;
                if (brush.x < 0) { brush.x = 0; }
                if (brush.x > this.imgSrc.W) { brush.x = this.imgSrc.W; }
                brush.y = brush.y + brush.dy;            
                if (brush.y < 0) { brush.y = 0; }
                if (brush.y > this.imgSrc.W) { brush.y = this.imgSrc.H; }
                
                //Reset brush every now and then
                if(percentTrue(30))
                {
                    brush.size=getRandomInt(3,7);
                }

                //Respawn every now and then
                if(percentTrue(.3))
                {
                    brush.x = getRandom(1,this.imgSrc.W);
                    brush.y = getRandom(1,this.imgSrc.H);
                }

                //Change direction every now and then
                if(percentTrue(80)) {
                    brush.dx = getRandom(-1, 1) * (brush.size/2);
                    brush.dy = getRandom(-1, 1) * (brush.size/2);
                }
            }
        };

        return painter;
    }
};



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

var SimpleRenderer = {

    createNew : function() {
        var renderer = {};
        renderer.composite = function(src, dst, mode)
        {
              for (var i=0; i<src.length; i+=4)
              {
                 // just copy for now
                 dst[i] = src[i];
                 dst[i+1] = src[i+1];
                 dst[i+2] = src[i+2];
              }
        };

        renderer.renderBrush = function (brush, source, destination) 
        {
            if (brush.shape=='square') 
            {
                var srcData = source.getImageData(brush.x, brush.y, brush.size, brush.size);
                var destData = destination.getImageData(brush.x, brush.y, brush.size, brush.size);
                this.composite(srcData.data, destData.data, 'copy');
                destination.putImageData(destData, brush.x, brush.y);
            }
        }

        return renderer;
    }
};

var MainLoop = function(images){
   
    var imgSource = ImageSource.createNew();
    imgSource.setSize(images[0].width, images[0].height);
    for(i=0;i<images.length;++i)
    {
        var imca    = document.createElement('canvas');
        imca.width  = images[i].width;
        imca.height = images[i].height;
        var context = imca.getContext('2d');
        context.drawImage (images[i],0,0)
        imgSource.addImage(context);
    }

    myPainter = MovingSquarePainter.createNew();
    myPainter.setImageSource( imgSource );
    myPainter.init();

    myRenderer = SimpleRenderer.createNew();

    dstContext = dstCanvas.getContext('2d');

    // // - start main loop
    // window.requestAnimationFrame(function(){
    //    myPainter.paint(myRenderer, dstCanvas);
    //    myPainter.update();
    // });
    var Loop = function()
    {
          myPainter.paint(myRenderer, dstContext);
          myPainter.update();
          window.setTimeout(Loop,1000/10)
    };
    window.setTimeout(Loop, 1000/10);

};

var dstCanvas = null;

// main application
var StartApp = function(renderTarget){
    dstCanvas = renderTarget;
    ImageLoader( new Array("img/01.jpg","img/02.jpg","img/03.jpg","img/04.jpg"), MainLoop );
};

StartApp(document.getElementById('canvas'));
