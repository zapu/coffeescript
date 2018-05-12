resolveSoon = () ->
  new Promise (resolve) ->
    setTimeout (() -> resolve()), 1

module.exports = () ->
  await resolveSoon()
  12345
