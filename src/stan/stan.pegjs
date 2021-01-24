{

}

Root
  = x:(Expression __ )*
  {
      return x;
  }

Expression
  = x:(Variable / PostfixOp)
  {
    return x;
  }

constr_expression
  = common_expression
 
common_expression
  = Variable

BinaryOp
  = left:Expression "^" right:Expression
  {
    return { kind: 'binaryOp', name: '^', left, right }
  }
  / left:Expression "\\" right:Expression
  {
    return { kind: 'binaryOp', name: '\\', left, right }
  }

PostfixOp
  = x:common_expression __ "'"
  {
    return { kind: 'postfixOp', name: "'", arg: x };
  }

Variable
  = x:$identifier
  {
    return { kind: "variable", name:x };
  }

identifier
  = [a-zA-Z] [a-zA-Z0-9_]*
  
__ = [ \t\r\n]*
