# vim-typo

![vim-typo_demo](https://github.com/tani/vim-typo/assets/5019902/dd75b622-231e-4785-a294-516f25b62eef)


Vim-typo is an auto-correction plugin for Vim/Neovim that relies on a syntax file to provide intelligent corrections while typing.

## Installation

To install vim-typo, follow the standard procedure for installing Vim plugins.
Here is an example using [vim-jetpack](https://github.com/tani/vim-jetpack):

```
 Jetpack 'tani/vim-typo'
```

## Configuration

No configuration is required.

## Algorithm Overview

The auto-correction algorithm used in vim-typo involves two main operations: completion and swapping.
Typos in words, excluding the first and last letters, are corrected.
The algorithm focuses specifically on correcting typos in words that are at least 6 characters long.

During typing, vim-typo dynamically retrieves the word source from the syntax file, enabling on-the-fly autocorrections.

## License

This plugin is released under the MIT License.
(c) 2023 Masaya Taniguchi

