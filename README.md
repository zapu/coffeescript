This is a branch where iced 4 development is taking place.

Iced4 took CoffeeScript 2 at commit

```
commit 694e69d872fc849a9c04dfdad0be33b946df2c4e
Author: Geoffrey Booth <GeoffreyBooth@users.noreply.github.com>
Date:   Mon Oct 2 22:19:32 2017 -0700
```

and started building from there.

Right now supported are:
- ES6 `await` or iced `await` depending on the file extension, or `--coffee` flag in cli.
- ES6 await is available as `waitfor` keyword in iced code.
- Generator-style transpiling for iced await from iced3 code branch.

All tests are passing. There are, however, certain incompatibilities between 
CoffeeScript 1 and CoffeeScript 2 which may require existing code bases to adapt
to be able to use Iced4.

TODO: Document incompatibilities
- super in constructors.
- `arguments` magic var in `=>` functions. 

also:
- no autocb
