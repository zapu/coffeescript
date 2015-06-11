

## How to implement ICS with ES6 Yield

Can either rely on yield native or [Traceur](https://github.com/google/traceur-compiler) or
[Regenerator](https://facebook.github.io/regenerator/) on ES5 implementations.

### Strategy

Input CS:

```coffeescript

foo = (x, cb) ->
  for i in [0...x]
    await
      console.log "wait #{i}"
      setTimeout defer(), i*10
  cb()
```

Output JS:

```javascript

function foo (x, cb) { var it = (function* () {
	for (var i = 0; i < x; i++) {
		(function(it) { var __iced_deferrals = new Deferrals(it);
			console.log("wait " + i);
	    	setTimeout(__iced_deferrals.Create(), i*10); yield false; })(it);
	})()
	cb()
}

```


