# 2. Grammar

The grammar below is written in EBNF (`{x}` = zero or more, `[x]` = optional, `x | y` =
choice). It corresponds one-to-one with the reference implementation's AST: every
production names a node kind in `src/ast.rs`. Where the grammar and the parser disagree,
the conformance suite decides which is wrong.

## 2.1 Program and items

```
Program      = { Item } EOF ;
Item         = Decorator* ( FnDecl | StructDecl | EnumDecl | ImplDecl
                          | TraitDecl | ConstDecl | TypeAlias | ImportDecl ) ;
Decorator    = "@" Ident "(" ArgumentList ")" ;
```

Eight item kinds exist: `Fn`, `Struct`, `Enum`, `Impl`, `Trait`, `Const`, `TypeAlias`,
`Import`. Decorators attach to the item that follows them; `@legal(...)` and
`@agent_task(...)` are checked by dedicated passes (§4.9), and an unknown decorator is a
compile error rather than an annotation that is silently ignored.

```
FnDecl       = [ "native" ] "fn" Ident "(" [ Param { "," Param } ] ")" [ "->" Type ]
               ( Block | /* native: no body */ ) ;
Param        = Ident ":" Type | "self" [ "," ] ;
StructDecl   = "struct" Ident "{" { Ident ":" Type "," } "}" ;
EnumDecl     = "enum" Ident "{" Ident { "," Ident } "}" ;
ImplDecl     = "impl" Type "{" { FnDecl } "}" ;
TraitDecl    = "trait" Ident "{" { FnDecl } "}" ;
ConstDecl    = "const" Ident ":" Type "=" Expr ;
TypeAlias    = "type" Ident "=" Type ;
ImportDecl   = "import" String ;
```

A `native fn` declaration has no body: its implementation is a symbol of the same name
supplied at link time (`native fn tallow_string_free(s: String)`), so calls bind to that
symbol with no name mangling. The modifier is only a modifier when followed by `fn`, so a
function named `native` still parses. The interpreter has nothing to execute for such a
call and refuses it by name; compile the program instead.

Enums are integer-backed: a variant is a named discriminant, and a `match` on an enum
compares against integer patterns (this is why `examples/enums.tl` matches `Color` values
against `0`, `1`, `2`).

## 2.2 Types

```
Type         = NamedType | GenericType | SliceType | OptionalType
             | TupleType | RecordType | FnType | BoxedType | ImplType | DynType ;
NamedType    = Path ;
GenericType  = Path "<" Type { "," Type } ">" ;
SliceType    = "[" Type "]" | "[]" Type ;
OptionalType = Type "?" ;
TupleType    = "(" Type { "," Type } ")" ;
RecordType   = "{" [ RecordField { "," RecordField } ] "}" ;
RecordField  = Ident ":" Type ;
FnType       = "fn" "(" [ Type { "," Type } ] ")" [ "->" Type ] ;
BoxedType    = "Box" "<" Type ">" ;
ImplType     = "impl" Ident ;
DynType      = "dyn" Ident ;
```

`[]T` and `[T]` are the same slice type; `T?` is optional. A `RecordType` is an
anonymous inline shape — `{a: Int, b: String}` — used where naming a struct
would add nothing (result shapes in declarations). It carries field names for
readers; the type checker erases it to a tuple of its field types. `{T, U}` is
the unnamed form.

`FnType` without `->` means the function returns nothing (`fn()`), which is the
parameter form used by callbacks that take no arguments and produce no value.

### Contextual keywords in names

Keywords are reserved where the grammar expects a construct, but a *name*
position (`field: Type`, `fn name(...)`, parameter lists) accepts the reserved
word as an identifier. This is what allows `type: String`, `return: Float` and
`fn await(self)` — spellings that appear throughout the shipped stdlib and in
ordinary API shapes. A keyword is never reinterpreted inside an expression.

### Generic type aliases

`type MetaPrivate<T> = private T` declares an alias with parameters; the
parameters are accepted for documentation and erased — the alias denotes its
target type.

## 2.3 Statements

Thirteen statement kinds (`StmtKind`):

```
Statement    = LetStmt | VarStmt | Destructure | ExprStmt | ReturnStmt | ForStmt
             | WhileStmt | WhileLet | BailStmt | BreakStmt | ContinueStmt
             | LoopStmt | DeferStmt ;
LetStmt      = ( "let" | "var" ) Ident [ ":" Type ] "=" Expr ;
Destructure  = "let" "(" Ident { "," Ident } ")" "=" Expr ;
ExprStmt     = Expr ;
ReturnStmt   = "return" [ Expr ] ;
ForStmt      = "for" Ident "in" Expr Block ;
WhileStmt    = "while" Expr Block ;
WhileLet     = "while" "let" Pattern "=" Expr Block ;
BailStmt     = "bail" Expr ;
BreakStmt    = "break" ;
ContinueStmt = "continue" ;
LoopStmt     = "loop" Block ;
DeferStmt    = "defer" Block ;
```

`let` binds immutably; `var` binds mutably; `const` is an item, not a statement, and MUST
carry a type and an initialiser.

## 2.4 Expressions

Twenty-nine expression kinds. The operator grammar is precedence-climbing with the binding
powers below — these are the parser's numbers, and a conforming parser MUST reproduce the
same grouping.

```
Expr         = UnaryExpr { InfixOp UnaryExpr } | PostfixOp ;
UnaryExpr    = ( "-" | "!" | "~" | "*" ) UnaryExpr | Primary ;
Primary      = Literal | Ident | Path | "(" Expr ")"
             | Block | IfExpr | MatchExpr | ArrayLit | MapLit
             | StructLit | Closure | "spawn" Expr | "select" Block ;
Block        = "{" { Statement } [ Expr ] "}" ;
IfExpr       = "if" Expr Block [ "else" ( IfExpr | Block ) ] ;
IfLet        = "if" "let" Pattern "=" Expr Block [ "else" Block ] ;
MatchExpr    = Expr "match" "{" { Pattern "->" Expr } "}" ;
ArrayLit     = "[" [ Expr { "," Expr } ] "]" ;
StructLit    = Path "{" { Ident ":" Expr "," } "}" ;
Closure      = "{" [ Ident ":" Type ] "->" Expr "}" ;
PostfixOp    = ( "." Ident | "." Ident "(" ArgList ")" | "[" Expr "]"
               | "?" | "as" Type | "await" ) ;
```

`match` is **postfix**: the scrutinee precedes the keyword (`expr match { … }`), and arms
use `->`, not `=>`. Closures are braces with an explicit parameter type and `->`
(`{ x: i64 -> x * 2 }`); a closure with no parameters is `{ -> expr }`.

## 2.5 Operator precedence

Lower number binds looser. The last column is associativity, derived from the left/right
binding powers.

| Operators | Left / Right | Associativity |
|---|---|---|
| `\|\|` | 3 / 4 | left |
| `&&` | 5 / 6 | left |
| `\|` | 7 / 8 | left |
| `^` | 9 / 10 | left |
| `&` | 11 / 12 | left |
| `==` `!=` | 13 / 14 | left |
| `<` `>` `<=` `>=` | 15 / 16 | left |
| `..` | 17 / 18 | left |
| `<<` `>>` | 19 / 20 | left |
| `+` `-` | 21 / 22 | left |
| `*` `/` `%` | 23 / 24 | left |
| `**` | 26 / 25 | **right** |

`**` is the only right-associative binary operator: `2 ** 3 ** 2` is `2 ** (3 ** 2)`.
Assignment (`=`) and the compound forms (`+=`, `-=`, `*=`, `/=`, `%=`, `**=`, `<<=`, `>>=`,
`&=`, `|=`, `^=`) are expressions of the `Assign` kind, not statements, and bind looser
than every operator above.

## 2.6 Patterns

```
Pattern      = Literal | Ident | "_" | Path "(" Pattern { "," Pattern } ")"
             | "(" Pattern { "," Pattern } ")" ;
```

Five pattern kinds: literal (including bare integers for enum discriminants), identifier
(binding), wildcard, variant (`Ok(x)`, `Err(e)`), and tuple.

## 2.7 What the grammar does not say

Precedence and grouping are syntax. Whether `a + b` is *legal* — operand types, numeric
promotion, whether an optional may be used at all — is the subject of §3, and whether it
evaluates in left-to-right order is the subject of §4.
