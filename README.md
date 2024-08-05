# Prototype of the Chord language

## Command Usage

The Chord interpreter currently is a command line program that will put the user into a 
REPL (Read-Eval-Print-Loop).

The command can be invoked passing in Chord source files (CSF) and/or a single line of Chord source.

    $ chord [filename1.csf [... filenamen.csf]] [-- Chord source]
    
###### Examples:

    $ chord bingo.csf

In this example the Chord interpreter is started and the source in the file bingo.csf is interpreted. 
After completion of the file the REPL will be started

    $ chord -- 1 2 3 4
    
In this example the Chord interpreter is started and the source after -- is interpreted. On completion 
of the interpretation the REPL is started with the integers 1, 2, 3, and 4 in the operand stack. It will 
look something like:

    Chord Version 0.9.1
    Copyright © 2024 Matthew Denson
    All rights reserved
    ↦ 1 2 3 4 chord>
    
Note: that the inline source on the commandline is interpreted after the files are interpreted. So any procedures
defined in the files can be used in the inline source.

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
    −.002 34.5 −3.62 −1. 0.0

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

###### Example 3.1

    40 60 + 2 /
    
The interpreter first encounters the literal integer object 40 and pushes it on the
operand stack. Then it pushes the integer object 60 on the operand stack.

Next, it encounters the executable name object +, which it looks up in the environment 
of the current dictionary stack. Unless + has been redefined elsewhere, the interpreter 
finds it associated with an operator object, which it
executes. This invokes a built-in function that pops the two integer objects off the
operand stack, adds them together, and pushes the result (a new integer object
whose value is 100) back on the operand stack.

The rest of the program fragment is executed similarly. The interpreter pushes
the integer 2 on the operand stack and then executes the name /. The / operator pops 
two operands off the stack (the integers whose values are 2 and 100),
divides the second-to-top one by the top one (100 divided by 2, in this case), and
pushes the real result 50.0 on the stack.

The source of the objects being executed by the Chord interpreter does not
matter. They may have been contained within an array or scanned in from a character 
stream. Executing a sequence of objects produces the same result regardless
of where the objects come from.

### Operand Order

In Example 1, 40 is the first and 60 is the second operand of the + operator.
That is, objects are referred to according to the order in which they are pushed on
the operand stack. This is the reverse of the order in which they are popped off by
the + operator. Similarly, the result pushed by the + operator is the first operand of the / operator, and 2 is its second operand.
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
name +, the literal integer 2, and the executable name +. The interpreter has not 
encountered these elements yet.

Here is what the interpreter does:

1. Upon encountering this procedure object, the interpreter pushes it on the
operand stack, even though the object has the executable attribute. This is explained shortly.
2. The interpreter then encounters the executable name def. Looking up this
name in the current dictionary stack, it finds def to be associated in
systemdict with an operator object, which it invokes.
3. The def operator pops two objects off the operand stack (the procedure
{+ 2 /} and the name average). It enters this pair into the current dictionary 
(most likely userdict), creating a new association having the name average
as its key and the procedure {+ 2 /} as its value.
4. The interpreter pushes the integer objects 40 and 60 on the operand stack,
then encounters the executable name average.
5. It looks up average in the current dictionary stack, finds it to be associated
with the procedure {+ 2 /}, and executes that procedure. In this case, execution 
of the array object consists of executing the elements of the array—the
objects +, 2, and /—in sequence. This has the same effect as executing
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
2. The gt (greater than) operator removes two operands from the stack and compares 
them. If the first operand is greater than the second, it pushes the boolean value 
true. Otherwise, it pushes false.
3. The interpreter now encounters the procedure objects {a} and {b}, which it
pushes on the operand stack.
4. The ifelse operator takes three operands: a boolean object and two procedures.
If the boolean object’s value is true, ifelse causes the first procedure to be 
executed; otherwise, it causes the second procedure to be executed. All three 
operands are removed from the operand stack before the selected procedure is
executed.

In this example, each procedure consists of a single element that is an executable
name (either a or b). The interpreter looks up this name and, since it is associated
with a number, pushes that number on the operand stack. So the result of executing 
the entire program fragment is to push on the operand stack the greater of the
values associated with a and b.

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

|        Stack before | Operator        | Stack after                                 | |
| ------------------: | :-------------: | ------------------------------------------- | --------------- |
| _any1 any2_ | **eq** | _bool_ | Test equal | 
| _any1 any2_ | **ne** | _bool_ | Test not equal | 
| _num1\|str1 num2\|str2_ | **ge** | _bool_ | Test greater than or equal | 
| _num1\|str1 num2\|str2_ | **gt** | _bool_ | Test greater than | 
| _num1\|str1 num2\|str2_ | **le** | _bool_ | Test less than or equal | 
| _num1\|str1 num2\|str2_ | **lt** | _bool_ | Test less than | 
| _bool1\|int1 bool2\|int2_ | **and** | _bool3|int3_ | Perform logical|bitwise and | 
| _bool1\|int1_ | **not** | _bool2|int2_ | Perform logical|bitwise not | 
| _bool1\|int1 bool2\|int2_ | **or** | _bool3|int3_ | Perform logical|bitwise inclusive or | 
| _bool1\|int1 bool2\|int2_ | **xor** | _bool3|int3_ | Perform logical|bitwise exclusive or | 
| _–_ | **true** | _true_ | Return boolean value true | 
| _–_ | **false** | _false_ | Return boolean value false | 

### Control Operators

|        Stack before | Operator        | Stack after                                 | |
| ------------------: | :-------------: | ------------------------------------------- | --------------- |
| _any_ | **exec** | _–_ | Execute arbitrary object | 
| _bool proc_ | **if** | _–_ | Execute proc if bool is true | 
| _bool proc1 proc2_ | **ifelse** | _–_ | Execute proc1 if bool is true, proc2 if false | 
| _initial increment limit proc_ | **for** | _–_ | Execute proc with values from initial by steps of increment to limit | 

### Type, Attribute, and Conversion Operators

|        Stack before | Operator        | Stack after     | |
| ------------------: | :-------------: | --------------- | ------------------ |
| _any_               | **type**        | _name_          | Return type of any | 

### Miscellaneous Operators

|        Stack before | Operator        | Stack after         | |
| ------------------: | :-------------: | ------------------- | --------------- |
| _–_                 | **null**        | _null_              | Push null on stack |
| _–_                 | **executive**   | _–_                 | Invoke interactive executive |
