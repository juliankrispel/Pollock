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
 
// a stroke generates a sequence of brushes
var Stroke = {
    // get an array of brushes for painting
    getBrushes : function()
    {
    }
}

var ImageSource = {
    getWidth : function() {}
    getHeight : function() {}
}

var Painter = {
    imgSrc : null;
    setImageSource : function(input) { 
        this.imgSrc = input; 
    }
    // the Painter interface
    init  : function() {}
    paint : function(renderer) {}
    update : function() {}
}

var MovingSquarePainter = _(Painter).extend({
    myBrushes : null,
    N : 10,
    // painter interface
    init : function() {
        this.myBrushes = [];
        for (i=0;i<this.N;++i) {
            this.myBrushes.push(new Brush());
        }
        _(this.myBrushes).each(function(brush) {
            brush.dx = 1;
            brush.dy = 1;                
            brush.setState(0,0,5,'square');
        });
    },

    paint : function(renderer) {
        _(this.myBrushes).each(function(brush) {
            renderer.renderBrush(brush);
        }
    },

    update : function() {
        _(this.myBrushes).each(function(brush))
        {
            // Change the coordinates to move in the right direction
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
                brush.dx = getRandomInt(-1, 1) * brush.size;
                brush.dy = getRandomInt(-1, 1) * brush.size;
            }
        }
    }
});

var ImageLoader = function(imageFiles, callback){
    var images = [];
    for(var i = 0; i < imageFiles.length; i++){
        var image = new Image();
        image.src = imageFiles[i];
        image.onload = function(){
            images.push(this.context);

            // Call callback when done loading images and pass images as argument
            if(i + 1 == imageFiles.length){
                callback(images);
            }
        }
    }
}




var Main = function(){
    
    // - load images <TODO>: call imageloader here
    
    var dstCanvas = <TODO>
    
    // - instantiate painter with src images
    var myPainter = MovingSquarePainter();
    myPainter.setImageSource( <TODO> );
    
    // - start main loop
    window.requestAnimationFrame(function(0){
       myPainter.paint(myRenderer, dstCanvas);
       myPainter.update();
    });
}