
// ----------------------- utility
var getRandom = function(lo,hi) {
    return Math.random()*(hi-lo)+lo;
}

var percentTrue = function(p) {
    return (Math.random() < (p/100.0))
}

var getRandomInt = function(lo,hi)
{
    return Math.round(getRandom(lo,hi));
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
var Painter = Base.extend({
    // the Painter interface
    config: {
        //Defaults
        imgSrc: null,
    },
    init: function(){},
    paint: function(renderer, destination){},
    update: function(){},
    setImageSource: function(input) { this.imgSrc = input }
})


// the MovingBrushPainter is a simple painter that just copies
// brushes from multiple input images to a destination image
var MovingBrushPainer =  { 
    createNew: function() {
        var painter = new Painter;
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
                10,'circle');
            }
        };
        // ------------------------------- paint
        painter.paint = function(renderer, dest) {
            //var imgIndex = getRandomInt(0,this.imgSrc.getNumImages()-1);
            var imgIndex = 0;
            // render each brush, cycling through input images
            for (i=0;i<this.N;++i)
            {
                var src = this.imgSrc.getImage(imgIndex);
                renderer.renderBrush(this.myBrushes[i], src , dest);
                imgIndex++;
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
                if (brush.y > this.imgSrc.H) { brush.y = this.imgSrc.H; }

                //Reset brush every now and then
                if(percentTrue(30))
                {
                    brush.size=getRandomInt(7,15);
                }

                //Respawn every now and then
                if(percentTrue(5))
                {
                    brush.x = getRandom(1,this.imgSrc.W);
                    brush.y = getRandom(1,this.imgSrc.H);
                }

                //Change direction every now and then
                if(percentTrue(80)) {
                    brush.dx = getRandom(-1, 1) * (brush.size/2);
                    brush.dy = getRandom(-1, 1) * (brush.size/2);
                }
                if (brush.x == NaN || brush.y == NaN || brush.dx == NaN || brush.dy == NaN || brush.size==NaN)
                {
                    alert(brush);
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
            images.push(this);

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
        renderer.blendBlock = function(src, dst)
        {
            for (var i=0; i<src.length; i+=4)
            {
                // simple blend: use dst[i] for everyone for a interesting effect
                dst[i] = (src[i]+dst[i])/2;
                dst[i+1] = (src[i+1]+dst[i+1])/2;
                dst[i+2] = (src[i+2]+dst[i+2])/2;
            }
        };

        renderer.getBrushData = function (brush, context)
        {
            return context.getImageData(Math.round(brush.x), Math.round(brush.y), Math.round(brush.size), Math.round(brush.size));
        }

        renderer.blend = function(src, dst, alpha)
        {
            return Math.round(alpha * src + (1-alpha) * dst);
        }

        renderer.renderBrush = function (brush, source, destination) 
        {
            var srcContext = source.imca.getContext('2d');
            var srcData = this.getBrushData(brush, srcContext);
            var dstData = this.getBrushData(brush, destination)

            if (brush.shape=='square') 
            {
                this.blendBlock(srcData.data, dstData.data);
            }

            if (brush.shape=='circle')
            {
                var x=0,y=0,cnt=brush.size/2;
                var i=0;
                for (var y=0;y<brush.size;++y)
                    for (var x=0;x<brush.size;++x)
                    {
                        var dx = x-cnt;
                        var dy = y-cnt;
                        var d = Math.sqrt(dx*dx+dy*dy);
                        var alpha = (cnt-d)/cnt;
                        if (alpha < 0) alpha=0;

                        var r = this.blend(srcData.data[i],dstData.data[i],alpha);
                        var g = this.blend(srcData.data[i+1],dstData.data[i+1],alpha);
                        var b = this.blend(srcData.data[i+2],dstData.data[i+2],alpha);
                        dstData.data[i] = r;
                        dstData.data[i+1]= g;
                        dstData.data[i+2] = b;
                        i+=4;
                    }
            }
            destination.putImageData(dstData, brush.x, brush.y);
        }
        return renderer;
    }
};

var MainLoop = function(images){

    var imgSource = ImageSource.createNew();
    imgSource.setSize(images[0].width, images[0].height);
    for(var i=0;i<images.length;++i)
    {
        images[i].imca    = document.createElement('canvas');
        images[i].imca.width  = images[i].width;
        images[i].imca.height = images[i].height;
        context = images[i].imca.getContext('2d');
        context.drawImage (images[i],0,0)
        imgSource.addImage(images[i]);
    }

    myPainter = MovingBrushPainter.createNew();
    myPainter.setImageSource( imgSource );
    myPainter.init();

    myRenderer = SimpleRenderer.createNew();

    dstContext = dstCanvas.getContext('2d');
    dstContext.fillRect(0,0,dstCanvas.width, dstCanvas.height);
    // // - start main loop
    // window.requestAnimationFrame(function(){
    //    myPainter.paint(myRenderer, dstCanvas);
    //    myPainter.update();
    // });
    // testPos = 0;

    var Loop = function()
    {
        //dstContext.fillRect(testPos,testPos,testPos+10,testPos+10);
        //testPos++;
        myPainter.paint(myRenderer, dstContext);
        myPainter.update();
        window.requestAnimationFrame(Loop);
    };
    window.requestAnimationFrame(Loop);

};

var dstCanvas = null;

// main application
var StartApp = function(renderTarget){
    dstCanvas = renderTarget;
    ImageLoader( new Array("img/03.jpg","img/04.jpg","img/05.jpg"), MainLoop );
};

StartApp(document.getElementById('canvas'));
