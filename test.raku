#!/usr/bin/env perl6

use lib '.';
use Test;
use protobuf;

ok protobuf.parse("package foo.bar;",:rule<package>), 'package';
ok protobuf.parse("foo.bar",:rule<fullIdent>), 'fullIdent';
ok protobuf.parse('string', :rule<type>), 'type';
ok protobuf.parse('SubMessage', :rule<type>), 'type';
ok protobuf.parse('4', :rule<intLit>), 'int';
ok protobuf.parse('4', :rule<fieldNumber>), 'fieldNumber';
ok protobuf.parse('string name = 4;', :rule<oneofField>), 'oneofField';
ok protobuf.parse('SubMessage sub_message = 9;', :rule<oneofField>), 'oneofField';
ok protobuf.parse(q:to/X/, :rule<oneof>), 'oneof';
oneof foo {
    string name = 4;
    SubMessage sub_message = 9;
}
X

ok protobuf.parse('map<int32, string> my_map = 4;',:rule<mapField>), 'mapField';
ok protobuf.parse('map<string, Project> projects = 3;',:rule<mapField>), 'mapField';

ok protobuf.parse('9 to 11',:rule<range>), 'range';
ok protobuf.parse('reserved 2, 15, 9 to 11;',:rule<reserved>), 'reserved';
ok protobuf.parse('2, 9 to 11',:rule<ranges>), 'ranges';
# ok protobuf.parse('reserved "foo", "bar";',:rule<reserved>), 'reserved';
# ok protobuf.parse('"foo", "bar"',:rule<fieldNames>), 'fieldNames';

ok protobuf.parse('UNKNOWN = 0;',:rule<enumField>), 'enumField';
ok protobuf.parse('EnumAllowingAlias',:rule<enumName>), 'enumName';
ok protobuf.parse('"hello world"', :rule<constant>), 'constant';
ok protobuf.parse('RUNNING = 2 [(custom_option) = "hello world"];', :rule<enumField>), 'field';
ok protobuf.parse(q:to/X/, :rule<enum>), 'enum';
  enum EnumAllowingAlias {
    option allow_alias = true;
    UNKNOWN = 0;
    STARTED = 1;
    RUNNING = 2 [(custom_option) = "hello world"];
  }
  X
ok protobuf.parse(q:to/X/,:rule<field>), 'field';
  foo.bar nested_message = 2;
  X
ok protobuf.parse(q:to/X/,:rule<field>), 'field';
  repeated int32 samples = 4 [packed=true];
  X
ok protobuf.parse('foo.bar',:rule<type>), 'type';

ok protobuf.parse('Outer',:rule<messageName>), 'messageName';

ok protobuf.parse('option (my_option).a = true;',:rule<option>), 'option';

ok protobuf.parse(q:to/X/,:rule<message>), 'message';
message Outer {
  option (my_option).a = true;
  message Inner {
    int64 ival = 1;
  }
  map<int32, string> my_map = 2;
}
X

ok protobuf.parse(q:to/X/,:rule<service>), 'service';
  service SearchService {
    rpc Search (SearchRequest) returns (SearchResponse);
  }
  X

ok protobuf.parse(q:to/X/,:rule<service>), 'service';
  service SearchService {
    rpc Search (SearchRequest) returns (SearchResponse);
  }
  X

ok protobuf.parse('//', :rule<ws>), 'ws';
ok protobuf.parse('// comment', :rule<ws>), 'ws';
ok protobuf.parse(q:to/X/, :rule<package>), 'package';
package  // comment
  foo.bar;
X

ok protobuf.parse(q:to/X/.trim, :rule<syntax>), 'syntax';
syntax = "proto3";
X

ok protobuf.parse(q:to/PROTO/, :rule<proto>), 'proto';
syntax = "proto3";
import public "other.proto";
option java_package = "com.example.foo";
enum EnumAllowingAlias {
  option allow_alias = true;
  UNKNOWN = 0;
  STARTED = 1;
  RUNNING = 2 [(custom_option) = "hello world"];
}
message outer {
  option (my_option).a = true;
  message inner {   // Level 2
    int64 ival = 1;
  }
  repeated inner inner_message = 2;
  EnumAllowingAlias enum_field =3;
  map<int32, string> my_map = 4;
}
PROTO
