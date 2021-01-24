{

}

Root
  = __ x:(Expression __ )*
  {
      return x;
  }

Expression
  = TermPrec9

Indexing
  = x:common_expression __ "[" __ e:Expression __ "]"
  {
    return { kind: "indexing", variable: x, indexing: e };
  }

TermPrec9
  = left:TermPrec8 c:(__ "||" __ TermPrec8)+
  {
    return { kind: "orOp", c }
  }
  / TermPrec8

TermPrec8
  = left:TermPrec7 c:(__ "&&" __ TermPrec7)+
  {
    return { kind: "andOp", c };
  }
  / TermPrec7

TermPrec7
  = left:TermPrec6 c:(__ ("==" / "!=" ) __ TermPrec6)+
    {
    return { kind: "eqOp", c }
  }
  / TermPrec6

TermPrec6
  = left:TermPrec5 c:(__ ("<" / "<=" / ">" / ">=" ) __ TermPrec5)+
  {
    return { kind: "cmpOp", c }
  }
  / TermPrec5

TermPrec5
  = left:TermPrec4 c:(__ [-+] __ TermPrec4)+
  {
    return { kind: "addOp", c }
  }
  / TermPrec4

TermPrec4
  = left:TermPrec3 c:(__ ("*" / ".*" / "/" / "./" / "%" ) __ TermPrec3)+
  {
    return { kind: "mulOp", c }
  }
  / TermPrec3

TermPrec3
  = left:TermPrec2 __ "\\" __ right:TermPrec2
  {
    return { kind: "ldivOp", name: "\\", left, right }
  }
  / TermPrec2

TermPrec2
  = TermPrec2_p
  / TermPrec1

TermPrec2_p
  = x:[!+-] __ arg:TermPrec1
  {
    return { kind: "unaryOp", name: x, arg }
  }

TermPrec1
  = left:TermPrec0 c:(__ "^" __ (TermPrec0 / TermPrec2_p))+
  {
    return { kind: "expOp", name: "^", left, c }
  }
  / TermPrec0


TermPrec0
  = Indexing
  / PostfixOp
  / common_expression

PostfixOp
  = x:( Indexing / common_expression ) __ "'"
  {
    return { kind: "postfixOp", name: "'", arg: x };
  }

common_expression
  = $real_literal
  / Variable

Variable
  = x:$identifier
  {
    return { kind: "variable", name: x };
  }

identifier
  = [a-zA-Z] [a-zA-Z0-9_]*

real_literal
  = integer_literal '.' [0-9]* exp_literal?
  / '.' [0-9]+ exp_literal?
  / integer_literal exp_literal?

exp_literal = ('e' / 'E') ('+' / '-')? integer_literal

integer_literal = [0-9]+
__
  = [ \t\r\n]*
  {
    return
  }

