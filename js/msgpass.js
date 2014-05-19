(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

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

}).call(this);
