###
This is a release script for Iced-Coffee-Script.


To run this script, a working iced compiler is needed (not just
coffee, this script uses await/defer).


Iced-Coffee-Script version number is derived from package.json and
coffee-script.coffee file. The only "editable" number is "Iced Patch
Version", which is the third number in package.json version field.

The final version will be the following:

<100*CS.Major + CS.Minor>. <CS.Patch> . <ICED.Patch>

This script will overwrite the version in package.json with the final
version.


For the release, full compilation will be performed, that is: build,
build:parser, and then build again. Then, the tests will run. After
that, browser version is built (along with inline-runtime). Browser
building automatically runs test:browser.

package.json will be changed. JSON.parse and JSON.stringify is used,
so the caveat is that all formatting will be lost.

After doing all of the above, script will pause and ask if you want to
continue. If so, a release commit and a release tag will be made by
invoking git commands.

The program then exits. If you are happy with the results, you can
push to github and publish to npm. If not, doing `git reset --soft
HEAD~` and `git tag -d tag_name` should be enough to undo repository
changes.
###

{spawn, exec} = require 'child_process'
fs = require 'fs'

iced_spawn = (bin, args, cb) ->
    console.log "(spawning `#{bin} #{args.join(' ')}`)"
    proc =         spawn bin, args, cwd: '..'
    proc.stdout.on 'data', (buffer) -> console.log buffer.toString()
    proc.stderr.on 'data', (buffer) -> console.log buffer.toString()
    proc.on        'exit', (status) ->
        if status != 0
            console.log "(#{bin} failed with status #{status})"
            process.exit(1)
        cb() if typeof cb is 'function'

cake = (args, cb) -> iced_spawn 'node', ['bin/cake'].concat(args), cb

ask = (question, cb) ->
    process.stdout.write "#{question} (type 'yes', or abort with ^C) "
    process.stdin.setEncoding 'utf8'
    process.stdin.once 'data', (val) ->
        process.stdin.pause()

        val = val.trim().toLowerCase()
        if val == 'yes'
            cb()
        else
            ask question, cb

    process.stdin.resume()

write_package_version = (ver) ->
    json = JSON.parse fs.readFileSync '../package.json'
    json.version = ver
    fs.writeFileSync '../package.json', JSON.stringify json, null, 2

console.log '* Proceeding with build'

await cake ['build'], defer()
await cake ['build:parser'], defer()
await cake ['build'], defer()

# Nuclear approach to ensure we get the fresh build. We should
# probably be fine by clearing just index.js and coffee-script.js,
# though.
for i in Object.keys require.cache
    delete require.cache[i]
CoffeeScript = require '../lib-iced/coffee-script'

coffee_version = CoffeeScript.VERSION
patch_version = CoffeeScript.ICED_PATCH_VERSION
final_version = CoffeeScript.ICED_VERSION

console.log """

Current Coffee-Script version (from coffee-script.coffee): #{coffee_version}
Current IcedCoffeeScript patch version: #{patch_version}
Releasing iced under version: #{final_version}

"""

console.log '* Running tests'

await cake ['test'], defer()

console.log '* Building browser support'

await cake ['build:inline-runtime'], defer()
await cake ['build:browser'], defer()

console.log "* Writing version #{final_version} to package.json"

write_package_version final_version

console.log """
Iced has been built and unit-tested.
Please examine test output and see if there are no unexpected failures.

You should also examine repository changes.

What will happen next:
- lib-iced/coffee-script/*.js, extras/coffee-script.js, package.json will be staged
- git commit will be made with #{final_version} release message.
- signed git tag will be made, of name \"v#{final_version}\", and the same tag message.

"""

await ask "Do you want to continue?", defer()

await iced_spawn 'git', ['add', 'package.json'], defer()
await iced_spawn 'git', ['add', 'lib-iced/coffee-script/*.js'], defer()
await iced_spawn 'git', ['add', 'extras/iced-coffee-script.js'], defer()

await iced_spawn 'git', ['commit', '-m', "IcedCoffeeScript release #{final_version}"], defer()
await iced_spawn 'git', ['tag', '-s', "v#{final_version}", '-m', "v#{final_version}"], defer()

console.log """

Done.

Check if the commit looks right and then git push, npm publish.
"""
