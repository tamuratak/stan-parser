{

}

Root
  = __ x:(Expression __ )*
  {
      return x;
  }

Expression
  = Indexing
///  / BinaryOp
  / Term9

Indexing
  = x:common_expression __ "[" __ e:Expression __ "]"
  {
    return { kind: "indexing", variable: x, indexing: e };
  }

Term9
  = left:Term8 c:(__ "||" __ Term8)+
  {
    return { c }
  }
  / Term8

Term8
  = left:Term7 c:(__ "&&" __ Term7)+
  {
    return { c };
  }
  / Term7

Term7
  = left:Term6 c:(__ ("==" / "!=" ) __ Term6)+
  / Term6

Term6
  = left:Term5 c:(__ ("<" / "<=" / ">" / ">=" ) __ Term5)+
  {
    return { kind: "addOp", c }
  }
  / Term5

Term5
  = left:Term4 c:(__ [-+] __ Term4)+
  {
    return { kind: "addOp", c }
  }
  / Term4

Term4
  = left:Term3 c:(__ ("*" / ".*" / "/" / "./" / "%" ) __ Term3)+
  {
    return { kind: "multiOp", c }
  }
  / Term3

Term3
  = left:Term2 __ "\\" __ right:Term2
  {
    return { kind: "leftDivOp", name: "\\", left, right }
  }
  / Term2

Term2
  = x:[!+-] __ arg:Term1
  {
    return { kind: "unaryOp", name: x, arg }
  }
  / Term1

Term1
  = left:Term0 __ "^" __ c:Term0
  {
    return { kind: "expOp", name: "^", left, c }
  }
  / Term0

Term0
  = Indexing
  / PostfixOp
  / Term
  / Variable

PostfixOp
  = x:( Indexing / common_expression ) __ "'"
  {
    return { kind: "postfixOp", name: "'", arg: x };
  }

Term
  = common_expression


common_expression
  = Variable

Variable
  = x:$identifier
  {
    return { kind: "variable", name: x };
  }

identifier
  = [a-zA-Z] [a-zA-Z0-9_]*
  
__ = [ \t\r\n]*
