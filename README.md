# devshells

Use dev templates as flake templates or inside `.envrc`, where `<ENV>` is the specific enviroment:

## As flake init

```bash
nix flake init -t github:choffmann/devshells#<ENV>
```

For example:

```bash
nix flake init -t github:choffmann/devshells#rust
```

**Inside `.envrc`**

```
use flake github:choffmann/devshells?dir=<ENV>
```

For example:

```
use flake github:choffmann/devshells?dir=rust
```
