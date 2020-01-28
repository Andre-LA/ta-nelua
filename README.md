# ta-nelua

Lexer to add [Nelua](https://nelua.io/) support to [Textadept](https://foicica.com/textadept/)

For now, only the lexer is available.

## How to use

* Clone the repository;
* Move the file lexer/nelua.lua to *_USERHOME*/lexers/ directory;
* Add this line to your *_USERHOME*/init.lua: ``lua textadept.file_types.extensions.nelua = 'nelua'``;

(*_USERHOME* is your textadept userhome directory, by default, ~/.textadept/ or  C:\Users\username\.textadept)

## Preview

![Textadept preview using base16-ashes-dark theme](ta_preview.jpg)