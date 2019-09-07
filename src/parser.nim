from strutils import parseFloat
from math import pow

import tokutils
import toktypes

# In order to use these before the actual implementation.
proc expression(ts: TokenStream): float
proc atom(ts: TokenStream): float

proc number(ts: TokenStream): float =
  let unop = ts.expect(@[T_INT, T_MINUS, T_PLUS])

  case unop.kind:
    of T_MINUS: return ts.atom * -1
    of T_PLUS: return ts.atom * 1
    of T_INT: return parseFloat(unop.val)
    else: discard # unreachable

proc atom(ts: TokenStream): float =
  if ts.peek.kind == T_LBR:
    discard ts.chomp
    let inner = ts.expression
    discard ts.expect(T_RBR) # eat the )
    return inner
  else:
    return ts.number
    
proc term(ts: TokenStream): float =
  let lhs = ts.atom

  if ts.peek.kind == T_POW:
    discard ts.chomp
    return lhs.pow(ts.term)
  else:
    return lhs

proc division(ts: TokenStream): float =
    let lhs = ts.term

    if ts.peek.kind == T_DIV:
      discard ts.chomp
      return lhs / ts.division
    else:
      return lhs

proc multiplication(ts: TokenStream): float =
  let lhs = ts.division

  if ts.peek.kind == T_MUL:
    discard ts.chomp
    return lhs * ts.multiplication
  else:
    return lhs

proc expression(ts: TokenStream): float =
  let lhs = ts.multiplication

  case ts.peek.kind:
    of T_PLUS: 
      discard ts.chomp
      return lhs + ts.expression

    of T_MINUS: 
      discard ts.chomp
      return lhs - ts.expression

    else: 
      return lhs
    
proc entry(ts: TokenStream): float =
  if ts.peek.kind == T_EOF: 
    return
  else: 
    return ts.expression

proc parse*(ts: TokenStream): float =
  return entry(ts)