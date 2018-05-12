# see if ES6 async coffee files can be imported from iced code

unless window? or testingBrowser?
  atest "coffee modules can be imported from iced", (cb) ->
    foo = require('./importing/imported_async.coffee')
    foo().then (val) ->
      cb val is 12345, {}
