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
local libraries = token('library', word_match{
  -- io
  'io.stderr', 'io.stdout', 'io.stdin', 'io.open', 'io.popen', 'io.close', 'io.flush', 'io.input', 'io.output',
  'io.tmpfile', 'io.read', 'io.write', 'io.writef', 'io.printf', 'io.type', 'io.lines',

  -- filestream
  'filestream._fromfp', 'filestream._getfp', 'filestream.open', 'filestream.flush', 'filestream.close', 'filestream.destroy',
  'filestream.__close', 'filestream.seek', 'filestream.setvbuf', 'filestream.read', 'filestream.write', 'filestream.writef',
  'filestream.lines', 'filestream.isopen', 'filestream.__tostring',

  -- math
  'math.abs', 'math.floor', 'math.ifloor', 'math.ceil', 'math.iceil', 'math.round', 'math.trunc', 'math.sqrt', 'math.cbrt',
  'math.exp', 'math.exp2', 'math.pow', 'math.log', 'math.cos', 'math.sin', 'math.tan', 'math.acos', 'math.asin', 'math.atan',
  'math.atan2', 'math.cosh', 'math.sinh', 'math.tanh', 'math.log10', 'math.log2', 'math.acosh', 'math.asinh', 'math.atanh',
  'math.deg', 'math.rad', 'math.sign', 'math.fract', 'math.mod', 'math.modf', 'math.fmod', 'math.frexp', 'math.ldexp', 'math.min',
  'math.max', 'math.clamp', 'math.ult', 'math.tointeger', 'math.type', 'math.randomseed', 'math.random', 'math.pi', 'math.huge',
  'math.mininteger', 'math.maxinteger', 'math.maxuinteger',

  -- memory
  'memory.copy', 'memory.move', 'memory.set', 'memory.zero', 'memory.compare', 'memory.equals', 'memory.scan', 'memory.find',
  'memory.spancopy', 'memory.spanmove', 'memory.spanset', 'memory.spanzero', 'memory.spancompare', 'memory.spanequals', 'memory.spanfind',

  -- os
  'os.clock', 'os.date', 'os.difftime', 'os.execute', 'os.exit', 'os.setenv', 'os.getenv', 'os.remove', 'os.rename',
  'os.setlocale', 'os.timedesc', 'os.time', 'os.tmpname', 'os.now', 'os.sleep',

  -- string
  'string.create', 'string.destroy', 'string.copy', 'string.byte', 'string.sub', 'string.subview', 'string.rep',
  'string.reverse', 'string.upper', 'string.lower', 'string.char', 'string.format', 'string.len', 'string.fillcstring',
  'string.span', 'string.__close', 'string.__atindex', 'string.__len', 'string.__concat', 'string.__eq', 'string.__lt',
  'string.__le', 'string.__add', 'string.__sub', 'string.__mul', 'string.__div', 'string.__idiv', 'string.__tdiv', 'string.__mod',
  'string.__tmod', 'string.__pow', 'string.__unm', 'string.__band', 'string.__bor', 'string.__bxor', 'string.__shl', 'string.__shr',
  'string.__asr', 'string.__bnot', 'string.find', 'string.gmatch', 'string.gmatchview', 'string.gsub', 'string.match',
  'string.matchview', 'string.pack', 'string.unpack', 'string.packsize',

  -- stringbuilder
  'stringbuilder.make', 'stringbuilder.destroy', 'stringbuilder.__close', 'stringbuilder.clear', 'stringbuilder.prepare',
  'stringbuilder.commit', 'stringbuilder.rollback', 'stringbuilder.resize', 'stringbuilder.writebyte', 'stringbuilder.write',
  'stringbuilder.writef', 'stringbuilder.view', 'stringbuilder.promote', 'stringbuilder.__len', 'stringbuilder.__tostring',

  -- traits
  'traits.typeid', 'traits.typeinfo', 'traits.typeidof', 'traits.typeinfoof',

  -- utf8
  'utf8.charpattern', 'utf8.char', 'utf8.codes', 'utf8.codepoint', 'utf8.offset', 'utf8.len',

  -- coroutine
  'coroutine.destroy', 'coroutine.__close', 'coroutine.create', 'coroutine.push', 'coroutine.pop', 'coroutine.isyieldable',
  'coroutine.resume', 'coroutine.spawn', 'coroutine.yield', 'coroutine.running', 'coroutine.status',

  -- hash
  'hash.short', 'hash.long', 'hash.combine', 'hash.hash',

  -- vector
  'vectorT.make', 'vectorT.clear', 'vectorT.destroy', 'vectorT.__close', 'vectorT.reserve', 'vectorT.resize', 'vectorT.copy',
  'vectorT.push', 'vectorT.pop', 'vectorT.insert', 'vectorT.remove', 'vectorT.removevalue', 'vectorT.removeif', 'vectorT.capacity',
  'vectorT.__atindex', 'vectorT.__len', 'vectorT.__convert',

  -- sequence
  'sequence._init', 'sequence.make', 'sequence.clear', 'sequence.destroy', 'sequence.__close', 'sequence.reserve', 'sequence.resize',
  'sequence.copy', 'sequence.push', 'sequence.pop', 'sequence.insert', 'sequence.remove', 'sequence.removevalue', 'sequence.removeif',
  'sequence.capacity', 'sequence.__atindex', 'sequence.__len', 'sequence.__convert', 'sequence.unpack',

  -- list
  'list.make', 'list.clear', 'list.destroy', 'list.__close', 'list.pushfront', 'list.pushback', 'list.insert', 'list.popfront',
  'list.popback', 'list.find', 'list.erase', 'list.empty', 'list.__len', 'list.__next', 'list.__mnext', 'list.__pairs', 'list.__mpairs',
  'list.__convert',

  -- hashmap
  'hashmap.make', 'hashmap.destroy', 'hashmap.__close', 'hashmap.clear', 'hashmap._find', 'hashmap.rehash', 'hashmap.reserve',
  'hashmap._at', 'hashmap.__atindex', 'hashmap.peek', 'hashmap.remove', 'hashmap.loadfactor', 'hashmap.bucketcount', 'hashmap.capacity',
  'hashmap.__len', 'hashmap.__pairs', 'hashmap.__mpairs', 'hashmap._next_node', 'hashmap.__next', 'hashmap.__mnext',

  -- TODO: Allocators
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
local balanced_parens = lexer.range('(', ')', false, false, true)
local balanced_braces = lexer.range('{', '}', false, false, true)

local function_call = (P'!'^-1 * balanced_parens) + string_tk + balanced_braces
local function_tk = token(lexer.FUNCTION, lexer.word) * #(ws0 * function_call)

-- rules

lex:add_rule('whitespace', token(lexer.WHITESPACE, ws1))
lex:add_rule('keyword', keywords)

lex:add_rule('type',
  token(lexer.OPERATOR, P'@') * ws0 * token(lexer.TYPE, lexer.word)
  +
  (
    token(lexer.OPERATOR, P':')
    *
    (
      ws1 * token(lexer.TYPE, lexer.word)
      +
      (
        token(lexer.TYPE, lexer.word) * #(P' '^0)
        *
        #( (lexer.newline + '=') + (function_call * (ws0 * '=')) )
      )
    )
  )
)

lex:add_rule('function', function_tk)

lex:add_rule('library', libraries)
lex:add_style('library', lexer.STYLE_TYPE)

lex:add_rule('constant', token(lexer.CONSTANT, P'_VERSION'))


lex:add_rule('identifier', token(lexer.IDENTIFIER, lexer.word))

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
lex:embed(lua, preprocessor_start, preprocessor_end)
lex:embed(lua, preprocessor_line, lexer.newline)

return lex
