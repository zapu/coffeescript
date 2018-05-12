# Required by ../importing.coffee

module.exports = (cb) ->
  for i in [0..2]
    await setTimeout defer(), 1
  cb null, 123
