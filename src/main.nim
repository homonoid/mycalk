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
    let spaces = " ".repeat (e.pos + prompt.len - 1)
    echo spaces & "\e[31m\e[1m^\e[0m"
    error(e.msg)
  except ParsingError as e:
    # Nice error formatting:
    error(e.msg & ". Last valid token was '" & e.lastValidValue & "'")
  except IOError:
    echo "Bye!"
    quit(0)