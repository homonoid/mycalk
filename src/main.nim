import rdstdin
import lexer
import parser
import errors
import strutils

const prompt = "expr> "

echo "\n  Welcome to Mycalk!\n"

while true:
  try:
    let line = readLineFromStdin(prompt)
    let tokens = lex(line)
    let result = parse(tokens)

    # NOTE: length of tokens.tokens is 1 only if there is just an EOF token.
    if len(tokens.tokens) > 1:
      echo "~> " & $result

  except LexicalError as e:
    echo spaces(e.pos + prompt.len - 1) & "\e[31m\e[1m^\e[0m"
    error(e.msg)
  except ParsingError as e:
    # NOTE: .pos is the last valid token's pos, so to make it the position of
    # the token that caused the error we shall add 1. Hence `- 1` is cancelled.
    echo spaces(e.pos + prompt.len) & "\e[31m\e[1m^\e[0m" 
    error(e.msg)
  except IOError:
    echo "Bye!"
    quit(0)