#! /bin/bash

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
  input="$1"
  ./9cc "$input" > tmp.s
  gcc -o tmp tmp.s
  ./tmp
  ret="$?"
  echo "$input -> $ret (This evalution don't checked.)"
}

msg(){
  # underscore;Cyan
  echo -e "\n\033[4;36m$1\033[0;37m"
}

msg "加算，減算のテスト"
try 2 "1+1"
try 100 "20-10+120-5-5-30+10"
try 24 "   5 - 2+4  +3 -1+4 + 12-     1"
try 1 " 2+   3 - 3-1  "

msg "エラー出力のテスト"
./9cc "1+ hoge- 3"

msg "四則演算のテスト"
try 90 "50+25+5*(10/2)-10"
try 6 "2*3"
try 2 "1+5/3"
try 3 " ( 10* 2 +   1 -3) / 6"
try 2 "20 *2/ (4*(2+3))"

msg "単項演算子のテスト"
try 1 "+1"
try 1 "-1*-1"
try 1 "++++1"
try 1 "----1"
try 1 "-2* 2 + +5"
try 10 "+10/-2+-7-(-2)++20"
try 3 "2 --1"

msg "比較演算子のテスト"
try 1 "100==100"
try 0 "100==0"
try 1 "100!=0"
try 0 "100!=100"
try 1 "100>0"
try 0 "100<0"
try 0 "100>100"
try 0 "100<100"

try 1 "100>=0"
try 0 "100<=0"
try 1 "100>=100"
try 1 "100<=100"

try 1 "1+1>0"
try 2 "1+(1>0)"
try 0 "(1+1)<0"

try 1 "1<2 == 3<4"
try 1 "1>2 != 3<4"

out "(2+10)*2==24"

echo -e "\nOK"
