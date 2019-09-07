import errors
import toktypes

from strformat import fmt
from strutils import join

type
  Token* = object of RootObj
    kind*: TokenType
    val*: string
    pos*: int

  TokenStream* = ref object of RootObj
    pos*: int
    tokens*: seq[Token]

proc previous*(ts: TokenStream): Token =
  if ts.pos > 0:
    return ts.tokens[ts.pos - 1]

proc peek*(ts: TokenStream): Token = 
  return ts.tokens[ts.pos]

proc chomp*(ts: TokenStream): Token =
  if ts.peek.kind == T_EOF: 
    return ts.peek
  else:
    ts.pos += 1
    return ts.previous

proc expect*(ts: TokenStream, expecting: TokenType): Token =
  if ts.peek.kind == expecting:
    return ts.chomp
  else:

    newParsingError(
      fmt"parsing error: expected {expecting}, yet found {ts.peek.kind}",
      ts.previous.kind,
      ts.previous.val,
      ts.previous.pos
    )

proc expect*(ts: TokenStream, expecting: seq[TokenType]): Token =
  if ts.peek.kind in expecting:
    return ts.chomp
  else:
    let valids = join(expecting, " or ")
    newParsingError(
      fmt"parsing error: expected {valids}, yet found {ts.peek.kind}",
      ts.previous.kind,
      ts.previous.val,
      ts.previous.pos
    )

proc newTokenStream*(tokens: seq[Token]): TokenStream =
  new(result)
  result.pos = 0
  result.tokens = tokens