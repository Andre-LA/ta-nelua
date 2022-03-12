# ta-nelua

Lexer to add [Nelua](https://nelua.io/) support to [Textadept](https://foicica.com/textadept/) editor.

## How to install

* Clone or download the repository;
* Move the lexer/nelua.lua file to *_USERHOME*/lexers/ directory;
* Move the ta-nelua directory to *_USERHOME*/modules/ directory;
* Add this line to your *_USERHOME*/init.lua: ``require("ta-nelua")``;

> Note : *_USERHOME* it's your textadept userhome directory, by default: `~/.textadept/` on Linux and `C:\Users\your_username\.textadept` on Windows)

## Usage

When opening any .nelua file, the nelua lexer will be selected automatically.

To run or compile a file, you either:
* use `Ctrl+R` to run; `Shift+Ctrl+R` to compile;
* go to `Tools -> Run` to run; `Tools -> Compile` to compile

If your file is on a VCS (Bazaar, Git, Mercurial, or SVN) directory, the root of the VCS project will be considered the working directory to run/compile.

Consult *Compile, Run, and Build* section of [Textadept's Manual](https://foicica.com/textadept/manual.html) for more information.

## Preview

![Textadept preview using base16-ashes-dark theme](ta_preview.png)
