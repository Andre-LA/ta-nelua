-- Copyright 2020-2022 André Luiz Alvares. See License.txt
-- Nelua LPeg lexer.

local lexer = require('lexer')

local token, word_match = lexer.token, lexer.word_match
local P, R, S = lpeg.P, lpeg.R, lpeg.S

local lex = lexer.new('nelua')

-- Whitespace
local ws0 = lexer.space^0
local ws1 = lexer.space^1

-- Keywords --

local keywords = token(lexer.KEYWORD, word_match{
  -- lua keywords: https://www.lua.org/manual/5.4/manual.html#3.1
  'and', 'break', 'do', 'else', 'elseif', 'end',
  'false', 'for', 'function', 'goto', 'if', 'in',
  'local', 'nil', 'not', 'or', 'repeat', 'return',
  'then', 'true', 'until', 'while',

  -- nelua keywords: https://github.com/edubart/nelua-lang/blob/af61898a8d90dc9736ab8f2e21e24a09a19b138d/docs/_includes/prismlangs.js#L61
  'switch', 'case', 'continue', 'fallthrough', 'global', 'defer',
})

-- Constants

-- Nelua libraries, from libraries page: https://nelua.io/libraries/
local libraries = token(lexer.CLASS, word_match{
  'io', 'filestream', 'math', 'memory', 'os', 'string', 'stringbuilder',
  'traits', 'utf8', 'coroutine', 'hash', 'vector', 'sequence', 'list', 'hashmap'
  -- TODO: add allocators
})

-- Strings.
local longstring = lpeg.Cmt(
  '[' * lpeg.C(P('=')^0) * '[',
  function(input, index, eq)
    local _, e = input:find(']' .. eq .. ']', index, true)
    return (e or #input) + 1
  end
)

local string_patt = lexer.range("'") + lexer.range('"')
local string_tk = token(lexer.STRING, string_patt + token('longstring', longstring))

-- Numbers.
local nelua_suffixes = word_match{
  '_i', '_integer',
  '_u', '_uinteger',
  '_n', '_number',
  '_b', '_byte',
  '_is', '_isize',
  '_i8', '_int8',
  '_i16', '_int16',
  '_i32', '_int32',
  '_i64', '_int64',
  '_i128', '_int128',
  '_us', '_usize',
  '_u8', '_uint8',
  '_u16', '_uint16',
  '_u32', '_uint32',
  '_u64', '_uint64',
  '_u128', '_uint128',
  '_f32', '_float32',
  '_f64', '_float64',
  '_f128', '_float128',

  -- C primitive suffixes
  '_cshort',
  '_cint',
  '_clong',
  '_clonglong',
  '_cptrdiff',
  '_cchar',
  '_cschar',
  '_cuchar',
  '_cushort',
  '_cuint',
  '_culong',
  '_culonglong',
  '_csize',
  '_clongdouble',
  '_cstring',
}

local integer = P('-')^-1 * (lexer.hex_num + lexer.dec_num)

-- preprocessor
local preprocessor_line = token('preprocessor_token', P'##')
local preprocessor_start = token('preprocessor_token', P'#|' + '#[' + (P'##[' * P'='^0 * '['))
local preprocessor_end  = token('preprocessor_token', P'|#' + "]#" +   (P']' * P'='^0 * ']'))
local pp_repl_macro_syntax_sugar  = token('preprocessor_token', P'!' * #(P'('))

-- functions
local balanced_parens = token(lexer.OPERATOR, lexer.range('(', ')', false, false, true))
local balanced_braces = token(lexer.OPERATOR, lexer.range('{', '}', false, false, true))
local balanced_pp_expr_repl = token(lexer.PREPROCESSOR, lexer.range('#[', ']#', false, false, true))

local function_call = (P'!'^-1 * balanced_parens) + string_tk + balanced_braces + balanced_pp_expr_repl
local function_tk = token(lexer.FUNCTION, lexer.word) * #(ws0 * function_call)

-- rules

lex:add_rule('whitespace', token(lexer.WHITESPACE, ws1))
lex:add_rule('keyword', keywords)

-- TODO: this one doesn't works on something like `foo: #|'Bar'|#.Baz`
local type_tk = (token(lexer.IDENTIFIER, lexer.word) * '.')^0 * token(lexer.TYPE, lexer.word)

lex:add_rule('type',
  token(lexer.OPERATOR, P'@') * ws0 * type_tk
  +
  (
    token(lexer.OPERATOR, P':')
    *
    (
      ws1 * type_tk
      +
      ( type_tk * #(P' '^0) * #( (lexer.newline + '=') + (function_call * (ws0 * '=')) ) )
    )
  )
)

lex:add_rule('function', function_tk)

lex:add_rule('library', libraries)
lex:add_style('library', lexer.STYLE_TYPE)

lex:add_rule('constant', token(lexer.CONSTANT, P'_VERSION'))

lex:add_rule('identifier', token(lexer.VARIABLE, P'self') + token(lexer.IDENTIFIER, lexer.word))

lex:add_rule('string', string_tk)
lex:add_style('longstring', lexer.STYLE_STRING)

lex:add_rule('comment', token(lexer.COMMENT, '--' * (longstring + lexer.nonnewline^0)))
lex:add_rule('number', token(lexer.NUMBER, (lexer.float + integer) * (nelua_suffixes)^0))
lex:add_rule('label', token(lexer.LABEL, '::' * lexer.word * '::'))

lex:add_rule('preprocessor', preprocessor_line + preprocessor_start + preprocessor_end + pp_repl_macro_syntax_sugar)

lex:add_rule('annotation', token(lexer.PREPROCESSOR, P'<' * -lexer.space * (lexer.nonnewline - P' >' - P'>')^1 * '>'))

lex:add_style('annotation', lexer.styles.class)
lex:add_rule('operator', token(lexer.OPERATOR, '..' + S('+-*/%^#=<>&|~;,.:{}[]()$')))
lex:add_style('preprocessor_token', lexer.STYLE_PREPROCESSOR .. {bold = true})

lex:add_rule('error', token(lexer.ERROR, lexer.any))

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
lex:add_fold_point(lexer.KEYWORD, 'defer', 'end')
lex:add_fold_point(lexer.KEYWORD, 'function', 'end')
lex:add_fold_point(lexer.KEYWORD, 'repeat', 'until')
lex:add_fold_point(lexer.COMMENT, '[', fold_longcomment)
lex:add_fold_point(lexer.COMMENT, ']', fold_longcomment)
lex:add_fold_point(lexer.COMMENT, '--', lexer.fold_line_comments('--'))

lex:add_fold_point('longstring', '[', ']')
lex:add_fold_point(lexer.OPERATOR, '(', ')')
lex:add_fold_point(lexer.OPERATOR, '[', ']')
lex:add_fold_point(lexer.OPERATOR, '{', '}')

-- embed lua
local lua = lexer.load('lua')
lex:embed(lua, preprocessor_line, lexer.newline)
lex:embed(lua, preprocessor_start, preprocessor_end)

return lex
