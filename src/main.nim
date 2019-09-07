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

    # NOTE: there is only one possibility of `tokens`s length being one:
    # if it ends with an EOF. Otherwise it will be two or more tokens.
    if len(tokens.tokens) > 1:
      echo "~> " & $result

  except LexicalError as e:
    echo spaces(e.pos + prompt.len - 1) & "\e[31m\e[1m^\e[0m"
    error(e.msg)
  except ParsingError as e:
    # NOTE: .pos is the last valid pos, so to make it be a position of the error
    # we add 1. Thus, `- 1` in `e.pos + prompt.len - 1` is cancelled.
    echo spaces(e.pos + prompt.len) & "\e[31m\e[1m^\e[0m" 
    error(e.msg)
  except IOError:
    echo "Bye!"
    quit(0)