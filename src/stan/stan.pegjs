{
    function leftAssociate(kind, leftTerm, rightTermArrayArg) {
        const termArray = rightTermArrayArg.flat().filter(e => e);
        if (termArray.length <= 2) {
            const right = termArray[1];
            const name = termArray[0];
            const left = leftTerm;
            return { kind, name, left, right, location: { start: left.start, end: right.end } };
        } else {
            const right = termArray[termArray.length - 1];
            const name = termArray[termArray.length - 2];
            const rest = termArray.slice(0, termArray.length - 2);
            const left = leftAssociate(kind, leftTerm, rest);
            return { kind, name, left, right, location: { start: left.start, end: right.end } };
        }
    }
}

Root
  = __ x:(Expression)*
  {
    return x;
  }

Statement
  = atomic_statement
  / nested_statement

atomic_statement
  = lhs __ assignment_op __ Expression __ ";"
  / Expression __ "~" __ identifier __ "(" expressions ")" __ truncation? __ ";"
  / "increment_log_prob" __ "(" __ Expression __ ")" __ ";"
  / function_literal __ "(" __ expressions __ ")" __ ";"
  / "target" __ "+=" __ Expression __ ";"
  / "break" __ ";"
  / "continue" __ ";"
  / "print" __ "(" ")" __ ";"
  / "reject" __ "(" ")" __ ";"
  / "return" __ Expression __ ";"

assignment_op
  = "<-" / "=" / "+=" / "-=" / "*=" / "/=" / ".*=" / "./="

lhs = identifier __ ("[" __ indexes __ "]")*

truncation
  = "T" __ "[" __ Expression? __ "," __ Expression? __ "]"

expressions
  = (Expression (__ "," __ Expression)*)?

nested_statement
  = "if" __ "(" __ Expression __ ")" __ Statement
    ( __ "else" __ "if" __ "(" __ Expression __ ")" __ Statement )*
    ( __ "else" __ Statement )?
  / "while" __ "(" __ Expression __ ")" __ Statement
  / "for" __ "(" __ identifier __ "in" __ Expression __ ":" __ Expression __ ")" __ Statement
  / "for" __ "(" __ identifier __ "in" __ Expression __ ")" __ Statement
//  / "{" __ var_decl* __ (Statement __)+ __ "}"

Expression
  = TermPrec9

constr_expression
  = TermPrec5

Indexing
  = x:common_expression __ "[" __ inds:indexes __ "]"
  {
    return { kind: "indexing", exp: x, indexes: inds, location: location() };
  }

indexes
  = index __ ("," index)*

index
  = Expression __ ":" __ Expression
  / Expression __ ":"
  / Expression
  / ":" __ Expression
  / ":"

TermPrec9
  = left:TermPrec8 c:(__ "||" __ TermPrec8)+
  {
    return leftAssociate("orOp", left, c);
  }
  / TermPrec8

TermPrec8
  = left:TermPrec7 c:(__ "&&" __ TermPrec7)+
  {
    return leftAssociate("andOp", left, c);
  }
  / TermPrec7

TermPrec7
  = left:TermPrec6 c:(__ ("==" / "!=" ) __ TermPrec6)+
    {
    return leftAssociate("eqOp", left, c);
  }
  / TermPrec6

TermPrec6
  = left:TermPrec5 c:(__ ("<" / "<=" / ">" / ">=" ) __ TermPrec5)+
  {
    return leftAssociate("cmpOp", left, c);
  }
  / TermPrec5

TermPrec5
  = left:TermPrec4 c:(__ [-+] __ TermPrec4)+
  {
    return leftAssociate("addOp", left, c);
  }
  / TermPrec4

TermPrec4
  = left:TermPrec3 c:(__ ("*" / ".*" / "/" / "./" / "%" ) __ TermPrec3)+
  {
    return leftAssociate("mulOp", left, c);
  }
  / TermPrec3

TermPrec3
  = left:TermPrec2 __ c:("\\" __ right:TermPrec2)+
  {
    return leftAssociate("ldivOp", left, c);
  }
  / TermPrec2

TermPrec2
  = TermPrec2_p
  / TermPrec1

TermPrec2_p
  = x:[!+-] __ arg:TermPrec1
  {
    return { kind: "unaryOp", name: x, arg, location: location() }
  }

TermPrec1
  = left:TermPrec0 c:(__ "^" __ (TermPrec0 / TermPrec2_p))+
  {
    return leftAssociate("expOp", left, c);
  }
  / TermPrec0

TermPrec0
  = Indexing
  / PostfixOp
  / common_expression

PostfixOp
  = x:( Indexing / common_expression ) __ "'"
  {
    return { kind: "postfixOp", name: "'", arg: x, location: location() };
  }

common_expression
  = x:$real_literal
  {
    return { kind: "realLiteral", value: x, location: location() };
  }
  / Variable

var_type
  = "int" __ range_constraint?
  / "real" __ constraint
  / "vector" __ constraint __ "[" __ Expression __ "]"

constraint
  = range_constraint
  / "<" __ offset_multiplier __ ">"

range_constraint
  = "<" __ range __ ">"

range
  = "lower" __ "=" __ constr_expression __ "," __ "upper" __ "=" __ constr_expression
  / "lower" __ "=" __ constr_expression
  / "upper" __ "=" __ constr_expression

offset_multiplier
  = "offset" __ "=" __ constr_expression __ "," __ "multiplier" __ "=" __ constr_expression
  / "offset" __ "=" __ constr_expression
  / "multiplier" "=" __ constr_expression

Variable
  = x:$identifier
  {
    return { kind: "variable", name: x, location: location() };
  }

function_literal
  = identifier

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

