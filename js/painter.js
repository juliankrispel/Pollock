(function() {
  var Base, Brush, CImage, ClassSwitcher, HalfPipeMovement, ImageSource, Movement, MovingBrushPainter, Mutable, MutableController, PS, Painter, RandomIntervalNumber, RandomMovement, RandomPosition, Range, Renderer, Transformation, TransformedImage, dstCanvas, extend, getRandom, getRandomInt, imgSource, isArray, isString, lastTime, mainLoop, myPainter, percentTrue, useArrayAsDirectory, vendors, x,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  lastTime = 0;

  vendors = ["webkit", "moz"];

  x = 0;

  while (x < vendors.length && !window.requestAnimationFrame) {
    window.requestAnimationFrame = window[vendors[x] + "RequestAnimationFrame"];
    window.cancelAnimationFrame = window[vendors[x] + "CancelAnimationFrame"] || window[vendors[x] + "CancelRequestAnimationFrame"];
    ++x;
  }

  if (!window.requestAnimationFrame) {
    window.requestAnimationFrame = function(callback, element) {
      var currTime, id, timeToCall;
      currTime = new Date().getTime();
      timeToCall = Math.max(0, 16 - (currTime - lastTime));
      id = window.setTimeout;
      (function() {
        return callback(currTime + timeToCall, timeToCall);
      });
      lastTime = currTime + timeToCall;
      return id;
    };
  }

  if (!window.cancelAnimationFrame) {
    window.cancelAnimationFrame = function(id) {
      return clearTimeout(id);
    };
  }

  getRandom = function(lo, hi) {
    return Math.random() * (hi - lo) + lo;
  };

  percentTrue = function(p) {
    return Math.random() < (p / 100.0);
  };

  getRandomInt = function(lo, hi) {
    return Math.round(getRandom(lo, hi));
  };

  extend = function(obj) {
    var prop, source, _i, _len, _ref;
    _ref = Array.prototype.slice.call(arguments, 1);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      source = _ref[_i];
      if (source) {
        for (prop in source) {
          obj[prop] = source[prop];
        }
      }
    }
    return obj;
  };

  isArray = function(obj) {
    return Object.prototype.toString.call(obj) === '[object Array]';
  };

  isString = function(obj) {
    return typeof obj === 'string' || obj instanceof String;
  };

  useArrayAsDirectory = function(obj, paths) {
    var path, publicMember, _i, _len;
    publicMember = obj;
    for (_i = 0, _len = paths.length; _i < _len; _i++) {
      path = paths[_i];
      if (!publicMember[path]) {
        throw new Error('object ' + publicMember.constructor.name + ' has no member called ' + path);
      }
      publicMember = publicMember[path];
    }
    return publicMember;
  };

  window.PublishSubscriber = (function() {
    function PublishSubscriber() {
      this.setValue = __bind(this.setValue, this);
      this._channels = {};
      this._subscribers = {};
    }

    PublishSubscriber.prototype.registerChannel = function(name, metadata) {
      if (this._channels.hasOwnProperty(name)) {
        console.error("[PublishSubscriber ERR]: channel " + name + " already exists.");
        return this;
      }
      this._channels[name] = metadata;
      this._channels[name]._subscribers = {};
      return this;
    };

    PublishSubscriber.prototype.unregisterChannel = function(name) {
      if (this._channels.hasOwnProperty(name)) {
        delete this._channels[name];
      } else {
        console.error("[PublishSubscriber ERR]: tried to unregister channel " + name + ", which is unknown to me.");
      }
      return this;
    };

    PublishSubscriber.prototype.getChannel = function(name) {
      if (this._channels.hasOwnProperty(name)) {
        return this._channels[name];
      }
      return null;
    };

    PublishSubscriber.prototype.subscribe = function(channel, subscriber, callback) {
      if (!this._channels.hasOwnProperty(channel)) {
        this.registerChannel(channel, {
          value: void 0
        });
      }
      if (!this._subscribers.hasOwnProperty(subscriber)) {
        this._subscribers[subscriber] = {
          _channels: {}
        };
      }
      if (typeof callback !== 'function') {
        console.log('[PublishSubscriber ERR]: `typeof` callback != function');
      }
      this._channels[channel]._subscribers[subscriber] = callback;
      this._subscribers[subscriber]._channels[channel] = this._channels[channel];
      return this;
    };

    PublishSubscriber.prototype.unsubscribe = function(channel, subscriber) {
      if (!this._subscribers.hasOwnProperty(subscriber)) {
        console.error("[PublishSubscriber ERR]: " + subscriber + " tried to unsubscribe from " + channel + ", but i don't know him.");
        return this;
      }
      if (!this._channels.hasOwnProperty(channel)) {
        console.error("[PublishSubscriber ERR]: " + subscriber + " tried to unsubscribe from " + channel + ", which doesn't exist.");
        return this;
      }
      delete this._subscribers[subscriber]._channels[channel];
      delete this._channels[channel]._subscribers[subscriber];
      return this;
    };

    PublishSubscriber.prototype.getValue = function(channel, subscriber) {
      if (this._channels.hasOwnProperty(channel)) {
        return this._channels[channel].value;
      }
      console.error("[PublishSubscriber ERR]: " + subscriber + " tried to read from non-existant channel " + channel);
      return null;
    };

    PublishSubscriber.prototype.setValue = function(channel, subscriber, value) {
      var callback, listener, _ref;
      if (!this._channels.hasOwnProperty(channel)) {
        this.registerChannel(channel, {
          value: value
        });
      }
      if (this._channels[channel].value !== value) {
        this._channels[channel].value = value;
        _ref = this._channels[channel]._subscribers;
        for (listener in _ref) {
          callback = _ref[listener];
          if (listener !== subscriber) {
            callback(value);
          }
        }
      }
      return this;
    };

    PublishSubscriber.prototype.publishAll = function(obj) {
      var lastPath, member, memberVar, paths, publicVar, _ref, _results;
      if (obj['public'] && typeof obj['public'] === 'object') {
        _ref = obj['public'];
        _results = [];
        for (publicVar in _ref) {
          memberVar = _ref[publicVar];
          if (memberVar !== void 0 && !isArray(memberVar)) {
            memberVar = [memberVar];
          }
          if ((function() {
            var _i, _len, _results1;
            _results1 = [];
            for (_i = 0, _len = memberVar.length; _i < _len; _i++) {
              member = memberVar[_i];
              _results1.push(isString(member));
            }
            return _results1;
          })()) {
            paths = member.split('.');
            lastPath = paths.pop();
            memberVar = useArrayAsDirectory(obj, paths);
            _results.push(this.publish(memberVar, lastPath, publicVar));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    };

    PublishSubscriber.prototype.getAllChannels = function() {
      var chanlist, channel, name, _ref;
      chanlist = [];
      _ref = this._channels;
      for (name in _ref) {
        channel = _ref[name];
        chanlist.push(name);
      }
      return chanlist;
    };

    PublishSubscriber.prototype.publish = function(obj, property, channel) {
      var PS, defaultValue, isNewChannel, subName;
      PS = this;
      if (obj.hasOwnProperty(property)) {
        defaultValue = obj[property];
      }
      subName = obj.constructor.name + "_" + property;
      Object.defineProperty(obj, property, {
        get: function() {
          return PS.getValue(channel, subName);
        },
        set: function(val) {
          return PS.setValue(channel, subName, val);
        }
      });
      isNewChannel = !this._channels.hasOwnProperty(channel) || this._channels[channel].value === void 0;
      this.subscribe(channel, subName, function() {});
      this._channels[channel].published = true;
      if (defaultValue !== void 0 && isNewChannel) {
        this.setValue(channel, subName, defaultValue);
      }
      return subName;
    };

    return PublishSubscriber;

  })();

  PS = new PublishSubscriber;

  Base = (function() {
    Base.prototype.PS = PS;

    function Base() {
      var arg, defaults, initArgs, isFirst, key, mixin, val, _i, _len, _ref;
      mixin = {};
      initArgs = [];
      isFirst = true;
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        arg = arguments[_i];
        if (typeof arg === 'object' && isFirst) {
          mixin = arg;
        } else {
          initArgs.push(arg);
        }
        isFirst = false;
      }
      defaults = {};
      _ref = this.defaults;
      for (key in _ref) {
        val = _ref[key];
        defaults[key] = _(this.defaults).result(key);
      }
      _(this).extend(_(defaults).clone(), mixin);
      if (this['init']) {
        this.init.apply(this, initArgs);
      }
      this.PS.publishAll(this);
    }

    return Base;

  })();

  window.PS = PS;

  Range = (function() {
    function Range(v1, v2) {
      this.setRange(v1, v2);
    }

    Range.prototype.setRange = function(v1, v2) {
      if (v1 <= v2) {
        this.min = v1;
        return this.max = v2;
      } else {
        this.min = v2;
        return this.max = v1;
      }
    };

    Range.prototype.mid = function() {
      return (this.min + this.max) / 2;
    };

    Range.prototype.clone = function() {
      return new Range(this.min, this.max);
    };

    return Range;

  })();

  RandomIntervalNumber = (function() {
    function RandomIntervalNumber(range) {
      this.myClass = RandomIntervalNumber;
      this.range = range.clone();
      this.val = this.range.mid();
    }

    RandomIntervalNumber.prototype.clone = function() {
      var cloned;
      cloned = new RandomIntervalNumber(this.range);
      cloned.val = this.val;
      return cloned;
    };

    RandomIntervalNumber.prototype.assign = function(from) {
      this.range = from.range.clone();
      return this.val = from.val;
    };

    RandomIntervalNumber.prototype.clamp = function() {
      if (this.val < this.min) {
        this.val = this.min;
      }
      if (this.val > this.max) {
        return this.val = this.max;
      }
    };

    RandomIntervalNumber.prototype.setRange = function(range) {
      this.range = range.clone();
      this.clamp();
      return this;
    };

    RandomIntervalNumber.prototype.newValue = function() {
      if (this.range.min < this.range.max) {
        this.val = getRandom(this.range.min, this.range.max);
      } else {
        this.val = this.range.min;
      }
      return this;
    };

    RandomIntervalNumber.prototype.setValue = function(v) {
      this.val = v;
      this.clamp();
      return this;
    };

    RandomIntervalNumber.prototype.interpolate = function(from, to, t) {
      this.setValue(from.val * t + to.val * (1 - t));
      return this.val;
    };

    RandomIntervalNumber.prototype.intValue = function() {
      return this.val | 0;
    };

    RandomIntervalNumber.prototype.valueOf = function() {
      return this.val;
    };

    return RandomIntervalNumber;

  })();

  RandomPosition = (function() {
    function RandomPosition(xrng, yrng) {
      if (!(xrng || yrng)) {
        throw new Error('x and y range must be defined');
      }
      this.myClass = RandomPosition;
      this.x = new RandomIntervalNumber(xrng);
      this.y = new RandomIntervalNumber(yrng);
    }

    RandomPosition.prototype.setRange = function(xrng, yrng) {
      this.x.setRange(xrng);
      this.y.setRange(yrng);
      return this;
    };

    RandomPosition.prototype.clone = function() {
      var cloned;
      cloned = new RandomPosition(this.x.range, this.y.range);
      cloned.x.val = this.x.val;
      cloned.y.val = this.y.val;
      return cloned;
    };

    RandomPosition.prototype.assign = function(from) {
      this.setRange(from.x.range, from.y.range);
      this.x.val = from.x.val;
      return this.y.val = from.y.val;
    };

    RandomPosition.prototype.newValue = function() {
      this.x.newValue();
      this.y.newValue();
      return this;
    };

    RandomPosition.prototype.setValue = function(v) {
      this.x.setValue(v.x);
      return this.y.setValue(v.y);
    };

    RandomPosition.prototype.interpolate = function(from, to, t) {
      this.x.interpolate(from.x, to.x, t);
      this.y.interpolate(from.y, to.y, t);
      return this.valueOf();
    };

    RandomPosition.prototype.valueOf = function() {
      return {
        x: this.x.val,
        y: this.y.val
      };
    };

    return RandomPosition;

  })();

  Mutable = (function(_super) {
    __extends(Mutable, _super);

    function Mutable() {
      return Mutable.__super__.constructor.apply(this, arguments);
    }

    Mutable.prototype.defaults = {
      ctr: 1,
      upmode: 'discrete',
      value: NaN,
      lastValue: NaN,
      cycle: function() {
        return new RandomIntervalNumber(new Range(20, 100));
      }
    };

    Mutable.prototype.init = function() {
      return this.setType(this.value);
    };

    Mutable.prototype.setType = function(val) {
      this.value = val;
      this.lastValue = this.value.clone();
      this.currentValue = this.value.clone();
      return this;
    };

    Mutable.prototype.update = function() {
      --this.ctr;
      if (this.ctr <= 0) {
        this.lastValue.assign(this.value);
        this.value.newValue();
        this.cycle.newValue();
        return this.ctr = this.cycle.intValue();
      }
    };

    Mutable.prototype.setRegularCycle = function(value) {
      return this.cycle.setRange(value, value);
    };

    Mutable.prototype.setIrregularCycle = function(min, max) {
      return this.cycle.setRange(min, max);
    };

    Mutable.prototype.valueOf = function() {
      var v;
      switch (this.upmode) {
        case 'discrete':
          v = this.value.valueOf();
          break;
        case 'linp':
          v = this.currentValue.interpolate(this.lastValue, this.value, this.ctr / this.cycle.intValue());
      }
      return v;
    };

    return Mutable;

  })(Base);

  MutableController = (function() {
    function MutableController() {}

    MutableController.prototype.mutables = [];

    MutableController.prototype.registerMutable = function(m) {
      return this.mutables.push(m);
    };

    MutableController.prototype.removeMutable = function(m) {
      var i;
      i = this.mutables.indexOf(m);
      if (i !== -1) {
        return this.mutables.splice(i, 1);
      }
    };

    MutableController.prototype.update = function() {
      var m, _i, _len, _ref, _results;
      _ref = this.mutables;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        m = _ref[_i];
        _results.push(m.update());
      }
      return _results;
    };

    return MutableController;

  })();

  window.Mutable = Mutable;

  window.RandomIntervalNumber = RandomIntervalNumber;

  Movement = (function(_super) {
    __extends(Movement, _super);

    function Movement() {
      return Movement.__super__.constructor.apply(this, arguments);
    }

    return Movement;

  })(Base);

  RandomMovement = (function(_super) {
    __extends(RandomMovement, _super);

    function RandomMovement() {
      return RandomMovement.__super__.constructor.apply(this, arguments);
    }

    RandomMovement.prototype["public"] = {
      'brushMinSize': 'sizem.value.range.min',
      'brushMaxSize': 'sizem.value.range.max',
      'movementChangeDirectionMin': 'delta.cycle.range.min',
      'movementChangeDirectionMax': 'delta.cycle.range.max',
      'movementInterpolation': 'delta.upmode',
      'canvasWidth': 'pos.value.x.range.max',
      'canvasHeight': 'pos.value.y.range.max'
    };

    RandomMovement.prototype.init = function() {
      var setValue;
      this.pos = new Mutable({
        value: new RandomPosition(new Range(0, PS.getValue('canvasWidth')), new Range(0, PS.getValue('canvasHeight'))),
        upmode: 'discrete',
        cycle: new RandomIntervalNumber(new Range(50, 1000))
      });
      setValue = function(v) {
        this.val = v < this.range.min ? this.range.max : v > this.range.max ? this.range.min : v;
        return this;
      };
      this.pos.value.x.setValue = setValue;
      this.pos.value.y.setValue = setValue;
      this.delta = new Mutable({
        value: new RandomPosition(new Range(-10, 10), new Range(-10, 10)),
        upmode: 'linp',
        cycle: new RandomIntervalNumber(new Range(10, 50))
      });
      this.sizem = new Mutable({
        value: new RandomIntervalNumber(new Range(2, 15)),
        upmode: 'linp',
        cycle: new RandomIntervalNumber(new Range(20, 100))
      });
      return this.update();
    };

    RandomMovement.prototype.update = function() {
      var D, S;
      this.pos.update();
      this.sizem.update();
      S = +this.sizem.value;
      this.delta.value.setRange(new Range(-S / 2, S / 2), new Range(-S / 2, S / 2));
      this.delta.update();
      D = this.delta.valueOf();
      this.pos.value.x.setValue(this.pos.value.x + D.x);
      this.pos.value.y.setValue(this.pos.value.y + D.y);
      return this.bsize = S | 0;
    };

    RandomMovement.prototype.x = function() {
      return this.pos.valueOf().x | 0;
    };

    RandomMovement.prototype.y = function() {
      return this.pos.valueOf().y | 0;
    };

    RandomMovement.prototype.size = function() {
      return this.bsize;
    };

    return RandomMovement;

  })(Movement);

  HalfPipeMovement = (function(_super) {
    __extends(HalfPipeMovement, _super);

    function HalfPipeMovement() {
      return HalfPipeMovement.__super__.constructor.apply(this, arguments);
    }

    HalfPipeMovement.prototype["public"] = {
      'movementDescription': 'description',
      'movementMinSize': 'minSize',
      'movementTwoAttribute': 'maxSize',
      'canvasWidth': 'center.value.x.range.max',
      'canvasHeight': 'center.value.y.range.max'
    };

    HalfPipeMovement.prototype.defaults = {
      description: 'Half Circle Movement'
    };

    HalfPipeMovement.prototype.init = function() {
      this.center = new Mutable({
        value: new RandomPosition(new Range(0, PS.getValue('canvasWidth')), new Range(0, PS.getValue('canvasHeight'))),
        upmode: 'discrete',
        cycle: new RandomIntervalNumber(new Range(1, 1))
      });
      this.radius = new Mutable({
        value: new RandomIntervalNumber(new Range(10, 50)),
        upmode: 'discrete',
        cycle: new RandomIntervalNumber(new Range(1, 1))
      });
      this.sizem = new Mutable({
        value: new RandomIntervalNumber(new Range(3, 8)),
        upmode: 'discrete',
        cycle: new RandomIntervalNumber(new Range(1, 1))
      });
      this.counter = 1;
      return this.update();
    };

    HalfPipeMovement.prototype.update = function() {
      var angle, r;
      if (--this.counter <= 0) {
        this.sizem.update();
        this.radius.update();
        r = this.radius.value.intValue();
        this.center.update();
        this.counter = Math.PI * this.radius.valueOf() / (this.sizem.valueOf() / 2);
      }
      angle = (this.sizem.valueOf() / 2) * this.counter / this.radius.valueOf();
      this.xPos = (this.center.value.x.valueOf() + this.radius * Math.cos(angle)) | 0;
      this.yPos = (this.center.value.y.valueOf() + this.radius * Math.sin(angle)) | 0;
      return this.msize = +this.sizem.value | 0;
    };

    HalfPipeMovement.prototype.x = function() {
      return this.xPos;
    };

    HalfPipeMovement.prototype.y = function() {
      return this.yPos;
    };

    HalfPipeMovement.prototype.size = function() {
      return this.msize;
    };

    return HalfPipeMovement;

  })(Movement);

  ClassSwitcher = (function(_super) {
    __extends(ClassSwitcher, _super);

    function ClassSwitcher() {
      return ClassSwitcher.__super__.constructor.apply(this, arguments);
    }

    ClassSwitcher.prototype.defaults = {
      channel: 'ClassSwitcherChannel',
      "default": 'name1',
      params: {},
      classes: {
        'Random': RandomMovement,
        'HalfPipe': HalfPipeMovement
      }
    };

    ClassSwitcher.prototype.init = function() {
      this._class = this["default"];
      this.update();
      return PS.publish(this, '_class', this.channel);
    };

    ClassSwitcher.prototype.update = function() {
      if (this._class !== this._oldClass) {
        if (this.classes.hasOwnProperty(this._class)) {
          this._oldClass = this._class;
          return this._value = new this.classes[this._class](this.params);
        }
      }
    };

    ClassSwitcher.prototype.val = function() {
      return this._value;
    };

    return ClassSwitcher;

  })(Base);

  Brush = (function(_super) {
    __extends(Brush, _super);

    function Brush() {
      return Brush.__super__.constructor.apply(this, arguments);
    }

    Brush.prototype.defaults = {
      type: 'circle'
    };

    Brush.prototype["public"] = {
      'brushType': 'type'
    };

    Brush.prototype.init = function() {
      return this.movement = new ClassSwitcher({
        channel: 'brushMovementType',
        "default": 'Random'
      });
    };

    Brush.prototype.update = function() {
      this.movement.update();
      return this.movement.val().update();
    };

    Brush.prototype.x = function() {
      return this.movement.val().x();
    };

    Brush.prototype.y = function() {
      return this.movement.val().y();
    };

    Brush.prototype.size = function() {
      return this.movement.val().size();
    };

    return Brush;

  })(Base);

  Transformation = (function(_super) {
    __extends(Transformation, _super);

    function Transformation() {
      return Transformation.__super__.constructor.apply(this, arguments);
    }

    Transformation.prototype.defaults = {
      tx: 0,
      ty: 0,
      sx: 1,
      sy: 1,
      angle: 0
    };

    Transformation.prototype.setTransformation = function(tx, ty, sx, sy, angle) {
      this.tx = tx;
      this.ty = ty;
      this.sx = sx;
      this.sy = sy;
      return this.angle = angle;
    };

    Transformation.prototype.transformImage = function(context, image) {
      context.setTransform;
      context.translate(this.tx, this.ty);
      context.scale(this.sx, this.sy);
      context.rotate(this.angle);
      return context.drawImage(image, 0, 0);
    };

    return Transformation;

  })(Base);

  CImage = (function(_super) {
    __extends(CImage, _super);

    function CImage() {
      return CImage.__super__.constructor.apply(this, arguments);
    }

    CImage.prototype.defaults = {
      width: 0,
      height: 0
    };

    CImage.prototype.init = function() {
      var context2d;
      this.canvas = document.createElement('canvas');
      if (this.image !== void 0) {
        this.width = this.image.width;
        this.height = this.image.height;
      }
      this.canvas.width = this.width;
      this.canvas.height = this.height;
      context2d = this.canvas.getContext('2d');
      if (this.image !== void 0) {
        context2d.drawImage(this.image, 0, 0);
      }
      return this.imgData = context2d.getImageData(0, 0, this.width, this.height);
    };

    CImage.prototype.drawToCanvas = function(canvas) {
      return canvas.getContext('2d').putImageData(this.imgData, 0, 0);
    };

    CImage.prototype.getPixelData = function(x, y, size) {
      var dstoffset, imgData, row, srcoffset;
      imgData = {
        width: size,
        height: size,
        data: new Uint8ClampedArray(size * size * 4)
      };
      row = 0;
      srcoffset = (x + (y * this.width)) * 4;
      dstoffset = 0;
      while (row < size) {
        imgData.data.set(this.imgData.data.subarray(srcoffset, srcoffset + size * 4), dstoffset);
        srcoffset += this.width * 4;
        dstoffset += size * 4;
        ++row;
      }
      return imgData;
    };

    CImage.prototype.putPixelData = function(x, y, size, src) {
      var dstoffset, row, srcoffset;
      row = 0;
      srcoffset = 0;
      dstoffset = (x + (y * this.width)) * 4;
      while (row < size) {
        this.imgData.data.set(src.data.subarray(srcoffset, srcoffset + size * 4), dstoffset);
        dstoffset += this.width * 4;
        srcoffset += size * 4;
        ++row;
      }
      return this;
    };

    return CImage;

  })(Base);

  TransformedImage = (function(_super) {
    __extends(TransformedImage, _super);

    function TransformedImage() {
      return TransformedImage.__super__.constructor.apply(this, arguments);
    }

    TransformedImage.prototype.defaults = {
      transwidth: 100,
      transheight: 100,
      transformation: new Transformation
    };

    TransformedImage.prototype.init = function() {
      this.resetTransformation();
      return this.applyTransformation();
    };

    TransformedImage.prototype.resetTransformation = function() {
      return this.transformation.setTransformation(0, 0, this.transwidth / this.width, this.transheight / this.height, 0);
    };

    TransformedImage.prototype.applyTransformation = function() {
      var ctx;
      this.transformed = new CImage({
        width: this.transwidth,
        height: this.transheight
      });
      ctx = this.transformed.canvas.getContext('2d');
      this.transformation.transformImage(ctx, this.image);
      return this.transformed.imgData = ctx.getImageData(0, 0, this.transformed.width, this.transformed.height);
    };

    TransformedImage.prototype.getPixelData = function(x, y, size) {
      var dstoffset, imgData, row, srcoffset;
      imgData = {
        width: size,
        height: size,
        data: new Uint8ClampedArray(size * size * 4)
      };
      row = 0;
      srcoffset = (x + (y * this.transformed.width)) * 4;
      dstoffset = 0;
      while (row < size) {
        imgData.data.set(this.transformed.imgData.data.subarray(srcoffset, srcoffset + size * 4), dstoffset);
        srcoffset += this.transformed.width * 4;
        dstoffset += size * 4;
        ++row;
      }
      return imgData;
    };

    TransformedImage.prototype.putPixelData = function(x, y, size, data) {
      throw new Error('putPixelData is not defined for transformed images.');
    };

    return TransformedImage;

  })(CImage);

  ImageSource = (function(_super) {
    __extends(ImageSource, _super);

    function ImageSource() {
      return ImageSource.__super__.constructor.apply(this, arguments);
    }

    ImageSource.prototype["public"] = {
      'canvasWidth': 'width',
      'canvasHeight': 'height'
    };

    ImageSource.prototype.defaults = {
      images: [],
      domImages: [],
      width: 460,
      height: 400
    };

    ImageSource.prototype.getRandomImageCanvas = function() {
      return this.images[Math.round(Math.random() * (this.images.length - 1))];
    };

    ImageSource.prototype.getImageCanvas = function(index) {
      return this.images[index];
    };

    ImageSource.prototype.addImage = function(img) {
      return this.images.push(new TransformedImage({
        width: img.width,
        height: img.height,
        image: img.image,
        transwidth: this.width,
        transheight: this.height
      }));
    };

    ImageSource.prototype.update = function() {
      var img, _i, _len, _ref, _results;
      _ref = this.images;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        img = _ref[_i];
        if (img.transwidth !== this.width || img.transheight !== this.height) {
          img.transwidth = this.width;
          img.transheight = this.height;
          img.resetTransformation();
          _results.push(img.applyTransformation());
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return ImageSource;

  })(Base);

  Painter = (function(_super) {
    __extends(Painter, _super);

    function Painter() {
      return Painter.__super__.constructor.apply(this, arguments);
    }

    Painter.prototype["public"] = {
      'canvasWidth': 'width',
      'canvasHeight': 'height'
    };

    Painter.prototype.defaults = {
      imgSrc: null,
      brushCount: 6
    };

    Painter.prototype.start = function() {};

    Painter.prototype.paint = function(renderer, destination) {};

    Painter.prototype.update = function() {};

    Painter.prototype.setImageSource = function(image) {
      return this.imgSrc = image;
    };

    return Painter;

  })(Base);

  MovingBrushPainter = (function(_super) {
    __extends(MovingBrushPainter, _super);

    function MovingBrushPainter() {
      this.start = __bind(this.start, this);
      return MovingBrushPainter.__super__.constructor.apply(this, arguments);
    }

    MovingBrushPainter.prototype.setBrushes = function(num) {
      this.brushCount = num;
      return this.init;
    };

    MovingBrushPainter.prototype["public"] = {
      'brushCount': 'brushCount',
      'canvasWidth': 'width',
      'canvasHeight': 'height'
    };

    MovingBrushPainter.prototype.start = function() {
      var i, _results;
      this.background = new CImage({
        width: this.width,
        height: this.height
      });
      this.brushes = [];
      i = 0;
      _results = [];
      while (i <= this.brushCount) {
        this.brushes[i] = new Brush();
        _results.push(++i);
      }
      return _results;
    };

    MovingBrushPainter;

    MovingBrushPainter.prototype.paint = function(renderer, dest) {
      var i, imgIndex;
      i = 0;
      imgIndex = 0;
      while (i < this.brushCount) {
        if (!this.brushes[i]) {
          this.brushes[i] = new Brush();
        }
        renderer.renderBrush(this.brushes[i], this.imgSrc.getImageCanvas(imgIndex++), this.background);
        if (imgIndex === this.imgSrc.images.length) {
          imgIndex = 0;
        }
        ++i;
      }
      return dest.putImageData(this.background.imgData, 0, 0);
    };

    MovingBrushPainter.prototype.update = function() {
      var br, _i, _len, _ref;
      if (this.background.width !== this.width) {
        this.background = new CImage({
          width: this.width,
          height: this.height
        });
      }
      this.imgSrc.update();
      _ref = this.brushes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        br = _ref[_i];
        br.update();
      }
      return this;
    };

    return MovingBrushPainter;

  })(Painter);

  Renderer = (function(_super) {
    __extends(Renderer, _super);

    function Renderer() {
      return Renderer.__super__.constructor.apply(this, arguments);
    }

    Renderer.prototype.alphablend = function(src, dst, alpha) {
      return alpha * src + (1 - alpha) * dst | 0;
    };

    Renderer.prototype.avgblend = function(src, dst) {
      return (src + dst) / 2.0 | 0;
    };

    Renderer.prototype.scrblend = function(src, dst) {
      return 255.0 * (1 - (1 - src / 255.0) * (1 - dst / 255.0)) | 0;
    };

    Renderer.prototype.compositeBlock = function(src, dst, bmode) {
      var i, _i, _ref;
      for (i = _i = 0, _ref = src.length; _i <= _ref; i = _i += 4) {
        dst[i] = bmode(src[i], dst[i]);
        dst[i + 1] = bmode(src[i + 1], dst[i + 1]);
        dst[i + 2] = bmode(src[i + 2], dst[i + 2]);
        dst[i + 3] = 255;
      }
      return this;
    };

    Renderer.prototype.rgb2luminance = function(RGB, i) {
      return 0.299 * RGB[i] + 0.587 * RGB[i + 1] + 0.114 * RGB[i + 2];
    };

    Renderer.prototype.quickSortStep = function(array, offset, length) {
      var i, left, li, pindex, pivot, ri, right, _i, _ref;
      pindex = getRandomInt(0, length - 1);
      pivot = this.rgb2luminance(array, offset + pindex * 4);
      left = new Uint8ClampedArray(length * 4);
      right = new Uint8ClampedArray(length * 4);
      li = 0;
      ri = 0;
      for (i = _i = 0, _ref = (length - 1) * 4; _i <= _ref; i = _i += 4) {
        if (this.rgb2luminance(array, offset + i) < pivot) {
          left[li + 0] = array[offset + i + 0];
          left[li + 1] = array[offset + i + 1];
          left[li + 2] = array[offset + i + 2];
          left[li + 3] = array[offset + i + 3];
          li += 4;
        } else {
          right[ri + 0] = array[offset + i + 0];
          right[ri + 1] = array[offset + i + 1];
          right[ri + 2] = array[offset + i + 2];
          right[ri + 3] = array[offset + i + 3];
          ri += 4;
        }
      }
      if (li > 0) {
        array.set(left.subarray(0, li - 1), offset + 0);
      }
      if (ri > 0) {
        return array.set(right.subarray(0, ri - 4), offset + li);
      }
    };

    Renderer.prototype.renderBrush = function(brush, source, destination) {
      var B, G, R, alpha, brx, bry, cnt, d, dstData, dx, dy, i, midoff, offset, s, srcData, y;
      s = brush.size();
      brx = brush.x();
      bry = brush.y();
      if (brx < 0) {
        brx = 0;
      }
      if (brx > (destination.width - s)) {
        brx = destination.width - s;
      }
      if (bry < 0) {
        bry = 0;
      }
      if (bry > (destination.height - s)) {
        bry = destination.height - s;
      }
      srcData = source.getPixelData(brx, bry, s);
      dstData = destination.getPixelData(brx, bry, s);
      switch (brush.type) {
        case 'square':
          this.compositeBlock(srcData.data, dstData.data, this.avgblend);
          break;
        case 'weird':
          this.compositeBlock(srcData.data, dstData.data, this.scrblend);
          break;
        case 'circle':
        case 'scircle':
          x = 0;
          y = 0;
          cnt = brush.size() / 2;
          i = 0;
          y = 0;
          if (brush.type === "scircle") {
            midoff = (cnt + cnt * brush.size()) * 4;
            R = srcData.data[midoff + 0];
            G = srcData.data[midoff + 1];
            B = srcData.data[midoff + 2];
          }
          while (y < brush.size()) {
            x = 0;
            while (x < brush.size()) {
              dx = x - cnt;
              dy = y - cnt;
              d = Math.sqrt(dx * dx + dy * dy);
              alpha = (cnt - d) / cnt;
              if (alpha < 0) {
                alpha = 0;
              }
              if (brush.type === "circle") {
                R = srcData.data[i + 0];
                G = srcData.data[i + 1];
                B = srcData.data[i + 2];
              }
              dstData.data[i] = this.alphablend(R, dstData.data[i], alpha);
              dstData.data[i + 1] = this.alphablend(G, dstData.data[i + 1], alpha);
              dstData.data[i + 2] = this.alphablend(B, dstData.data[i + 2], alpha);
              dstData.data[i + 3] = 255;
              i += 4;
              ++x;
            }
            ++y;
          }
          break;
        case 'sort':
          y = 0;
          offset = 0;
          while (y < brush.size()) {
            this.quickSortStep(dstData.data, offset, brush.size());
            offset += brush.size() * 4;
            ++y;
          }
      }
      destination.putPixelData(brx, bry, s, dstData);
      return this;
    };

    return Renderer;

  })(Base);

  myPainter = new MovingBrushPainter;

  imgSource = new ImageSource;

  dstCanvas = null;

  mainLoop = function(images) {
    var dstContext, image, iterate, myRenderer, _i, _len;
    for (_i = 0, _len = images.length; _i < _len; _i++) {
      image = images[_i];
      imgSource.addImage(new CImage({
        image: image
      }));
    }
    myPainter.setImageSource(imgSource);
    myPainter.start();
    myRenderer = new Renderer;
    dstContext = dstCanvas.getContext("2d");
    dstContext.fillRect(0, 0, dstCanvas.width, dstCanvas.height);
    iterate = (function(_this) {
      return function() {
        myPainter.paint(myRenderer, dstContext);
        myPainter.update();
        return window.requestAnimationFrame(iterate);
      };
    })(this);
    window.requestAnimationFrame(iterate);
    return null;
  };

  window.painter = myPainter;

  window.startPainter = function(renderTarget, images, callback) {
    dstCanvas = renderTarget;
    mainLoop(images);
    if (callback) {
      return callback(myPainter);
    }
  };

}).call(this);
