
## ES6 Progress

First successful compilation and execution of ICS-to-ES6 compilation today. See below for
more details, and a big todo list.

### Todo
  - [ ] Top-level `await`'s don't work
  - [ ] Babel/traceur plumbing to output runnable code on ES5 (! oy, looks painful).
  - [ ] Fix `autocb` or remove its support entirely
  - [ ] Maybe it's possible to use `o.scope.freeVariable`s for `__iced_it` and
        `__iced_passed_deferrals`,  but don't see how yet.
  - [ ] fix awaits in expressions (see "can await in expressions" test)
  - [ ] fix `package.json` to install as `icake` and `iced`.

### Input File:

[t1.iced](./t1.iced) in this directory:

```coffeescript
foo = (i, cb) ->
  await setTimeout defer(), i*1000
  cb i

bar = (cb) ->
  console.log "A"
  await foo 1, defer x
  console.log "B"
  await foo 2, defer y
  console.log "C"
  await console.log "dummy"
  cb x + y

bar (z) -> console.log z
```

### Output File:

[t1.js](./t1.js) in this directory:

```javascript
(function() {
  var bar, foo, iced;

  iced = require('iced-runtime');

  foo = (function(_this) {
    return function(i, cb) {
      var __iced_it, __iced_passed_deferral;
      __iced_passed_deferral = iced.findDeferral(arguments);
      __iced_it = (function*() {
        var __iced_deferrals;
        __iced_deferrals = new iced.Deferrals(__iced_it, {
          parent: __iced_passed_deferral
        });
        setTimeout(__iced_deferrals.defer({
          lineno: 3
        }), i * 1000);
        if (__iced_deferrals.await_exit()) {
          yield;
        }
        return cb(i);
      })();
      return __iced_it.next();
    };
  })(this);

  bar = (function(_this) {
    return function(cb) {
      var __iced_it, __iced_passed_deferral, x, y;
      __iced_passed_deferral = iced.findDeferral(arguments);
      __iced_it = (function*() {
        var __iced_deferrals, __iced_deferrals1, __iced_deferrals2;
        console.log("A");
        __iced_deferrals = new iced.Deferrals(__iced_it, {
          parent: __iced_passed_deferral
        });
        foo(1, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              return x = arguments[0];
            };
          })(),
          lineno: 8
        }));
        if (__iced_deferrals.await_exit()) {
          yield;
        }
        console.log("B");
        __iced_deferrals1 = new iced.Deferrals(__iced_it, {
          parent: __iced_passed_deferral
        });
        foo(2, __iced_deferrals1.defer({
          assign_fn: (function() {
            return function() {
              return y = arguments[0];
            };
          })(),
          lineno: 10
        }));
        if (__iced_deferrals1.await_exit()) {
          yield;
        }
        console.log("C");
        __iced_deferrals2 = new iced.Deferrals(__iced_it, {
          parent: __iced_passed_deferral
        });
        console.log("dummy");
        if (__iced_deferrals2.await_exit()) {
          yield;
        }
        return cb(x + y);
      })();
      return __iced_it.next();
    };
  })(this);

  bar(function(z) {
    return console.log(z);
  });

}).call(this);
```
