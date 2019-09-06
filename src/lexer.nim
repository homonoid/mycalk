import streams
import tokutils
import strformat
import sequtils
import errors
import toktypes

proc lex*(input: string): TokenStream =
  let chars = newStringStream(input)
  var tokens: seq[Token]
  var braceLevel: seq[int]

  while not chars.atEnd():
    case chars.peekChar:
      of '0'..'9':
        var buffer: string
        var token: Token

        while chars.peekChar in '0'..'9': 
          buffer = buffer & $chars.readChar()
       
        token.kind = T_INT
        token.val = buffer
        tokens.add(token)
        
      of '+', '-', '*', '/', '(', ')':
        var token: Token

        token.val = chars.peekStr(1)

        case chars.readChar:
          of '+': token.kind = TokenType.T_PLUS
          of '-': token.kind = TokenType.T_MINUS
          of '*': token.kind = TokenType.T_MUL
          of '/': token.kind = TokenType.T_DIV

          of '(': 
            braceLevel.add chars.getPosition
            token.kind = TokenType.T_LBR

          of ')': 
            if braceLevel.len > 0:
              discard braceLevel.pop
            else:
              # TODO: make this a function because it is used often!
              raise LexicalError(
                msg: fmt"lexical error caused by ')' at char {chars.getPosition}",
                pos: chars.getPosition
              )
            token.kind = TokenType.T_RBR

          else: discard # (unreachable)

        tokens.add(token)

      of ' ', '\n', '\t', '\r': 
        discard chars.readChar
      
      else:
        raise LexicalError(
          msg: fmt"lexical error caused by '{chars.readChar}' at char {chars.getPosition}",
          pos: chars.getPosition
        )
    
  if braceLevel.len > 0:
    let lastBrace: int = braceLevel[braceLevel.len - 1]

    raise LexicalError(
      msg: fmt"maybe you forgot to close braces? The last one was at char {lastBrace}",
      pos: lastBrace
    )
  # Append the EOF token.
  var eof: Token
  eof.kind = T_EOF
  tokens.add(eof)

  return newTokenStream(tokens)