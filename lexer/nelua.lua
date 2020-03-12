-- Copyright 2020 André Luiz Alvares. See License.txt
-- Nelua LPeg lexer.

-- This was written from scratch, using the Textadept's Lua
-- lexer from mitchell as guide

-- TODO: Update Lua libraries and other things once Lua 5.4 launches

local lexer = require('lexer')
local token, word_match = lexer.token, lexer.word_match
local P, R, S = lpeg.P, lpeg.R, lpeg.S

local lex = lexer.new('nelua')

-- Whitespace.
lex:add_rule('whitespace', token(lexer.WHITESPACE, lexer.space^1))

-- Keywords.

-- Lua keywords from: https://www.lua.org/manual/5.3/manual.html#3.1
-- Nelua keywords from: [Nelua source code/nelua/syntaxdefs.lua at line 53](https://github.com/edubart/nelua-lang/blob/e74db9f729d49807cf5a072363f206fa0b26bf43/nelua/syntaxdefs.lua#L53)
local keywords = token(lexer.KEYWORD, word_match[[
  -- (ne)lua keywords
  and break do else elseif end false for function if
  in local nil not or repeat return then true until while

  -- Added in 5.2
  goto

  -- nelua-only keywords
  switch case continue global
]])

lex:add_rule('keyword', keywords)

-- Types
-- from: [Nelua source code/nelua/typedefs.lua](https://github.com/edubart/nelua-lang/blob/e74db9f729d49807cf5a072363f206fa0b26bf43/nelua/typedefs.lua)
local type_op = S(':@')
lex:add_rule('type', token(lexer.OPERATOR, type_op) * lexer.space^0 * token(lexer.TYPE, lexer.word))

-- Functions and deprecated functions
-- from: https://www.lua.org/manual/5.1/contents.html#index,
--       https://www.lua.org/manual/5.2/contents.html#index and
--       https://www.lua.org/manual/5.3/contents.html#index

local functions = token(lexer.FUNCTION, word_match[[
  -- lua functions, some are available to nelua
  assert collectgarbage dofile error getmetatable ipairs load
  loadfile next pairs pcall print rawequal rawget rawset
  require select setmetatable tonumber tostring type xpcall

  -- Added in 5.2
  rawlen

  -- Added in 5.4, also available on nelua
  warn

  -- nelua functions
  likely unlikely
]])

local deprecated_functions = token('deprecated_functions', word_match([[
  -- Deprecated in 5.2
  getfenv loadstring module setfenv unpack
]]))

lex:add_rule('function', functions + deprecated_functions)
lex:add_style('deprecated_functions', lexer.STYLE_FUNCTION .. ',italics')

-- Constants
lex:add_rule('constant', token(lexer.CONSTANT, word_match[[
  _G _VERSION
  -- Added in 5.2
  _ENV
]]))

-- Lua libraries
local lua_libraries = token('library', word_match[[
  -- coroutine library
  coroutine.create coroutine.resume coroutine.running coroutine.status coroutine.wrap coroutine.yield
  -- Added in 5.3
  coroutine.isyieldable

  -- debug library
  debug.debug debug.gethook debug.getinfo debug.getlocal debug.getmetatable debug.getregistry debug.getupvalue debug.sethook debug.setlocal debug.setmetatable debug.setupvalue debug.traceback
  -- Added in 5.2
  debug.getuservalue debug.setuservalue debug.upvalueid debug.upvaluejoin

  -- io library
  io.close io.flush io.input io.lines io.open io.output io.popen io.read io.stderr io.stdin io.stdout io.tmpfile io.type io.write

  -- math library
  math.abs math.acos math.asin math.atan math.ceil math.cos math.deg math.exp math.floor math.fmod math.huge math.log math.max math.min math.modf math.pi math.rad math.random math.randomseed math.sin math.sqrt math.tan
  -- Added in 5.3
  math.maxinteger math.mininteger math.tointeger math.type math.ult

  -- os library
  os.clock os.date os.difftime os.execute os.exit os.getenv os.remove os.rename os.setlocale os.time os.tmpname

  -- package library
  package.config package.cpath package.loaded package.loadlib package.path package.preload package.searchers package.searchpath

  -- string library
  string.byte string.char string.dump string.find string.format string.gmatch string.gsub string.len string.lower string.match string.pack string.packsize string.rep string.reverse string.sub string.unpack string.upper
  -- Added in 5.3
  string.pack string.packsize string.unpack

  -- table library
  table.concat table.insert table.pack table.remove table.sort table.unpack
  -- Added in 5.3
  table.move

  -- utf8 library
  utf8.char utf8.charpattern utf8.codepoint utf8.codes utf8.len utf8.offset
]])

local lua_deprecated_libraries = token('deprecated_library', word_match[[
  -- Deprecated (in 5.2) debug functions
  debug.getfenv debug.setfenv

  -- Deprecated (in 5.2, except .log10 which was deprecated on 5.3) math functions
  math.atan2 math.cosh math.frexp math.ldexp math.log10 math.pow math.sinh math.tanh

  -- Deprecated (in 5.2) package functions
  package.loaders package.seeall

  -- Deprecated (in 5.2) table function
  table.maxn

  -- bit32 library was deprecated in 5.3
  bit32.arshift bit32.band bit32.bnot bit32.bor bit32.btest bit32.bxor bit32.extract bit32.lrotate bit32.lshift bit32.replace bit32.rrotate bit32.rshift
]])

lex:add_rule('library', lua_libraries + lua_deprecated_libraries)
lex:add_style('library', lexer.STYLE_TYPE)
lex:add_style('deprecated_library', lexer.STYLE_TYPE .. ',italics')

-- Identifiers.
lex:add_rule('identifier', token(lexer.IDENTIFIER, lexer.word))

-- Strings.
local longstring = lpeg.Cmt(
  '[' * lpeg.C(P('=')^0) * '[',
  function(input, index, eq)
    local _, e = input:find(']' .. eq .. ']', index, true)
    return (e or #input) + 1
  end
)

lex:add_rule('string', token(lexer.STRING, lexer.delimited_range("'") + lexer.delimited_range('"')) + token('longstring', longstring))
lex:add_style('longstring', lexer.STYLE_STRING)

-- Comments.
lex:add_rule('comment', token(lexer.COMMENT, '--' * (longstring + lexer.nonnewline^0)))

-- Numbers.
local nelua_suffixes = word_match[[
  -- Number suffixes
  _i _integer _u _uinteger _n _number _b _byte _is _isize
  _i8 _int8 _i16 _int16 _i32 _int32 _i64 _int64 _us _usize
  _u8 _uint8 _u16 _uint16 _u32 _uint32 _u64 _uint64
  _f32 _float32 _f64 _float64

  -- C primitive suffixes
  _cchar _cschar _cshort _cint _clong _clonglong _cptrdiff
  _cuchar _cushort _cuint _culong _culonglong _csize _clongdouble
]]

local integer = P('-')^-1 * (lexer.hex_num + lexer.dec_num)
lex:add_rule('number', token(lexer.NUMBER, (lexer.float + integer) * (nelua_suffixes)^0))

-- Labels
lex:add_rule('label', token(lexer.LABEL, '::' * lexer.word * '::'))

-- Prerocessor
lex:add_rule('preprocessor', token('preprocessor_token', (P('##[[') + '##' + ']]' + '#|' + '|#' + "#[" + "]#")^1))
lex:add_style('preprocessor_token', lexer.STYLE_PREPROCESSOR .. ',bold')

-- Annotations
lex:add_rule('annotation', token(lexer.PREPROCESSOR, lexer.delimited_range("<>", true, false, true)))

-- Operators.
lex:add_rule('operator', token(lexer.OPERATOR, '..' + S('+-*/%^#=<>&|~;,.{}[]()$') + type_op))

-- Fold points.
local function fold_longcomment(text, pos, line, s, symbol)
  if symbol == '[' then
    if line:find("^%[=*%[", s) then return 1 end
  elseif symbol == ']' then
    if line:find("^%]=*%]", s) then return -1 end
  end
  return 0
end

lex:add_fold_point(lexer.KEYWORD, 'if', 'end')
lex:add_fold_point(lexer.KEYWORD, 'do', 'end')
lex:add_fold_point(lexer.KEYWORD, 'switch', 'end')
lex:add_fold_point(lexer.KEYWORD, 'function', 'end')
lex:add_fold_point(lexer.KEYWORD, 'repeat', 'until')
-- TODO: in the future, defer<--->end should be included
lex:add_fold_point(lexer.COMMENT, '[', fold_longcomment)
lex:add_fold_point(lexer.COMMENT, ']', fold_longcomment)
lex:add_fold_point(lexer.COMMENT, '--', lexer.fold_line_comments('--'))
lex:add_fold_point('longstring', '[', ']')
lex:add_fold_point(lexer.OPERATOR, '(', ')')
lex:add_fold_point(lexer.OPERATOR, '[', ']')
lex:add_fold_point(lexer.OPERATOR, '{', '}')

return lex
