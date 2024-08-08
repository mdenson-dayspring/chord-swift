# Prototype of the Chord language

## Command Usage

The Chord interpreter currently is a command line program.

The command can be invoked passing in Chord source files (CSF) and/or a single line of Chord source.

    $ chord [filename1.csf [... filenamen.csf]] [-- Chord_source]
    
###### Examples A:

    $ chord
    Chord Version 0.9.1
    Copyright © 2024 Matthew Denson
    All rights reserved
    ↦ chord>

In this example the Chord interpreter is started and the REPL (Read-Eval-Print-Loop) is started.

###### Examples B:
    
    $ chord -- 1 2 3 4
    Chord Version 0.9.1
    Copyright © 2024 Matthew Denson
    All rights reserved
    ↦ 1 2 3 4 chord>
        
In this example the Chord interpreter is started and the source after -- is interpreted. 
On completion of the interpretation because there are values the operand stack (the integers 
1, 2, 3, and 4) the REPL is started.

###### Examples C:

    $ chord bingo.csf
    $
    
In this example the Chord interpreter is started and the source in the file bingo.csf is interpreted. 
If the operand stack is empty Chord will exit when finished.

###### Examples D:

    $ chord convert.csf -- "(in mm = ) print 1 yard 2 feet 5.5 inches + + ="
    in mm = 1663.6999999999998
    $

In this example the Chord interpreter is started and the source in the file convert.csf is 
interpreted. Assuming the words yard, feet and inches are defined in convert.csf then the inline
source will be run and because the operand stack is empty Chord will exit when finished.

## Syntax

The characters (, ), <, >, [, ], {, }, \`, and # are special. They delimit syntactic entities
such as strings, procedure bodies, name literals, and comments. Any of these
characters terminates the entity preceding it and is not included in the entity.

All characters besides the white-space characters and delimiters are referred to as
regular characters. 

### Comments

Any occurrence of the character # outside a string introduces a comment. The
comment consists of all characters between the # and the next newline or form
feed, including regular, delimiter, space, and tab characters.

The scanner ignores comments, treating each one as if it were a single whitespace 
character. That is, a comment separates the token preceding it from the one
following. Thus the program fragment

    abc# comment {/#) blah blah blah
    123

is treated by the scanner as just two tokens: abc and 123. 

### Numbers

Numbers in the Chord language include:

- Signed integers, such as

    123 −98 43445 0 +17
    
- Real numbers, such as

    −.002 34.5 −3.62 123.6e10 1.0E−5 1E6 −1. 0.0

An integer consists of an optional sign followed by one or more decimal digits.
The number is interpreted as a signed decimal integer and is converted to an 
integer object. If it exceeds the implementation limit for integers, it is 
converted to a real object.

A real number consists of an optional sign and one or more decimal digits, with
an embedded period (decimal point), a trailing exponent, or both. The exponent,
if present, consists of the letter E or e followed by an optional sign and one or
more decimal digits. The number is interpreted as a real number and is converted
to a real (floating-point) object.

### Strings

There is one convention for quoting a literal string object:

- As literal text, enclosed in ( and )

#### Literal Text Strings

A literal text string consists of an arbitrary number of characters enclosed in
( and ). Any characters may appear in the string other than (, ), and ~, which must
be treated specially. Balanced pairs of parentheses in the string require no special
treatment.

The following lines show several valid strings:

    (This is a string)
    (Strings may contain newlines
    and such.)
    (Strings may contain special characters *!&}^# and
    balanced parentheses ( ) (and so on).)
    (The following is an empty string.)
    ()
    (It has 0 (zero) length.)
    
Within a text string, the ~ (tilde) character is treated as an “escape” for various 
purposes, such as including newline characters, unbalanced parentheses, and
the ~ character itself in the string. The character immediately following the ~ 
determines its precise interpretation.

    ~n line feed (LF)
    ~r carriage return (CR)
    ~t horizontal tab
    ~b backspace
    ~f form feed
    ~~ tilde
    ~( left parenthesis
    ~) right parenthesis

If the character following the ~ is not in the preceding list, the scanner ignores the
~. If the ~ is followed immediately by a newline (CR, LF, or CR-LF pair), the scanner 
ignores both the initial ~ and the newline; this breaks a string into multiple
lines without including the newline character as part of the string, as in the following example:

    (These ~
    two strings ~
    are the same.)
    (These two strings are the same.)
    
But if a newline appears without a preceding ~, the result is equivalent to ~n. For
example:

    (This string has a newline at the end of it.
    )
    (So does this one.~n)

### Names

Any token that consists entirely of regular characters and cannot be interpreted as
a number is treated as a name object (more precisely, an executable name). All
characters except delimiters and white-space characters can appear in names, 
including characters ordinarily considered to be punctuation.

The following are examples of valid names:

    abc Offset $$ 23A 13−456 a.b $MyDict @pattern
    
Use care when choosing names that begin with digits. For example, while 23A is a
valid name, 23E1 is a real number, and 23#1 is a radix number token that represents an integer.

A \` (back tick) introduces a literal name. The tick is not part of the
name itself, but is a prefix indicating that the following sequence of zero or more
regular characters constitutes a literal name object. There can be no white-space
characters between the \` and the name. 

### Arrays

The characters [ and ] are self-delimiting tokens that specify the construction of
an array. For example, the program fragment

    [ 123 `abc (xyz) ]
    
results in the construction of an array object containing the integer object 123,
the literal name object abc, and the string object xyz. Each token within the
brackets is executed in turn.

The [ and ] characters are special syntax for names that, when executed, invoke
operators that collect objects and construct an array containing them.

Thus the example

    [ 123 `abc (xyz) ]
    
contains these five tokens:

- The name object [
- The integer object 123
- The literal name object abc
- The string object xyz
- The name object ]

When the example is executed, a sixth object (the array) results from executing
the [ and ] name objects.

### Procedures

The special characters { and } delimit an executable array, otherwise known as a
procedure. The syntax is superficially similar to that for the array construction 
operators [ and ]; however, the semantics are entirely different and arise as a result of
scanning the procedure rather than executing it.

Scanning the program fragment

    {+ 2 /}

produces a single procedure object that contains the name object +, the integer
object 2, and the name object /. When the scanner encounters the initial {, it
continues scanning and creating objects, but the interpreter does not execute
them. When the scanner encounters the matching }, it puts all the objects created
since the initial { into a new executable array (procedure) object.

The interpreter does not execute a procedure immediately, but treats it as data; it
pushes the procedure on the operand stack. Only when the procedure is explicitly
invoked (by means yet to be described) will it be executed. Execution of the 
procedure—and of all objects within the procedure, including any embedded procedures—has 
been deferred. 

## Execution

Execution semantics are different for each of the various object types. Also, execution 
can be either immediate, occurring as soon as the object is created by the
scanner, or deferred to some later time.

### Immediate Execution

Some example Chord program fragments will help clarify the concept of execution. 
Example 1 illustrates the immediate execution of a few operators and
operands to perform some simple arithmetic.

###### Example 1

    40 60 + 2 /
    
The interpreter first encounters the literal integer object 40 and pushes it on the
operand stack. Then it pushes the integer object 60 on the operand stack.

Next, it encounters the executable name object **+**, which it looks up in the environment 
of the current dictionary stack. Unless **+** has been redefined elsewhere, the interpreter 
finds it associated with an operator object, which it
executes. This invokes a built-in function that pops the two integer objects off the
operand stack, adds them together, and pushes the result (a new integer object
whose value is 100) back on the operand stack.

The rest of the program fragment is executed similarly. The interpreter pushes
the integer 2 on the operand stack and then executes the name **/**. The **/** operator pops 
two operands off the stack (the integers whose values are 2 and 100),
divides the second-to-top one by the top one (100 divided by 2, in this case), and
pushes the real result 50.0 on the stack.

The source of the objects being executed by the Chord interpreter does not
matter. They may have been contained within an array or scanned in from a character 
stream. Executing a sequence of objects produces the same result regardless
of where the objects come from.

### Operand Order

In Example 1, 40 is the first and 60 is the second operand of the **+** operator.
That is, objects are referred to according to the order in which they are pushed on
the operand stack. This is the reverse of the order in which they are popped off by
the + operator. Similarly, the result pushed by the **+** operator is the first 
operand of the **/** operator, and 2 is its second operand.
The same terminology applies to the results of an operator. If an operator pushes
more than one object on the operand stack, the first object pushed is the first
result. This order corresponds to the usual left-to-right order of appearance of
operands in a Chord program.

### Deferred Execution

The first line of Example 2 defines a procedure named average that computes
the average of two numbers. The second line applies that procedure to the integers 
40 and 60, producing the same result as Example 1. 

###### Example 2

    `average {+ 2 /} def
    40 60 average
    
The interpreter first encounters the literal name average. Recall from "Syntax" section 
that \` introduces a literal name. The interpreter pushes this object on
the operand stack, as it would any object having the literal attribute.

Next, the interpreter encounters the executable array {+ 2 /}. Recall that
{ and } enclose a procedure (an executable array or executable packed array object)
that is produced by the scanner. This procedure contains three elements: the executable 
name **+**, the literal integer 2, and the executable name **/**. The interpreter has not 
encountered these elements yet.

Here is what the interpreter does:

1. Upon encountering this procedure object, the interpreter pushes it on the
operand stack, even though the object has the executable attribute. This is explained shortly.
2. The interpreter then encounters the executable name **def**. Looking up this
name in the current dictionary stack, it finds **def** to be associated in
**systemdict** with an operator object, which it invokes.
3. The **def** operator pops two objects off the operand stack (the procedure
{+ 2 /} and the name average). It enters this pair into the current dictionary 
(most likely **userdict**), creating a new association having the name average
as its key and the procedure {+ 2 /} as its value.
4. The interpreter pushes the integer objects 40 and 60 on the operand stack,
then encounters the executable name average.
5. It looks up average in the current dictionary stack, finds it to be associated
with the procedure {+ 2 /}, and executes that procedure. In this case, execution 
of the array object consists of executing the elements of the array — the
objects **+**, 2, and **/** — in sequence. This has the same effect as executing
those objects directly. It produces the same result: the real object 50.0.

Why did the interpreter treat the procedure as data in the first line of the example
but execute it in the second, despite the procedure having the executable attribute
in both cases? There is a special rule that determines this behavior: An executable
array encountered directly by the interpreter is treated as data (pushed on the operand stack), 
but an executable array or packed array encountered indirectly—as a result of executing 
some other object, such as a name or an operator—is invoked as a procedure.

This rule reflects how procedures are ordinarily used. Procedures appearing directly 
(either as part of a program being read from a file or as part of some larger
procedure in memory) are usually part of a definition or of a construct, such as a
conditional, that operates on the procedure explicitly. But procedures obtained
indirectly—for example, as a result of looking up a name—are usually intended
to be executed. 

### Control Constructs

In the Chord language, control constructs such as conditionals and iterations
are specified by means of operators that take procedures as operands. Example
3 computes the maximum of the values associated with the names a and b, as in
the steps that follow.

###### Example 3

    a b gt {a} {b} ifelse
    
1. The interpreter encounters the executable names a and b in turn and looks
them up. Assume both names are associated with numbers. Executing the
numbers causes them to be pushed on the operand stack.
2. The **gt** (greater than) operator removes two operands from the stack and compares 
them. If the first operand is greater than the second, it pushes the boolean value 
_true_. Otherwise, it pushes _false_.
3. The interpreter now encounters the procedure objects {a} and {b}, which it
pushes on the operand stack.
4. The **ifelse** operator takes three operands: a boolean object and two procedures.
If the boolean object’s value is _true_, **ifelse** causes the first procedure to be 
executed; otherwise, it causes the second procedure to be executed. All three 
operands are removed from the operand stack before the selected procedure is
executed.

In this example, each procedure consists of a single element that is an executable
name (either a or b). The interpreter looks up this name and, since it is associated
with a number, pushes that number on the operand stack. So the result of executing 
the entire program fragment is to push on the operand stack the greater of the
values associated with a and b.

### Execution of Specific Types

An object with the literal attribute is _always_ treated as data—pushed on the operand 
stack by the interpreter—regardless of its type. Even operator objects are
treated this way if they have the literal attribute.

For many objects, executing them has the same effect as treating them as data.
This is true of integer, real, boolean, dictionary, mark objects. So the distinction 
between literal and executable objects of these types is
meaningless. The following descriptions apply only to objects having the executable attribute.

- An _executable array_ (procedure) object is pushed on
the operand stack if it is encountered directly by the interpreter. If it is invoked
_indirectly_ as a result of executing some other object (a name or an operator), it
is _called_ instead. The interpreter calls a procedure by pushing it on the execution 
stack and then executing the array elements in turn. When the interpreter
reaches the end of the procedure, it pops the procedure object off the execution
stack. (Actually, it pops the procedure object when there is one element
remaining and then pushes that element; this permits unlimited depth of “tail
recursion” without overflowing the execution stack.)
- An _executable string_ object is pushed on the execution stack. The interpreter
then uses the string as a source of characters to be converted to tokens and
interpreted according to the PostScript syntax rules. This continues until the
interpreter reaches the end of the string. Then it pops the string object from the
execution stack.
- An _executable name_ object is looked up in the environment of the current dictionary 
stack and its associated value is executed. The interpreter looks first in
the top dictionary on the dictionary stack and then in other dictionaries successively 
lower on the stack. If it finds the name as a key in some dictionary, it
executes the associated value. To do that, it examines the value’s type and executable 
attribute and performs the appropriate action described in this section.
Note that if the value is a procedure, the interpreter executes it. If the interpreter 
fails to find the name in any dictionary on the dictionary stack, an **undefined**
error occurs.
- An _executable operator_ object causes the interpreter to perform one of the builtin 
operations described in this document.
- An _executable null_ object causes the interpreter to perform no action. In particular, 
it does not push the object on the operand stack. 

## Early Name Binding

Normally, when the Chord language scanner encounters an executable name
in the program being scanned, it simply produces an executable name object; it
does not look up the value of the name. It looks up the name only when the name
object is _executed_ by the interpreter. The lookup occurs in the dictionaries that
are on the dictionary stack at the time of execution.

A name object contained in a procedure is looked up each time the procedure is
executed. For example, given the definition

    /average {+ 2 /} def
    
the names **+** and **/** are looked up, yielding operators to be executed, every
time the **average** procedure is invoked.

This so-called late binding of names is an important feature of the Chord language. 
However, there are situations in which early binding is advantageous.

There are two facilities for looking up the values of names before execution: the
bind operator and the immediately evaluated name.

### bind Operator

The **bind** operator takes a procedure operand and returns a possibly modified
procedure. There are two kinds of modification: operator substitution and idiom
recognition.

#### Operator Substitution

The **bind** operator systematically replaces names with operators in a procedure. 
For each executable name whose value is an _operator_ (not an array, procedure, or 
other type), it replaces the name with the operator object. This lookup
occurs in the dictionaries that are on the dictionary stack at the time **bind** is executed. 
The effect of **bind** applies not only to the procedure being bound but to all
subsidiary procedures (executable arrays or executable packed arrays) contained
within it, nested to arbitrary depth.

When the interpreter subsequently executes this procedure, it encounters the
_operator_ objects, not the _names_ of operators. For example, if the **average** 
procedure has been defined as

    /average {+ 2 /} bind def
    
then during the execution of **average**, the interpreter executes the **+** and **/**
operators directly, without looking up the names **+** and **/**.

There are two main benefits to using **bind*:

- A procedure that has been bound will execute the sequence of operators that
were intended when the procedure was defined, even if one or more of the
operator names have been redefined in the meantime. This benefit is mainly of
interest in procedures that are part of the Chord implementation, such as
**dup** and **=**. Those procedures are expected to behave correctly and 
uniformly, regardless of how a user program may have altered its name environment.
- A bound procedure executes somewhat faster than one that has not been
bound, since the interpreter need not look up the operator names each time,
but can execute the operators directly. This benefit is of interest in most Chord 
programs. It is worthwhile to apply **bind** to any procedure that will be executed more than a few
times.

It is important to understand that **bind** replaces only those names whose values
are _operators_ at the time **bind** is executed. Names whose values are of other types,
particularly procedures, are not disturbed. If an operator name has been redefined in some 
dictionary above **systemdict** on the dictionary stack _before_ the execution of **bind**, 
occurrences of that name in the procedure will not be replaced.

_ **Note:** Certain standard language features are implemented as
built-in procedures, such as **=** rather than as operators. Also, certain names, such as **true**, **false**,
and **null**, are associated directly with literal values in **systemdict**. Occurrences of such
names in a procedure are not altered by bind._ 

### Immediately Evaluated Names

Most implementations include a syntax feature called _immediately evaluated names_. When
the Chord language scanner encounters a token of the form _\`\`name_ (a name
preceded by two tildes with no intervening spaces), it immediately looks up the
name and substitutes the corresponding value. This lookup occurs in the dictionaries 
on the dictionary stack at the time the scanner encounters the token. If it
cannot find the name, an **undefined** error occurs.

The substitution occurs _immediately_—even inside an executable array delimited
by { and }, where execution is deferred. Note that this process is a _substitution_ and
not an _execution_; that is, the name’s value is not executed, but rather is substituted
for the name itself, just as if the **load** operator were applied to the name.

The most common use of immediately evaluated names is to perform early binding of 
objects (other than operators) in procedure definitions. The **bind** operator,
described in the previous section, performs early binding of operators; binding
objects of other types requires the explicit use of immediately evaluated names.
Example 4 illustrates the use of an immediately evaluated name to bind a reference 
to a dictionary.

###### Example 4

    `mydict << … >> def
    `proc
    { ``mydict begin
      …
       end
    } bind def
    
In the definition of proc, _\`\`mydict _is an immediately evaluated name. At the 
moment the scanner encounters the name, it substitutes the name’s current value,
which is the dictionary defined earlier in the example. The first element of the
executable array proc is a dictionary object, not a name object. When proc is 
executed, it will access that dictionary, even if in the meantime mydict has been 
redefined or the definition has been removed.

Another use of immediately evaluated names is to refer directly to permanent objects: 
standard dictionaries, such as **systemdict**, and constant literal objects, such
as the values of **true**, **false**, and **null**. On the other hand, it does not make sense to
treat the names of variables as immediately evaluated names. Doing so would
cause a procedure to be irrevocably bound to particular values of those variables.

A word of caution: Indiscriminate use of immediately evaluated names may
change the behavior of a program. As discussed in “Execution” section, the
behavior of a procedure differs depending on whether the interpreter encounters
it directly or as the result of executing some other object (a name or an operator).
Execution of the program fragments

    {… b …}
    {… ``b …}
    
will have different effects if the value of the name **b** is a procedure. So it is 
inadvisable to treat the names of operators as immediately evaluated names. A program 
that does so will malfunction in an environment in which some operators
have been redefined as procedures. This is why **bind** applies only to names whose
values are operators, not procedures or other types. 

## Operator Summary

### Operand Stack Manipulation Operators

|        Stack before | Operator        | Stack after                                 | |
| ------------------: | :-------------: | ------------------------------------------- | --------------- |
|               _any_ | **pop**         | _–_                                         | Discard top element|
|         _any1 any2_ | **exch**        | _any2 any1_                                 | Exchange top two elements|
|               _any_ | **dup**         | _any any_                                   | Duplicate top element|
|     _any1 … anyn n_ | **copy**        | _any1 … anyn any1 … anyn_                   | Duplicate top n elements|
|     _anyn … any0 n_ | **index**       | _anyn … any0 anyn_                          | Duplicate arbitrary element|
| _anyn−1 … any0 n j_ | **roll**        | _any(j−1) mod n … any0 anyn−1 … anyj mod n_ | Roll n elements up j times|
|       _any1 … anyn_ | **clear**       |                                             | Discard all elements|
|       _any1 … anyn_ | **count**       | _any1 … anyn n_                             | Count elements on stack|
|                 _–_ | **mark**        | _mark_                                      | Push mark on stack|
|  _mark obj1 … objn_ | **cleartomark** | _–_                                         | Discard elements down through mark|
|  _mark obj1 … objn_ | **counttomark** | _mark obj1 … objn n_                        | Count elements down to mark|

### Arithmetic and Math Operators

|        Stack before | Operator        | Stack after                                 | |
| ------------------: | :-------------: | ------------------------------------------- | --------------- |
| _num1 num2_ | **+** | _sum_ | Return num1 plus num2 |
| _num1 num2_ | **/** | _quotient_ | Return num1 divided by num2 |
| _int1 int2_ | **idiv** | _quotient_ | Return int1 divided by int2 |
| _int1 int2_ | **mod** | _remainder_ | Return remainder after dividing int1 by int2 |
| _num1 num2_ | **\*** | _product_ | Return num1 times num2 |
| _num1 num2_ | **-** | _difference_ | Return num1 minus num2 |
| _num1_ | **abs** | _num2_ | Return absolute value of num1 |
| _num1_ | **neg** | _num2_ | Return negative of num1 |
| _num1_ | **ceiling** | _num2_ | Return ceiling of num1 |
| _num1_ | **floor** | _num2_ | Return floor of num1 |
| _num1_ | **round** | _num2_ | Round num1 to nearest integer |
| _num1_ | **truncate** | _num2_ | Remove fractional part of num1 |
| _num_ | **sqrt** | _real_ | Return square root of num |
| _real_ | **acos** | _angle_ | Return arccosine of number in degrees |
| _real_ | **asin** | _angle_ | Return arcsine of number in degrees |
| _num den_ | **atan** | _angle_ | Return arctangent of num/den in degrees |
| _angle_ | **cos** | _real_ | Return cosine of angle degrees |
| _angle_ | **sin** | _real_ | Return sine of angle degrees |
| _angle_ | **tan** | _real_ | Return tangent of angle degrees |
| _base exponent_ | **exp** | _real_ | Raise base to exponent power |
| _num_ | **ln** | _real_ | Return natural logarithm (base e) |
| _num_ | **log** | _real_ | Return common logarithm (base 10) |
| _–_ | **rand** | _int_ | Generate pseudo-random integer |

### Array Operators

|        Stack before | Operator        | Stack after                                 | |
| ------------------: | :-------------: | ------------------------------------------- | --------------- |
| _int_ | **array** | _array_ | Create array of length int |
| _–_ | **[** | _mark_ | Start array construction |
| _mark obj0 … objn−1_ | **]** | _array_ | End array construction |
| _array_ | **length** | _int_ | Return number of elements in array |
| _array index_ | **get** | _any_ | Return array element indexed by index |
| _array index any_ | **put** | _–_ | Put any into array at index |
| _any0 … anyn−1 array_ | **astore** | _array_ | Pop elements from stack into array |
| _array_ | **aload** | _any0 … anyn−1 array_ | Push all elements of array on stack |
| _array proc_ | **forall** | _–_ | Execute proc for each element of array |

### Relational, Boolean, and Bitwise Operators

|              Stack before | Operator  | Stack after   |                                       |
| ------------------------: | :-------: | ------------- | ------------------------------------- |
|               _any1 any2_ | **eq**    | _bool_        | Test equal                            | 
|               _any1 any2_ | **ne**    | _bool_        | Test not equal                        | 
|   _num1\|str1 num2\|str2_ | **ge**    | _bool_        | Test greater than or equal            | 
|   _num1\|str1 num2\|str2_ | **gt**    | _bool_        | Test greater than                     | 
|   _num1\|str1 num2\|str2_ | **le**    | _bool_        | Test less than or equal               | 
|   _num1\|str1 num2\|str2_ | **lt**    | _bool_        | Test less than                        | 
| _bool1\|int1 bool2\|int2_ | **and**   | _bool3\|int3_ | Perform logical\|bitwise and          | 
|             _bool1\|int1_ | **not**   | _bool2\|int2_ | Perform logical\|bitwise not          | 
| _bool1\|int1 bool2\|int2_ | **or**    | _bool3\|int3_ | Perform logical\|bitwise inclusive or | 
| _bool1\|int1 bool2\|int2_ | **xor**   | _bool3\|int3_ | Perform logical\|bitwise exclusive or | 
|                       _–_ | **true**  | _true_        | Return boolean value true             | 
|                       _–_ | **false** | _false_       | Return boolean value false            | 

### Control Operators

|                   Stack before | Operator   | Stack after  | |
| -----------------------------: | :--------: | ------------ | --------------- |
|                          _any_ | **exec**   | _–_          | Execute arbitrary object | 
|                    _bool proc_ | **if**     | _–_          | Execute proc if bool is true | 
|             _bool proc1 proc2_ | **ifelse** | _–_          | Execute proc1 if bool is true, proc2 if false | 
| _initial increment limit proc_ | **for**    | _–_          | Execute proc with values from initial by steps of increment to limit | 

### Type, Attribute, and Conversion Operators

|   Stack before | Operator   | Stack after  |                           |
| -------------: | :--------: | ------------ | ------------------------- |
|          _any_ | **type**   | _name_       | Return type of any        | 
|          _any_ | **cvlit**  | _any_        | Make object literal       | 
|          _any_ | **cvx**    | _any_        | Make object executable    | 
|          _any_ | **xcheck** | _bool_       | Test executable attribute | 

### File Operators

|  Stack before | Operator   | Stack after   | |
| ------------: | :--------: | ------------- | ------------------ |
|    _filename_ | **run**    | _–_           | Execute contents of named file | 
|      _string_ | **print**  | _–_           | Write string to standard output file |
|         _any_ | **=**      | _–_           | Write text representation of any to standard output file |
|         _any_ | **==**     | _–_           | Write syntactic representation of any to standard output file |
| _any1 … anyn_ | **stack**  | _any1 … anyn_ | Print stack nondestructively using = |
| _any1 … anyn_ | **pstack** | _any1 … anyn_ | Print stack nondestructively using == |

### Miscellaneous Operators

|  Stack before | Operator      | Stack after | |
| ------------: | :-----------: | ----------- | --------------- |
|        _prod_ | **bind**      | _proc_      | Replace operator names in _proc_ with operators |
|           _–_ | **null**      | _null_      | Push _null_ on stack |
|           _–_ | **version**   | _string_    | Return interpreter version |
|           _–_ | **executive** | _–_         | Invoke interactive executive |
