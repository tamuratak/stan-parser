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
    return { kind: "binaryOp9", c }
  }
  / TermPrec8

TermPrec8
  = left:TermPrec7 c:(__ "&&" __ TermPrec7)+
  {
    return { kind: "binaryOp8", c };
  }
  / TermPrec7

TermPrec7
  = left:TermPrec6 c:(__ ("==" / "!=" ) __ TermPrec6)+
    {
    return { kind: "binaryOp7", c }
  }
  / TermPrec6

TermPrec6
  = left:TermPrec5 c:(__ ("<" / "<=" / ">" / ">=" ) __ TermPrec5)+
  {
    return { kind: "binaryOp6", c }
  }
  / TermPrec5

TermPrec5
  = left:TermPrec4 c:(__ [-+] __ TermPrec4)+
  {
    return { kind: "binaryOp5", c }
  }
  / TermPrec4

TermPrec4
  = left:TermPrec3 c:(__ ("*" / ".*" / "/" / "./" / "%" ) __ TermPrec3)+
  {
    return { kind: "binaryOp4", c }
  }
  / TermPrec3

TermPrec3
  = left:TermPrec2 __ "\\" __ right:TermPrec2
  {
    return { kind: "binaryOp3", name: "\\", left, right }
  }
  / TermPrec2

TermPrec2
  = x:[!+-] __ arg:TermPrec1
  {
    return { kind: "unaryOp", name: x, arg }
  }
  / TermPrec1

TermPrec1
  = left:TermPrec0 c:(__ "^" __ TermPrec0)+
  {
    return { kind: "binaryOp1", name: "^", left, c }
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
  = Variable

Variable
  = x:$identifier
  {
    return { kind: "variable", name: x };
  }

identifier
  = [a-zA-Z] [a-zA-Z0-9_]*
  
__
  = [ \t\r\n]*
  {
    return
  }

