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


(function(){
    var canvas = document.getElementById('canvas');
    var w = canvas.width;
    var h = canvas.height;
    var pixels = [];

    canvas = canvas.getContext('2d');

    var images = [];
    var imagesLoaded = 0;

    for(var i = 1; i < 8; i++){
        var image = new Image();
        image.src = 'img/0' + i + '.jpg';
        image.imageCanvas = document.createElement('canvas');
        image.imageCanvas.width = 1400;
        image.imageCanvas.height = 1600;
        image.context = image.imageCanvas.getContext('2d');

        image.onload = function(){
            this.context.drawImage(this, 0, 0 );
            imagesLoaded++;
            images.push(this.context);

            if(imagesLoaded == images.length)
                init();
        }

    }
    function init(){
        generatePixels();
        draw();
    };

    function draw(){
        _(pixels).each(function(pixel){
            pixel.move();
        });
        requestAnimationFrame(draw);
    }

    function generatePixels(){
        for(var i = 0; i < 10; i++){
            var pixel = new Pixel({
                canvas: canvas,
                imageCanvas: images 
            })
            pixels.push(pixel);
        }
    }

    var Pixel = function(config){
        this.init(config);
    }

    _(Pixel.prototype).extend({
        //Defaults
        defaults: {
            x: 0,
            y: 0,
            xir: 1,
            ydir: 1,
            canvas: null,
            imageCanvas: null,
            brushWidth: 1,
            brushHeight: 1
        },

        init: function(config){
            //Extend new pixel with passed parameters
            _(this).extend(this.defaults, config);

            if(_.isArray(this.imageCanvas)){
                this.storeImageCanvasArray();
                this.pickImageCanvas();
            }

            this.resetCoordinates();
            this.resetDirection();
        },

        storeImageCanvasArray: function(){
            if(_.isArray(this.imageCanvas))
                this.imageCanvasArray = this.imageCanvas;
        },

        pickImageCanvas: function(){
            var max = this.imageCanvasArray.length;
            var index = getRandomInt(0, max - 1);
            this.imageCanvas = this.imageCanvasArray[index];
        },

        move: function(){
            // Change the coordinates to move in the right direction
            this.x = this.x + this.xdir;
            this.y = this.y + this.ydir;

            //Reset brush every now and then
//            if(percentTrue(3))
//                this.resetBrush();

            //Respawn every now and then
            if(percentTrue(1))
                this.resetCoordinates();

            //Change direction every now and then
            if(percentTrue(30))
                this.resetDirection();               

            //Get imageData from .imageCanvas and put it on canvas
            var imageData = this.imageCanvas.getImageData(this.x, this.y, this.brushWidth, this.brushHeight);
            this.canvas.putImageData(imageData, this.x, this.y);
        },


        resetCoordinates: function(){
            this.x = getRandomInt(1, w);
            this.y = getRandomInt(1, h);
        },

        resetDirection: function(){
            this.xdir = getRandomInt(-2, 2);
            this.ydir = getRandomInt(-2, 2);
        },

        resetBrush: function(){
            this.brushWidth = getRandom(1, 2);
            this.brushHeight = getRandom(1, 2);
        }
    
    });

    // Get Image Data
    function getImageData(context, w,h){
        //Set defaults for width and height
        if(!w) w = 1;
        if(!h) h = 1;

        return context.getImageData(0, 0, w, h);
    }

    // Generate random point
    function generateRandomCoordinates(){
        return [ getRandomInt(1, w), getRandomInt(1, h) ];
    }

    function getRandomInt(min, max){
        return Math.round(Math.random() * (max - min) + min);
    }

    function getRandom(min, max){
        var num = Math.random() * (max - min) + min;
        return num;
    }

    function percentTrue(percent){
        return (getRandomInt(1, 100) <= percent);
    }

})();
