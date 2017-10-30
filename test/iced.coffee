
delay = (cb, i) ->
   i = i || 3
   setTimeout cb, i

atest "nested of/in loop", (cb) ->
  counter = 0
  bar = () ->
    if counter++ > 100
      throw new Error "infinite loop found"
  for a,b of { foo : 1 }
    for v, i in [0,1]
      await delay defer()
    bar()
  cb true, {}

atest "basic iced waiting", (cb) ->
   i = 1
   await delay defer()
   i++
   cb(i is 2, {})

foo = (i, cb) ->
  await delay(defer(), i)
  cb(i)

atest "basic iced waiting", (cb) ->
   i = 1
   await delay defer()
   i++
   cb(i is 2, {})

atest "basic iced trigger values", (cb) ->
   i = 10
   await foo(i, defer j)
   cb(i is j, {})

atest "basic iced set structs", (cb) ->
   field = "yo"
   i = 10
   obj = { cat : { dog : 0 } }
   await
     foo(i, defer obj.cat[field])
     field = "bar" # change the field to make sure that we captured "yo"
   cb(obj.cat.yo is i, {})

multi = (cb, arr) ->
  await delay defer()
  cb.apply(null, arr)

atest "defer splats", (cb) ->
  v = [ 1, 2, 3, 4]
  obj = { x : 0 }
  await multi(defer(obj.x, out...), v)
  out.unshift obj.x
  ok = true
  for i in [0..v.length-1]
    ok = false if v[i] != out[i]
  cb(ok, {})

atest "continue / break test" , (cb) ->
  tot = 0
  for i in [0..100]
    await delay defer()
    continue if i is 3
    tot += i
    break if i is 10
  cb(tot is 52, {})

atest "for k,v of obj testing", (cb) ->
  obj = { the : "quick", brown : "fox", jumped : "over" }
  s = ""
  for k,v of obj
    await delay defer()
    s += k + " " + v + " "
  cb( s is "the quick brown fox jumped over ", {} )

atest "for k,v in arr testing", (cb) ->
  obj = [ "the", "quick", "brown" ]
  s = ""
  for v,i in obj
    await delay defer()
    s += v + " " + i + " "
  cb( s is "the 0 quick 1 brown 2 ", {} )

atest "switch --- github issue #55", (cb) ->
  await delay defer()
  switch "blah"
    when "a"
      await delay defer()
    when "b"
      await delay defer()
  cb( true, {} )

atest "switch-a-roos", (cb) ->
  res = 0
  for i in [0..4]
    await delay defer()
    switch i
      when 0 then res += 1
      when 1
        await delay defer()
        res += 20
      when 2
        await delay defer()
        if false
          res += 100000
        else
          await delay defer()
          res += 300
      else
        res += i*1000
    res += 10000 if i is 2
  cb( res is 17321, {} )


atest "parallel awaits with classes", (cb) ->
  class MyClass
    constructor: ->
      @val = 0
    increment: (wait, i, cb) ->
      await setTimeout(defer(),wait)
      @val += i
      await setTimeout(defer(),wait)
      @val += i
      cb()
    getVal: -> @val

  obj = new MyClass()
  await
    obj.increment 10, 1, defer()
    obj.increment 20, 2, defer()
    obj.increment 30, 4, defer()
  v = obj.getVal()
  cb(v is 14, {})

atest "loop construct", (cb) ->
  i = 0
  loop
    await delay defer()
    i += 1
    await delay defer()
    break if i is 10
    await delay defer()
  cb(i is 10, {})

test "`this` points to object instance in methods with await", ->
  class MyClass
    huh: (cb) ->
      ok @a is 'a'
      await delay defer()
      cb()
  o = new MyClass
  o.a = 'a'
  o.huh(->)

atest "AT variable works in an await (1)", (cb) ->
  class MyClass
    constructor : ->
      @flag = false
    chill : (cb) ->
      await delay defer()
      cb()
    run : (cb) ->
      await @chill defer()
      @flag = true
      cb()
    getFlag : -> @flag
  o = new MyClass
  await o.run defer()
  cb(o.getFlag(), {})

atest "test nested serial/parallel", (cb) ->
  slots = []
  await
    for i in [0..10]
      ( (j, cb) ->
        await delay defer(), 5 * Math.random()
        await delay defer(), 4 * Math.random()
        slots[j] = true
        cb()
      )(i, defer())
  ok = true
  for i in [0..10]
    ok = false unless slots[i]
  cb(ok, {})

atest "test scoping", (cb) ->
  class MyClass
    constructor : -> @val = 0
    run : (cb) ->
      @val++
      await delay defer()
      @val++
      await
        class Inner
          chill : (cb) ->
            await delay defer()
            @val = 0
            cb()
        i = new Inner
        i.chill defer()
      @val++
      await delay defer()
      @val++
      await
        ( (cb) ->
          class Inner
            chill : (cb) ->
              await delay defer()
              @val = 0
              cb()
          i = new Inner
          await i.chill defer()
          cb()
        )(defer())
      ++@val
      cb(@val)
    getVal : -> @val
  o = new MyClass
  await o.run defer(v)
  cb(v is 5, {})

atest "AT variable works in an await (2)", (cb) ->
  class MyClass
    constructor : -> @val = 0
    inc : -> @val++
    chill : (cb) ->
      await delay defer()
      cb()
    run : (cb) ->
      await @chill defer()
      for i in [0..9]
        await @chill defer()
        @inc()
      cb()
    getVal : -> @val
  o = new MyClass
  await o.run defer()
  cb(o.getVal() is 10, {})

atest "fat arrow versus iced", (cb) ->
  class Foo
    constructor : ->
      @bindings = {}

    addHandler : (key,cb) ->
      @bindings[key] = cb

    useHandler : (key, args...) ->
      @bindings[key](args...)

    delay : (cb) ->
      await delay defer()
      cb()

    addHandlers : ->
      @addHandler "sleep1", (cb) =>
        await delay defer()
        await @delay defer()
        cb(true)
      @addHandler "sleep2", (cb) =>
        await @delay defer()
        await delay defer()
        cb(true)

  ok1 = ok2 = false
  f = new Foo()
  f.addHandlers()
  await f.useHandler "sleep1", defer(ok1)
  await f.useHandler "sleep2", defer(ok2)
  cb(ok1 and ok2, {})

atest "nested loops", (cb) ->
  val = 0
  for i in [0..9]
    await delay(defer(),1)
    for j in [0..9]
      await delay(defer(),1)
      val++
  cb(val is 100, {})

atest "until", (cb) ->
  i = 10
  out = 0
  until i is 0
    await delay defer()
    out += i--
  cb(out is 55, {})

atest 'super with no args', (cb) ->
  class P
    constructor: ->
      @x = 10
  class A extends P
    constructor : ->
      super()
    foo : (cb) ->
      await delay defer()
      cb()
  a = new A
  await a.foo defer()
  cb(a.x is 10, {})

atest 'nested for .. of .. loops', (cb) ->
  x =
    christian:
      age: 36
      last: "rudder"
    max:
      age: 34
      last: "krohn"

  tot = 0
  for first, info of x
    tot += info.age
    for k,v of info
      await delay defer()
      tot++
  cb(tot is 74, {})

atest "for + guards", (cb) ->
  v = []
  for i in [0..10] when i % 2 is 0
    await delay defer()
    v.push i
  cb(v[3] is 6, {})

atest "while + guards", (cb) ->
  i = 0
  v = []
  while (x = i++) < 10 when x % 2 is 0
    await delay defer()
    v.push x
  cb(v[3] is 6, {})

atest "nested loops + inner break", (cb) ->
  i = 0
  while i < 10
    await delay defer()
    j = 0
    while j < 10
      if j == 5
        break
      j++
    i++
  res = j*i
  cb(res is 50, {})

atest "defer and object assignment", (cb) ->
  baz = (cb) ->
    await delay defer()
    cb { a : 1, b : 2, c : 3}
  out = []
  await
    for i in [0..2]
      switch i
        when 0 then baz defer { c : out[i] }
        when 1 then baz defer { b : out[i] }
        when 2 then baz defer { a : out[i] }
  cb( out[0] is 3 and out[1] is 2 and out[2] is 1, {} )

atest 'defer + arguments', (cb) ->
  bar = (i, cb) ->
    await delay defer()
    arguments[1](arguments[0])
  await bar 10, defer x
  cb(10 is x, {})

atest 'for in by + await', (cb) ->
  res = []
  for i in [0..10] by 3
    await delay defer()
    res.push i
  cb(res.length is 4 and res[3] is 9, {})

atest 'super after await', (cb) ->
  class A
    constructor : ->
      @_i = 0
    foo : (cb) ->
      await delay defer()
      @_i += 1
      cb()
  class B extends A
    constructor : ->
      super()
    foo : (cb) ->
      await delay defer()
      await delay defer()
      @_i += 2
      super cb
  b = new B()
  await b.foo defer()
  cb(b._i is 3, {})

atest 'more for + when (Issue #38 via @boris-petrov)', (cb) ->
  x = 'x'
  bar = { b : 1 }
  for o in [ { p : 'a' }, { p : 'b' } ] when bar[o.p]?
    await delay defer()
    x = o.p
  cb(x is 'b', {})

atest 'for + ...', (cb) ->
  x = 0
  inc = () ->
    x++
  for i in [0...10]
    await delay defer(), 0
    inc()
  cb(x is 10, {})

atest 'negative strides (Issue #86 via @davidbau)', (cb) ->
  last_1 = last_2 = -1
  tot_1 = tot_2 = 0
  for i in [4..1]
    await delay defer(), 0
    last_1 = i
    tot_1 += i
  for i in [4...1]
    await delay defer(), 0
    last_2 = i
    tot_2 += i
  cb ((last_1 is 1) and (tot_1 is 10) and (last_2 is 2) and (tot_2 is 9)), {}

atest "positive strides", (cb) ->
  total1 = 0
  last1 = -1
  for i in [1..5]
    await delay defer(), 0
    total1 += i
    last1 = i
  total2 = 0
  last2 = -1
  for i in [1...5]
    await delay defer(), 0
    total2 += i
    last2 = i
  cb ((total1 is 15) and (last1 is 5) and (total2 is 10) and (last2 is 4)), {}

atest "positive strides with expression", (cb) ->
  count = 6
  total1 = 0
  last1 = -1
  for i in [1..count-1]
    await delay defer(), 0
    total1 += i
    last1 = i
  total2 = 0
  last2 = -1
  for i in [1...count]
    await delay defer(), 0
    total2 += i
    last2 = i
  cb ((total1 is 15) and (last1 is 5) and (total2 is 15) and (last2 is 5)), {}

atest "negative strides with expression", (cb) ->
  count = 6
  total1 = 0
  last1 = -1
  for i in [count-1..1]
    await delay defer(), 0
    total1 += i
    last1 = i
  total2 = 0
  last2 = -1
  for i in [count...1]
    await delay defer(), 0
    total2 += i
    last2 = i
  cb ((total1 is 15) and (last1 is 1) and (total2 is 20) and (last2 is 2)), {}

atest "loop without looping variable", (cb) ->
  count = 6
  total1 = 0
  for [1..count]
    await delay defer(), 0
    total1 += 1
  total2 = 0
  for i in [count..1]
    await delay defer(), 0
    total2 += 1
  cb ((total1 is 6) and (total2 is 6)), {}

atest "destructuring assignment in defer", (cb) ->
  j = (cb) ->
    await delay defer(), 0
    cb { z : 33 }
  await j defer { z }
  cb(z is 33, {})

atest 'defer + class member assignments', (cb) ->
  myfn = (cb) ->
    await delay defer()
    cb 3, { y : 4, z : 5}
  class MyClass2
    f : (cb) ->
      await myfn defer @x, { @y , z }
      cb z
  c = new MyClass2()
  await c.f defer z
  cb(c.x is 3 and c.y is 4 and z is 5,  {})

# tests bug #146 (github.com/maxtaco/coffee-script/issues/146)
atest 'deferral variable with same name as a parameter in outer scope', (cb) ->
  val = 0
  g = (cb) ->
    cb(2)
  f = (x) ->
    (->
      val = x
      await g defer(x)
    )()
  f 1
  cb(val is 1, {})

atest 'funcname with double quotes is safely emitted', (cb) ->
  v = 0
  b = {}

  f = -> v++
  b["xyz"] = ->
    await f defer()

  do b["xyz"]

  cb(v is 1, {})

atest 'consistent behavior of ranges with and without await', (cb) ->
  arr1 = []
  arr2 = []
  for x in [3..0]
    await delay defer()
    arr1.push x

  for x in [3..0]
    arr2.push x

  arrayEq arr1, arr2

  arr1 = []
  arr2 = []
  for x in [3..0] by -1
    await delay defer()
    arr1.push x

  for x in [3..0] by -1
    arr2.push x

  arrayEq arr1, arr2

  for x in [3...0] by 1
    await delay defer()
    throw new Error 'Should never enter this loop'

  for x in [3...0] by 1
    throw new Error 'Should never enter this loop'

  for x in [3..0] by 1
    await delay defer()
    throw new Error 'Should never enter this loop'

  for x in [3..0] by 1
    throw new Error 'Should never enter this loop'

  for x in [0..3] by -1
    throw new Error 'Should never enter this loop'
    await delay defer()

  for x in [0..3] by -1
    throw new Error 'Should never enter this loop'

  arr1 = []
  arr2 = []
  for x in [3..0] by -2
    ok x <= 3
    await delay defer()
    arr1.push x

  for x in [3..0] by -2
    arr2.push x

  arrayEq arr1, arr2

  arr1 = []
  arr2 = []
  for x in [0..3] by 2
    await delay defer()
    arr1.push x

  for x in [0..3] by 2
    arr2.push x

  arrayEq arr1, arr2

  cb true, {}

atest 'loops with defers (Issue #89 via @davidbau)', (cb) ->
  arr = []
  for x in [0..3] by 2
    await delay defer()
    arr.push x
  arrayEq [0, 2], arr

  arr = []
  for x in ['a', 'b', 'c']
    await delay defer()
    arr.push x
  arrayEq arr, ['a', 'b', 'c']

  arr = []
  for x in ['a', 'b', 'c'] by 1
    await delay defer()
    arr.push x
  arrayEq arr, ['a', 'b', 'c']

  arr = []
  for x in ['d', 'e', 'f', 'g'] by 2
    await delay defer()
    arr.push x
  arrayEq arr, [ 'd', 'f' ]

  arr = []
  for x in ['a', 'b', 'c'] by -1
    await delay defer()
    arr.push x
  arrayEq arr, ['c', 'b', 'a']

  arr = []
  step = -2
  for x in ['a', 'b', 'c'] by step
    await delay defer()
    arr.push x
  arrayEq arr, ['c', 'a']

  cb true, {}

atest "nested loops with negative steps", (cb) ->
  v1 = []
  for i in [10...0] by -1
    for j in [10...i] by -1
      await delay defer()
      v1.push (i*1000)+j
  v2 = []
  for i in [10...0] by -1
    for j in [10...i] by -1
      v2.push (i*1000)+j
  arrayEq v1, v2
  cb true, {}

atest 'loop with function as step', (cb) ->
  makeFunc = ->
    calld = false
    return ->
      if calld
        throw Error 'step function called twice'

      calld = true
      return 1

  # Basically, func should be called only once and its result should
  # be used as step.

  func = makeFunc()
  arr = []
  for x in [1,2,3] by func()
    arr.push x

  arrayEq [1,2,3], arr

  func = makeFunc()
  arr = []
  for x in [1,2,3] by func()
    await delay defer()
    arr.push x

  arrayEq [1,2,3], arr

  func = makeFunc()
  arr = []
  for x in [1..3] by func()
    arr.push x

  arrayEq [1,2,3], arr

  func = makeFunc()
  arr = []
  for x in [1..3] by func()
    await delay defer()
    arr.push x

  arrayEq [1,2,3], arr

  cb true, {}

atest 'arguments clash', (cb) ->
  func = (cb, test) ->
    _arguments = [1,2,3]
    await delay defer(), 1
    cb(arguments[1])

  await func defer(res), 'test'
  cb res == 'test', {}

atest 'can return immediately from awaited func', (cb) ->
  func = (cb) ->
    cb()

  await func defer()
  cb true, {}

atest 'using defer in other contexts', (cb) ->
  a =
    defer: ->
      cb true, {}

  await delay defer()
  a.defer()

atest 'await race condition with immediate defer (issue #175)', (test_cb) ->
  foo = (cb) ->
    cb()

  bar = (cb) ->
    # The bug here was that after both "defer()" calls, Deferrals
    # counter should be 2, so it knows it has to wait for two
    # callbacks. But because foo calls cb immediately, Deferalls is
    # considered completed before it reaches second defer() call.
    await
      foo defer()
      delay defer()

    await delay defer()
    cb()

  await bar defer()

  test_cb true, {}

atest 'await race condition pesky conditions (issue #175)', (test_cb) ->
  foo = (cb) -> cb()

  # Because just checking for child node count is not enough
  await
    if 1 == 1
      foo defer()
      delay defer()

  test_cb true, {}

atest 'await potential race condition but not really', (test_cb) ->
  await
    if test_cb == 'this is not even a string'
      delay defer()
    delay defer()

  test_cb true, {}

atest 'awaits that do not really wait for anything', (test_cb) ->
  await
    if test_cb == 'this is not even a string'
      delay defer()
      delay defer()

  await
    if test_cb == 'this is not even a string'
      delay defer()

  test_cb true, {}

# helper to assert that a string should fail compilation
cantCompile = (code) ->
  throws ->
    CoffeeScript.compile code
    console.error "Compiling\n#{code}\nshould throw but didn't"

atest "await expression assertions 1", (cb) ->
  cantCompile '''
    x = if true
      await foo defer bar
      bar
    else
      10
'''
  cantCompile '''
    foo if true
      await foo defer bar
      bar
    else 10
'''
  cantCompile '''
    if (if true
      await foo defer bar
      bar) then 10
    else 20
'''
  cantCompile '''
    while (
      await foo defer bar
      bar
      )
      say_ho()
'''
  cantCompile '''
    for i in (
      await foo defer bar
      bar)
      go_nuts()
'''
  cantCompile '''
     switch (
        await foo defer bar
        10
      )
        when 10 then 11
        else 20
'''
  cb true, {}

atest "autocb is illegal", (cb) ->
  cantCompile '''
    func = (autocb) ->
'''

  cb true, {}

# Nasty evals! But we can't sandbox those, we expect the evaluated
# string to call our cb function.
atest "can run toplevel await", (cb) ->
  eval CoffeeScript.compile '''
await delay defer()
cb true, {}
''', { bare: true }

atest "can run toplevel await 2", (cb) ->
  eval CoffeeScript.compile '''
acc = 0
for i in [0..5]
  await delay defer()
  acc += 1
cb acc == 6, {}
''', { bare: true }

test "top level awaits are wrapped", ->
  js = CoffeeScript.compile '''
await delay defer()
cb true, {}
''', { bare: true }

  eq js.trim().indexOf("(function() {"), 0

atest "eval iced", (test_cb) ->
  global.cb = ->
    delete global.cb
    test_cb true, {}

  result = CoffeeScript.eval """
await setTimeout defer(), 1
cb()
""", { runtime: 'inline' }

if vm = require? 'vm'
  atest "eval sandbox iced", (test_cb) ->
    createContext = vm.Script.createContext ? vm.createContext
    sandbox = createContext()
    sandbox.delay = delay
    sandbox.cb = ->
      test_cb true, {}

    result = CoffeeScript.eval """
  await delay defer()
  cb()
  """, { runtime: 'inline', sandbox }

atest "iced coffee all the way down", (cb) ->
  js = CoffeeScript.compile """
  await delay defer()
  js_inside = CoffeeScript.compile 'await delay defer()\\ncb true, {}', { runtime: 'inline' }
  eval js_inside
  """, { bare: true, runtime: 'inline' }

  eval js

test "helpers.strToJavascript and back", ->
  str_to_js = CoffeeScript.helpers.strToJavascript

  # We use this to "encode" JavaScript files so naturally this test
  # should try to encode some JavaScript code snippet.
  test_string = str_to_js.toString()
  javascript_literal = str_to_js test_string
  eval "var back_to_string = #{javascript_literal};"

  eq back_to_string, test_string

# Tests if we are emitting 'traces' correctly and if runtime uses
# them to generate proper errors.

wrap_error = (test_cb, predicate) ->
  real_warn = console.error

  console.error = (msg) ->
    console.error = real_warn
    if predicate(msg)
      test_cb true, {}
    else
      console.error 'Unexpected overused deferral msg:', msg
      console.error 'Predicate is:', predicate
      test_cb false, {}

atest "overused deferral error message", (test_cb) ->
  wrap_error test_cb, (msg) ->
    msg.indexOf('test/iced.coffee:') != -1 and msg.indexOf('<anonymous>') != -1

  foo = (cb) -> cb(); cb()
  await foo defer()

atest "overused deferral error message 2", (test_cb) ->
  wrap_error test_cb, (msg) ->
    msg.indexOf('test/iced.coffee:') != -1 and msg.indexOf('A.b') != -1

  class A
    b: () ->
      foo = (cb) -> cb(); cb()
      await foo defer()

  new A().b()

atest "overused deferral error message 3", (test_cb) ->
  wrap_error test_cb, (msg) ->
    msg.indexOf('test/iced.coffee:') != -1 and msg.indexOf('<anonymous: anon_func>') != -1

  anon_func = ->
    foo = (cb) -> cb(); cb()
    await foo defer()

  anon_func()
