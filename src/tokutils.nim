import strformat
import strutils
import errors
import toktypes

type
  Token* = tuple
    kind: TokenType
    val: string

  TokenStream* = ref object of RootObj
    pos*: int
    tokens*: seq[Token]
    expression: proc (ts: TokenStream): float

proc previous*(ts: TokenStream): Token =
  if ts.pos > 0:
    return ts.tokens[ts.pos - 1]

proc peek*(ts: TokenStream): Token = 
  return ts.tokens[ts.pos]

proc chomp*(ts: TokenStream): Token =
  if ts.peek.kind == T_EOF: 
    return ts.peek
  else:
    let temp = ts.peek
    ts.pos += 1
    return temp

proc expect*(ts: TokenStream, expecting: TokenType): Token =
  if ts.peek.kind == expecting:
    return ts.chomp
  else:
    raise ParsingError(
      msg: fmt"parsing error: expected {expecting}, found {ts.peek.kind}",
      lastValid: ts.previous.kind,
      lastValidValue: ts.previous.val
    )

proc expect*(ts: TokenStream, expecting: seq[TokenType]): Token =
  if ts.peek.kind in expecting:
    return ts.chomp
  else:
    let valids = join(expecting, " or ")
    raise ParsingError(
      msg: fmt"parsing error: expected {valids}, found {ts.peek.kind}",
      lastValid: ts.previous.kind,
      lastValidValue: ts.previous.val
    )

proc newTokenStream*(tokens: seq[Token]): TokenStream =
  new(result)
  result.pos = 0
  result.tokens = tokens