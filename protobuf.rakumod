use Grammar::PrettyErrors;

grammar protobuf does Grammar::PrettyErrors {

token ws {
  <!ww>
  [
    \s
    | [ '//' \V* [$|\n] ]
  ]*
}

# letter = "A" … "Z" | "a" … "z"
regex letter { <[A..Z] + [a..z]> }

# decimalDigit = "0" … "9"
regex decimalDigit { <[0..9]> }

# octalDigit   = "0" … "7"
regex octalDigit { <[0..7]> }

# hexDigit     = "0" … "9" | "A" … "F" | "a" … "f"
regex hexDigit { <[0..9A..Fa..f]> }

# ident = letter { letter | decimalDigit | "_" }
regex ident {
  <.letter>
  [ <.letter> | <.decimalDigit> | "_" ]*
}

# fullIdent = ident { "." ident }
regex fullIdent { <ident>+ % '.' }

# messageName = ident
# enumName = ident
# fieldName = ident
# oneofName = ident
# mapName = ident
# serviceName = ident
# rpcName = ident
regex messageName { <ident> }
regex enumName { <ident> }
regex fieldName { <ident> }
regex oneofName { <ident> }
regex mapName { <ident> }
regex serviceName { <ident> }
regex rpcName { <ident> }

# messageType = [ "." ] { ident "." } messageName
regex messageType { [ "." ]? [ <ident> '.' ]* <messageName> }

# enumType = [ "." ] { ident "." } enumName
regex enumType { [ '.' ] [ <ident> '.']+ <enumName> }

# intLit     = decimalLit | octalLit | hexLit
regex intLit { <decimalLit> | <octalLit> | <hexLit> }

# decimalLit = ( "1" … "9" ) { decimalDigit }
regex decimalLit { <[1..9]> <decimalDigit>* }

# octalLit   = "0" { octalDigit }
regex octalLit { '0' <octalDigit>* }

# hexLit = "0" ( "x" | "X" ) hexDigit { hexDigit }
regex hexLit { '0' <[xX]> <hexDigit>+ }

# floatLit = ( decimals "." [ decimals ] [ exponent ] | decimals exponent | "."decimals [ exponent ] )
#            | "inf" | "nan"
regex floatLit {
  [ | <decimals> '.' <decimals>? <exponent>?
    | <decimals> <exponent>
    | '.' <decimals> <exponent>? 
    ]
  | 'inf' | 'nan'
}

# decimals  = decimalDigit { decimalDigit }
regex decimals { <decimalDigit>+ }

# exponent  = ( "e" | "E" ) [ "+" | "-" ] decimals
regex exponent  {
  <[eE]> <[+-]> <decimals>
}

# boolLit = "true" | "false"
regex boolLit {
  true|false
}

# strLit = ( "'" { charValue } "'" ) |  ( '"' { charValue } '"' )
regex strLit {
  | "'" <.charValue>* "'"
  | '"' <.charValue>* '"'
}

# charValue = hexEscape | octEscape | charEscape | /[^\0\n\\]/
regex charValue {
  <hexEscape> | <octEscape> | <charEscape> | <-[\0\n\\]>
}

# hexEscape = '\' ( "x" | "X" ) hexDigit hexDigit
regex hexEscape {
  '\\' <[xX]> <hexDigit>**2
}

# octEscape = '\' octalDigit octalDigit octalDigit
regex octEscape {
  '\\' <octalDigit>**3
}

# charEscape = '\' ( "a" | "b" | "f" | "n" | "r" | "t" | "v" | '\' | "'" | '"' )
regex charEscape {
  '\\' <[abfnrtv\\'"]>
}

# quote = "'" | '"'
regex quote {
  <['"]>
}

# emptyStatement = ";"
regex emptyStatement {
  ';'
}

# constant = fullIdent | ( [ "-" | "+" ] intLit ) | ( [ "-" | "+" ] floatLit ) | strLit | boolLit
regex constant {
  | <fullIdent>
  | [ <[-+]>? <intLit> ]
  | [ <[-+]>? <floatLit> ]
  | <strLit>
  | <boolLit>
}

# syntax = "syntax" "=" quote "proto3" quote ";"
rule syntax {
  syntax '=' <quote> proto3 $<quote> ';'
}

# import = "import" [ "weak" | "public" ] strLit ";" </pre>
rule import {
  import [ weak | public | "" ] <strLit> ';'
}

# package = "package" fullIdent ";"
rule package {
  package <fullIdent> ';'
}

# option = "option" optionName  "=" constant ";"
rule option {
    option <optionName> '=' <constant> ';'
}

# optionName = ( ident | "(" fullIdent ")" ) { "." ident }
rule optionName {
  [ <ident> | '(' <fullIdent> ')' ]
  [ '.' <ident> ]*
}

# type = "double" | "float" | "int32" | "int64" | "uint32" | "uint64"
#       | "sint32" | "sint64" | "fixed32" | "fixed64" | "sfixed32" | "sfixed64"
#       | "bool" | "string" | "bytes" | messageType | enumType
regex type {
 < double float int32 int64 uint32 uint64
   sint32 sint64 fixed32 fixed64 sfixed32 sfixed64
   bool string bytes> | <messageType> | <enumType>
}

# fieldNumber = intLit
regex fieldNumber {
  <intLit>
}

# field = [ "repeated" ] type fieldName "=" fieldNumber [ "[" fieldOptions "]" ] ";"
rule field {
  [ repeated ]? <type> <fieldName> '=' <fieldNumber> [ '[' <fieldOptions> ']' ]? ';'
}

# fieldOptions = fieldOption { ","  fieldOption }
regex fieldOptions {
  <fieldOption>+ % ','
}

# fieldOption = optionName "=" constant
regex fieldOption {
 <optionName> '=' <constant>
}

# oneof = "oneof" oneofName "{" { oneofField | emptyStatement } "}"
rule oneof {
  oneof <oneofName> '{' [ <oneofField> | <emptyStatement> ]* '}'
}

# oneofField = type fieldName "=" fieldNumber [ "[" fieldOptions "]" ] ";"
rule oneofField {
  <type> <fieldName> '=' <fieldNumber> [ '[' <fieldOptions> ']' ]? ';'
}

# mapField="map" "<" " "," keytype type>" mapName "=" fieldNumber [ "[" fieldOptions "]" ] ";"
rule mapField {
  map '<' <keyType> ',' <type> '>' <mapName> '=' <fieldNumber> [ '[' <fieldOptions> ']' ]? ';'
}
#   map<int32, string> my_map = 4;

# keyType = "int32" | "int64" | "uint32" | "uint64" | "sint32" | "sint64" |
#           "fixed32" | "fixed64" | "sfixed32" | "sfixed64" | "bool" | "string"
regex keyType {
 < int32 int64 uint32 uint64 sint32 sint64 
   fixed32 fixed64 sfixed32 sfixed64 bool string >
}

# reserved = "reserved" ( ranges | fieldNames ) ";"
rule reserved {
 reserved [ <ranges> | <fieldNames> ] ';'
}

# ranges = range { "," range }
rule ranges {
  <range>+ % ','
}

# range =  intLit [ "to" ( intLit | "max" ) ]
rule range {
  <intLit> [ to [ <intLit> | max ] ]?
}

# fieldNames = fieldName { "," fieldName }
rule fieldNames {
  <fieldName>+ % ','
}

# enum = "enum" enumName enumBody
rule enum {
 enum <enumName> <enumBody>
}

# enumBody = "{" { option | enumField | emptyStatement } "}"
rule enumBody {
  '{' [ <option> | <enumField> | <emptyStatement> ]* '}'
}

# enumField = ident "=" intLit [ "[" enumValueOption { ","  enumValueOption } "]" ]";"
rule enumField {
  <ident> '=' <intLit>
  [ '[' <enumValueOption>+ % ',' ']' ]?
  ';'
}

# enumValueOption = optionName "=" constant</pre>
rule enumValueOption {
  <optionName> '=' <constant>
}

# message = "message" messageName messageBody
rule message {
 message <messageName> <messageBody>
}

# messageBody = "{" { field | enum | message | option | oneof | mapField | reserved | emptyStatement } "}"
rule messageBody {
  '{' [ <field> | <enum> | <message> | <option> | <oneof> | <mapField> | <reserved> | <emptyStatement> ]* '}'
}

# service = "service" serviceName "{" { option | rpc | emptyStatement } "}"
rule service {
  service <serviceName> '{' [
    <option> | <rpc> | <emptyStatement>
  ]* '}'
}

# rpc = "rpc" rpcName "(" [ "stream" ] messageType ")" "returns" "(" [ "stream" ]
#        messageType ")" (( "{" {option | emptyStatement } "}" ) | ";")
rule rpc {
  rpc
  <rpcName> '(' [ stream ]? <messageType> ')'
  returns
     '(' [ stream ]? <messageType> ')'
  [[ '{' [<option> | <emptyStatement>]* '}' ] | ';']
}

# proto = syntax { import | package | option | topLevelDef | emptyStatement }
rule proto {
  <syntax> [ <import> | <package> | <option> | <topLevelDef> | <emptyStatement> ]*
}

# topLevelDef = message | enum | service
rule topLevelDef {
 <message> | <enum> | <service>
}

rule TOP {
  [ \s
    | [ '//' \V* [$|\n] ]
  ]*
  <proto>
}

}

