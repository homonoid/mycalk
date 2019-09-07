import toktypes

type
  ParsingError* = ref object of CatchableError
    lastValid*: TokenType
    lastValidValue*: string

  LexicalError* = ref object of CatchableError
    pos*: int

proc error*(msg: string): void =
  write(stderr, "\e[31m\e[1merror:\e[0m " & msg & '\n')

proc newLexicalError*(msg: string, pos: int = 0): void =
  raise LexicalError(msg: msg, pos: pos)

proc newParsingError*(msg: string, lval: TokenType, lvalval: string = ""): void =
  raise ParsingError(msg: msg, lastValid: lval, lastValidValue: lvalval)