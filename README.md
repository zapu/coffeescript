
                                      ICED

                                       _____       __  __
                                      / ____|     / _|/ _|
     .- ----------- -.               | |     ___ | |_| |_ ___  ___
    (  (ice cubes)    )              | |    / _ \|  _|  _/ _ \/ _ \
    |`-..________ ..-'|              | |___| (_) | | | ||  __/  __/
    |                 |               \_____\___/|_| |_| \___|\___|
    |                 ;--.
    |                (__  \            _____           _       _
    |                 | )  )          / ____|         (_)     | |
    |                 |/  /          | (___   ___ _ __ _ _ __ | |_
    |                 (  /            \___ \ / __| '__| | '_ \| __|
    |                 |/              ____) | (__| |  | | |_) | |_
    |                 |              |_____/ \___|_|  |_| .__/ \__|
     `-.._________..-'                                  | |
                                                        |_|

CoffeeScript is a little language that compiles into JavaScript.
IcedCoffeeScript is a superset of CoffeeScript that adds two new
keywords: `await` and `defer`.

## Iced v3 Alpha

We're current alpha-testing Iced v3, which emits ES6 with `yield`s and generators.
Relative to Iced v2, this version stays much closer to the CoffeeScript main body of
code, and emits much simpler code. The downside is that the target must run ES6, or
be transpiled into ES5 with a further step not handled by the this package.

## How to Build

(Details here)

## Installation

If you have the node package manager, npm, installed:

```shell
npm install -g coffee-script
```

Leave off the `-g` if you don't wish to install globally. If you don't wish to use npm:

```shell
git clone https://github.com/jashkenas/coffeescript.git
sudo coffeescript/bin/cake install
```

## Getting Started

Execute a script:

```shell
coffee /path/to/script.coffee
```

Compile a script:

```shell
coffee -c /path/to/script.coffee
```

For documentation, usage, and examples, see: http://coffeescript.org/

To suggest a feature or report a bug: http://github.com/jashkenas/coffeescript/issues

If you'd like to chat, drop by #coffeescript on Freenode IRC.

The source repository: https://github.com/jashkenas/coffeescript.git

Changelog: http://coffeescript.org/#changelog

Our lovely and talented contributors are listed here: http://github.com/jashkenas/coffeescript/contributors
