import streams
import tokutils
import toktypes

from errors import newLexicalError, newParsingError
from strutils import Digits, Whitespace
from strformat import fmt

proc lex*(input: string): TokenStream =
  let chars = newStringStream(input)
  var tokens: seq[Token]
  var braceLevel: seq[int]

  while not chars.atEnd:
    case chars.peekChar:
      of Digits:
        var buffer: string
        var token: Token

        token.pos = chars.getPosition

        while chars.peekChar in Digits: 
          buffer = buffer & $chars.readChar
       
        token.kind = T_INT
        token.val = buffer
        tokens.add(token)
        
      of '+', '-', '*', '/', '^':
        var token: Token

        token.val = $chars.peekChar
        token.pos = chars.getPosition

        case chars.readChar:
          of '+': token.kind = T_PLUS
          of '-': token.kind = T_MINUS
          of '*': token.kind = T_MUL
          of '/': token.kind = T_DIV
          of '^': token.kind = T_POW
          else: discard # unreachable

        tokens.add(token)

      of '(': 
        let token = Token(kind: T_LBR, val: $chars.readChar, pos: chars.getPosition)
        braceLevel.add(chars.getPosition)
        tokens.add(token)

      of ')': 
        let token = Token(kind: T_RBR, val: $chars.readChar, pos: chars.getPosition) 
        
        if braceLevel.len > 0:
          discard braceLevel.pop
          tokens.add(token)
        else:
          newLexicalError(
            fmt"maybe you forgot to open the brace from char {chars.getPosition}?",
            chars.getPosition
          )

      of Whitespace: 
        discard chars.readChar
      
      else:
        newLexicalError(
          fmt"lexical error caused by '{chars.readChar}' at char {chars.getPosition}",
          chars.getPosition
        )
    
  if braceLevel.len > 0:
    let lastBrace: int = braceLevel[braceLevel.len - 1]
    newLexicalError(
      fmt"maybe you forgot to close the brace from char {lastBrace}?",
      lastBrace
    )
    
  # Append the EOF token.
  var eof: Token
  eof.kind = T_EOF
  tokens.add(eof)

  return newTokenStream(tokens)