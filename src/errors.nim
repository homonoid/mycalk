import toktypes

type
  ParsingError* = ref object of CatchableError
    lastValid*: TokenType
    lastValidValue*: string

  LexicalError* = ref object of CatchableError
    pos*: int

proc error*(msg: string): void =
  write(stderr, "\e[31m\e[1merror:\e[0m " & msg & '\n')