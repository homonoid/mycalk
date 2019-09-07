import toktypes

type
  ParsingError* = ref object of CatchableError
    lastValidKind*: TokenType
    lastValidVal*: string
    pos*: int

  LexicalError* = ref object of CatchableError
    pos*: int

proc error*(msg: string): void =
  write(stderr, "\e[31m\e[1merror:\e[0m " & msg & '\n')

proc newLexicalError*(msg: string, pos: int = 0): void =
  raise LexicalError(msg: msg, pos: pos)

proc newParsingError*(msg: string, lval: TokenType, lvalval: string = "", pos: int = 0): void =
  raise ParsingError(msg: msg, lastValidKind: lval, lastValidVal: lvalval, pos: pos)