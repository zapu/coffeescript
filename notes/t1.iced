

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
