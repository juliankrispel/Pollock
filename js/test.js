(function() {
  var Base, ImageTransform, Mat3, Mutable, MutableController, PS, RandomIntervalNumber, RandomPosition, Range, extend, getRandom, getRandomInt, isArray, isString, lastTime, percentTrue, useArrayAsDirectory, vendors, x,
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

  Mat3 = (function() {
    function Mat3(init) {
      if (init === void 0) {
        this._m = new Float32Array([1, 0, 0, 0, 1, 0, 0, 0, 1]);
      } else {
        this._m = new Float32Array(init);
      }
    }

    Mat3.prototype.multVec = function(v) {
      var r;
      r = new Float32Array([0, 0, 0]);
      r[0] = this._m[0] * v[0] + this._m[1] * v[1] + this._m[2] * v[2];
      r[1] = this._m[3] * v[0] + this._m[4] * v[1] + this._m[5] * v[2];
      r[2] = this._m[6] * v[0] + this._m[7] * v[1] + this._m[8] * v[2];
      return r;
    };

    Mat3.prototype.multVecH = function(v) {
      var r;
      r = multVec(v);
      r[0] = r[0] / r[2];
      r[1] = r[1] / r[2];
      r[2] = void 0;
      return r;
    };

    Mat3.prototype.multMat = function(mat) {
      var m;
      m = new Mat3();
      m._m[0] = this._m[0] * mat._m[0] + this._m[1] * mat._m[3] + this._m[2] * mat._m[6];
      m._m[1] = this._m[0] * mat._m[1] + this._m[1] * mat._m[4] + this._m[2] * mat._m[7];
      m._m[2] = this._m[0] * mat._m[2] + this._m[1] * mat._m[5] + this._m[2] * mat._m[8];
      m._m[3] = this._m[3] * mat._m[0] + this._m[4] * mat._m[3] + this._m[5] * mat._m[6];
      m._m[4] = this._m[3] * mat._m[1] + this._m[4] * mat._m[4] + this._m[5] * mat._m[7];
      m._m[5] = this._m[3] * mat._m[2] + this._m[4] * mat._m[5] + this._m[5] * mat._m[8];
      m._m[6] = this._m[6] * mat._m[0] + this._m[7] * mat._m[3] + this._m[8] * mat._m[6];
      m._m[7] = this._m[6] * mat._m[1] + this._m[7] * mat._m[4] + this._m[8] * mat._m[7];
      m._m[8] = this._m[6] * mat._m[2] + this._m[7] * mat._m[5] + this._m[8] * mat._m[8];
      return m;
    };

    Mat3.prototype.determinant = function() {
      return this._m[0] * this._m[4] * this._m[8] + this._m[1] * this._m[5] * this._m[6] + this._m[2] * this._m[3] * this._m[7] - this._m[2] * this._m[4] * this._m[6] - this._m[1] * this._m[3] * this._m[8] - this._m[0] * this._m[5] * this._m[7];
    };

    Mat3.prototype.inverse = function() {
      var d, m;
      d = 1.0 / determinant();
      m = new Mat3();
      m._m[0] = d * (this._m[4] * this._m[8] - this._m[5] * this._m[7]);
      m._m[1] = d * (this._m[2] * this._m[7] - this._m[1] * this._m[8]);
      m._m[2] = d * (this._m[1] * this._m[5] - this._m[2] * this._m[4]);
      m._m[3] = d * (this._m[5] * this._m[6] - this._m[3] * this._m[8]);
      m._m[4] = d * (this._m[0] * this._m[8] - this._m[2] * this._m[6]);
      m._m[5] = d * (this._m[2] * this._m[3] - this._m[0] * this._m[5]);
      m._m[6] = d * (this._m[3] * this._m[7] - this._m[4] * this._m[6]);
      m._m[7] = d * (this._m[1] * this._m[6] - this._m[0] * this._m[7]);
      m._m[8] = d * (this._m[0] * this._m[4] - this._m[1] * this._m[3]);
      return m;
    };

    Mat3.prototype.createTranslation = function(tx, ty) {
      return new Mat3([1, 0, tx, 0, 1, ty, 0, 0, 1]);
    };

    Mat3.prototype.createScale = function(sx, sy) {
      return new Mat3([sx, 0, 0, 0, sy, 0, 0, 0, 1]);
    };

    Mat3.prototype.createRotation = function(angle) {
      var c, s;
      c = Math.cos(angle);
      s = Math.sin(angle);
      return new Mat3([c, -s, 0, s, c, 0, 0, 0, 1]);
    };

    Mat3.prototype.translate = function(tx, ty) {
      return this.createTranslation(tx, ty).multMat(this);
    };

    Mat3.prototype.scale = function(px, py, sx, sy) {
      return this.createTranslation(px, py).multMat(this.createScale(sx, sy).multMat(this.createTranslation(-px, -py).multMat(this)));
    };

    Mat3.prototype.rotate = function(px, py, angle) {
      return this.createTranslation(px, py).multMat(this.createRotation(angle).multMat(this.createTranslation(-px, -py).multMat(this)));
    };

    return Mat3;

  })();

  ImageTransform = (function() {
    function ImageTransform() {}

    ImageTransform.prototype.transformImage = function(image, transformation, w, h) {
      var dstoff, img, offset, pos, y, _results;
      img = {
        width: w,
        height: h,
        data: new Uint8ClampedArray(w * h * 4)
      };
      dstoff = 0;
      y = 0;
      _results = [];
      while (y < h) {
        x = 0;
        while (x < w) {
          pos = transformation.multVecH([x, y, 1]);
          offset = (Math.round(pos.x) + Math.round(pos.y) * image.width) * 4;
          img.data[dstoff++] = image.data[offset + 0];
          img.data[dstoff++] = image.data[offset + 1];
          img.data[dstoff++] = image.data[offset + 2];
          img.data[dstoff++] = image.data[offset + 3];
          ++x;
        }
        _results.push(++y);
      }
      return _results;
    };

    return ImageTransform;

  })();

  describe('test publish/subscribe mechanism', function() {
    var ps;
    ps = {};
    beforeEach(function() {
      return ps = new PublishSubscriber();
    });
    afterEach(function() {
      return ps = {};
    });
    it('instantiates PublishSubscriber', function() {
      return expect(typeof ps).toBe('object');
    });
    it('registers channel', function() {
      ps.registerChannel('FOO', {
        value: 'bar'
      });
      return expect(ps.getValue('FOO', '')).toBe('bar');
    });
    it('unregisters channel', function() {
      ps.registerChannel('FOO', {
        value: 'bar'
      });
      expect(ps.getChannel('FOO')).toNotBe(null);
      ps.unregisterChannel('FOO');
      return expect(ps.getChannel('FOO')).toBe(null);
    });
    it('changes channel value', function() {
      ps.registerChannel('FOO', {
        value: 'BAR'
      });
      ps.setValue('FOO', 'JOHN', 'BAZ');
      return expect(ps.getValue('FOO', 'JOHN')).toBe('BAZ');
    });
    it('notify on channel change', function() {
      var isNotified;
      isNotified = false;
      ps.registerChannel('FOO', {
        value: 'bar'
      });
      ps.subscribe('FOO', 'ME', function() {
        return isNotified = true;
      });
      ps.setValue('FOO', '', 'baz');
      return expect(isNotified).toBe(true);
    });
    it('multiple subscribers', function() {
      var channelAIsNotified, channelBIsNotified;
      channelAIsNotified = false;
      channelBIsNotified = false;
      ps.registerChannel('FOO', {
        value: 'bar'
      });
      ps.subscribe('FOO', 'A', function() {
        return channelAIsNotified = true;
      });
      ps.subscribe('FOO', 'B', function() {
        return channelBIsNotified = true;
      });
      ps.setValue('FOO', '', 'BAZ');
      expect(channelAIsNotified).toBe(true);
      return expect(channelBIsNotified).toBe(true);
    });
    it('does not get self-notified on change', function() {
      var channelAIsNotified, channelBIsNotified;
      channelAIsNotified = false;
      channelBIsNotified = false;
      ps.registerChannel('FOO', {
        value: 'bar'
      });
      ps.subscribe('FOO', 'A', function() {
        return channelAIsNotified = true;
      });
      ps.subscribe('FOO', 'B', function() {
        return channelBIsNotified = true;
      });
      ps.setValue('FOO', 'A', 'BAZ');
      expect(channelAIsNotified).toBe(false);
      return expect(channelBIsNotified).toBe(true);
    });
    it('unregister channel', function() {
      var notifyCount;
      notifyCount = 0;
      ps.registerChannel('FOO', {
        value: 'bar'
      });
      ps.subscribe('FOO', 'ITSME', function() {
        return notifyCount++;
      });
      ps.setValue('FOO', '', 'baz');
      expect(notifyCount).toBe(1);
      ps.setValue('FOO', '', 'barr');
      expect(notifyCount).toBe(2);
      ps.unsubscribe('FOO', 'ITSME');
      ps.setValue('FOO', '', 'bla');
      return expect(notifyCount).toBe(2);
    });
    it('read from non-existant channel', function() {
      expect(ps.getChannel("foo")).toBe(null);
      return expect(ps.getValue("foo", "A")).toBe(null);
    });
    it('create channel upon subscription', function() {
      var isNotified;
      isNotified = false;
      expect(ps.getChannel("FOO")).toBe(null);
      ps.subscribe('FOO', 'A', function() {
        return isNotified = true;
      });
      expect(ps.getChannel("FOO")).toNotBe(null);
      expect(ps.getValue('FOO', 'A')).toBe("");
      ps.setValue('FOO', '', 42);
      expect(ps.getValue('FOO', 'A')).toBe(42);
      return expect(isNotified).toBe(true);
    });
    it('create channel upon write', function() {
      expect(ps.getChannel("FOO")).toBe(null);
      ps.setValue('FOO', "A", 42);
      expect(ps.getChannel("FOO")).toNotBe(null);
      return expect(ps.getValue("FOO", "A")).toBe(42);
    });
    it('create channels from variables', function() {
      var FOO, notified;
      FOO = {
        BAR: 5
      };
      notified = false;
      ps.publish(FOO, 'BAR', 'PublicBAR');
      ps.subscribe('PublicBAR', 'Notifier', function() {
        return notified = true;
      });
      expect(notified).toBe(false);
      FOO.BAR = 2;
      return expect(notified).toBe(true);
    });
    return it('get public channel list', function() {
      var FOO, FOZ, chanlist;
      FOO = {
        BAR: 5
      };
      FOZ = {
        BAZ: 3
      };
      ps.subscribe('TestChannel', 'WAT', function() {});
      ps.publish(FOO, 'BAR', 'PublicBAR');
      ps.publish(FOZ, 'BAZ', 'PublicBAZ');
      chanlist = ps.getPublishedChannels();
      expect(chanlist).toContain('PublicBAR');
      expect(chanlist).toContain('PublicBAZ');
      return expect(chanlist).toNotContain('TestChannel');
    });
  });

  describe('test Mutables', function() {
    var mc;
    mc = {};
    beforeEach(function() {
      return mc = new MutableController;
    });
    afterEach(function() {
      return mc = {};
    });
    it('successfully instantiates MutableController', function() {
      return expect(typeof mc).toBe('object');
    });
    it('registers a Mutable with a RandomIntervalNumber and update Mutable via MutableController', function() {
      var m, value;
      m = new Mutable({
        value: new RandomIntervalNumber(0, 1)
      });
      m.cycle.setValue(3);
      mc.registerMutable(m);
      expect(m.valueOf()).toBeLessThan(1.01);
      expect(m.valueOf()).toBeGreaterThan(-0.01);
      value = m.valueOf();
      mc.update();
      return expect(m.valueOf()).not.toEqual(value);
    });
    return it('registers a Mutable with a RandomPosition and update Mutable via MutableController', function() {
      var m, newValue, value;
      m = new Mutable({
        value: new RandomPosition(1, 20, 10, 30),
        cycle: {
          min: 1,
          max: 4
        }
      });
      mc.registerMutable(m);
      value = m.valueOf();
      expect(value.x).toBeGreaterThan(0.99);
      expect(value.x).toBeLessThan(20.01);
      expect(value.y).toBeGreaterThan(9.99);
      expect(value.y).toBeLessThan(30.01);
      mc.update();
      newValue = m.valueOf();
      expect(value.x).not.toEqual(newValue.x);
      return expect(value.y).not.toEqual(newValue.y);
    });
  });

  describe('2D Transformation test', function() {
    beforeEach(function() {});
    afterEach(function() {});
    it('Creates 2D Transformation', function() {
      var m;
      m = new Mat3().createTranslation(5, 5);
      return expect(typeof m).toBe('object');
    });
    it('translates point', function() {
      var T, result;
      T = new Mat3().translate(5, 5);
      result = T.multVec([1, 2, 1]);
      expect(result[0]).toBe(5 + 1);
      return expect(result[1]).toBe(5 + 2);
    });
    it('scales point', function() {
      var T, result;
      T = new Mat3().scale(1, 1, 2, 3);
      result = T.multVec([3, 4, 1]);
      expect(result[0]).toBe((3 - 1) * 2 + 1);
      return expect(result[1]).toBe((4 - 1) * 2 + 1);
    });
    return it('rotates point', function() {
      var T;
      T = new (Mat3().result = T.multVec([1, 2, 1]));
      expect(result[0]).toBe(5 + 1);
      return expect(result[1]).toBe(5 + 2);
    });
  });

}).call(this);
