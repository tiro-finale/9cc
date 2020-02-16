#! /bin/bash

msg(){
  # underscore;Cyan
  echo -e "\n\033[4;36m$1\033[0;37m"
}

try() {

  expected="$1"
  input="$2"

  ./9cc "$input" > tmp.s
  gcc -o tmp tmp.s
  ./tmp
  actual="$?"

  if [ "$actual" = "$expected" ]; then
    echo "$input -> $actual"
  else
    echo "$input -> $expected expected, but got $actual"
    exit 1
  fi
}

out(){
  compatible="$1"
  input="$2"
  ./9cc "$input" > tmp.s
  gcc -o tmp tmp.s
  ./tmp
  ret="$?"
  echo "$input -> $ret (This evalution is not checked.)"
}

testcase(){

  case $1 in
  1 )
    msg "加算，減算のテスト"
    try 2 "return 1+1;"
    try 100 "return 20-10+120-5-5-30+10;"
    try 24 "return   5 - 2+4  +3 -1+4 + 12-     1;"
    try 1 "return 2+   3 - 3-1  ;"
    ;;

  2 )
    msg "四則演算のテスト"
    try 90 "return 50+25+5*(10/2)-10;"
    try 6 "return 2*3;"
    try 2 "return 1+5/3;"
    try 3 "return  ( 10* 2 +   1 -3) / 6;"
    try 2 "return 20 *2/ (4*(2+3));"
    ;;

  3 )
    msg "単項演算子のテスト"
    try 1 "return +1;"
    try 1 "return -1*-1;"
    try 1 "return ++++1;"
    try 1 "return ----1;"
    try 1 "return -2* 2 + +5;"
    try 10 "return +10/-2+-7-(-2)++20;"
    try 3 "return 2 --1;"
    ;;

  4 )
    msg "比較演算子のテスト"
    try 1 "return 100==100;"
    try 0 "return 100==0;"
    try 1 "return 100!=0;"
    try 0 "return 100!=100;"
    try 1 "return 100>0;"
    try 0 "return 100<0;"
    try 0 "return 100>100;"
    try 0 "return 100<100;"

    try 1 "return 100>=0;"
    try 0 "return 100<=0;"
    try 1 "return 100>=100;"
    try 1 "return 100<=100;"

    try 1 "return 1+1>0;"
    try 2 "return 1+(1>0);"
    try 0 "return (1+1)<0;"

    try 1 "return 1<2 == 3<4;"
    try 1 "return 1>2 != 3<4;"

    try 1 "return (2+10)*2==24;"
    ;;

  5 )
    msg "変数代入のテスト"
    try   0 "a=0; return a;"
    try 100 "b=100; return b;"
    try  10 "z=2; return z*(z*z)+z;"
    try   6 "a=1; b=2; c=3; return c + a + b;"
    try   1 "hoge = 2; foo = 1 + hoge; return foo - hoge;"
    try   6 "I = 1; love = 2; you = 3; return I*love*you;"
    try   1 "greater = 100; less = 20; return greater > less;"
    ;;

  6 )
    msg "return文のテスト"
    try 6 "return 1+2+3;"
    try 2 "hoge=2; return hoge;"
    try 1 "return 1; 2; 3;"
    try 5 "4; return 5; 6;"
    try 9 "7; 8; return 9;"
    try 0 "return 0; return 1;"
    ;;

  7 )
    msg "if文のテスト"
    try  3 "if(1+2 == 3) return 3; return 2;"
    try  2 "if(1*2 == 3) return 3; return 2;"
    try  1 "if ( 0 ) return 100; return 2-1;"
    try  3 "foo=3; if(5-foo == 5-(2+1))   return foo; return 0;"
    try  0 "foo=3; if(5-foo != 5-(2+1))   return foo; return 0;"
    try  2 "abc = 5; hoge = 2; if ( 0 ) hoge = abc * 3; return hoge;"
    try 15 "abc = 5; hoge = 2; if ( 1 ) hoge = abc * 3; return hoge;"
    try  4 "num=1; if(num == 1) if(num == 1) num = num*2; num = num*2; return num;"
    try  2 "num=1; if(num == 1) if(num != 1) num = num*2; num = num*2; return num;"
    try  2 "num=1; if(num != 1) if(num == 1) num = num*2; num = num*2; return num;"
    try  2 "num=1; if(num != 1) if(num != 1) num = num*2; num = num*2; return num;"
    ;;

  * )
    exit 0
    ;;

  esac

  echo -e "\nOK"
}

for i in {1..100} ; do
  testcase $i
done

