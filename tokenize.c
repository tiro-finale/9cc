#include "9cc.h"

/*
 * トークナイザ
 */

bool peek(char *op){
  return !(token->kind != TK_RESERVED || strlen(op) != token->len || memcmp(token->str, op, token->len));
}

bool consume(char *op){
  if(!peek(op)){
    return false;
  }
  token = token->next;
  return true;
}

Token *consume_ident(){
  if(token->kind != TK_IDENT){
    return NULL;
  }
  Token *tok = token;
  token = token->next;
  return tok;
}

void expect(char *op){
  if(!peek(op)){
    error_at(token->str, "'%s'を期待しています．", op);
  }
  token = token->next;
}

char *expect_ident(){
  if(token->kind != TK_IDENT){
    error_at(token->str, "識別子を期待しています．");
  }
  char *buf = (char*)malloc(token->len + 1);
  strncpy(buf, token->str, token->len);
  buf[token->len] = '\0';
  token = token->next;
  return buf;
}

int expect_number(){
  if(token->kind != TK_NUM){
    error_at(token->str, "数を期待しています．");
  }
  int val = token->val;
  token = token->next;
  return val;
}

bool at_eof(){
  return token->kind == TK_EOF;
}

Token *new_token(TokenKind kind, Token *cur, char *str, int len){
  Token *new = (Token*)calloc(1, sizeof(Token));
  new->kind = kind;
  new->str = str;
  new->len = len;
  cur->next = new;
  return new;
}

// 入力されたプログラムの記号が正しいか確認する．
bool check_symbol(char *p, char *q){
  return !memcmp(p, q, strlen(q));
}

bool is_alpha(char c){
  return isalpha(c) || c == '_';
}

bool is_alnum(char c){
  return isalpha(c) || isdigit(c) || c == '_';
}

Token *tokenize(){

  char *p = user_input;

  Token head;
  head.next = NULL;
  Token *cur = &head;

  while(*p){

    /*
     * ここのif文では，文字長が長いトークンから判別する．
     * なぜなら，>=よりも先に>をトークン化しようとすると
     * >=の>が優先されてトークン化され，=は無視されるからである．
     * ただし空白や数字は他の演算子や識別子と被ることはないので
     * どこに書いても問題ない．
     */

    // if
    if(check_symbol(p, "if") && !is_alnum(p[2])){
      cur = new_token(TK_RESERVED, cur, p, 2);
      p += 2;
      continue;
    }

    // else
    if(check_symbol(p, "else") && !is_alnum(p[4])){
      cur = new_token(TK_RESERVED, cur, p, 4);
      p += 4;
      continue;
    }

    // while
    if(check_symbol(p, "while") && !is_alnum(p[5])){
      cur = new_token(TK_RESERVED, cur, p, 5);
      p += 5;
      continue;
    }

    // for
    if(check_symbol(p, "for") && !is_alnum(p[3])){
      cur = new_token(TK_RESERVED, cur, p, 3);
      p += 3;
    }

    // return
    if(check_symbol(p, "return") && !is_alnum(p[6])){
      cur = new_token(TK_RESERVED, cur, p, 6);
      p += 6;
      continue;
    }

    // 空白を無視する．
    if(isspace(*p)){
      p++;
      continue;
    }

    // 比較演算子
    if(check_symbol(p, "==") || check_symbol(p, "!=") ||
       check_symbol(p, ">=") || check_symbol(p, "<=")){
        cur = new_token(TK_RESERVED, cur, p, 2);
        p += 2;
        continue;
    }
    if(check_symbol(p, ">") || check_symbol(p, "<")){
      cur = new_token(TK_RESERVED, cur, p, 1);
      p++;
      continue;
    }

    // 代入
    if(check_symbol(p, "=")){
      cur = new_token(TK_RESERVED, cur, p, 1);
      p++;
      continue;
    }

    // ターミネータ
    if(check_symbol(p, ";")){
      cur = new_token(TK_RESERVED, cur, p, 1);
      p++;
      continue;
    }

    // 四則演算，ポインタ(*)
    if(check_symbol(p, "+") || check_symbol(p, "-") ||
       check_symbol(p, "*") || check_symbol(p, "/") ||
       check_symbol(p, "(") || check_symbol(p, ")") ){
      cur = new_token(TK_RESERVED, cur, p, 1);
      p++;
      continue;
    }

    // アドレス，AND
    if(check_symbol(p, "&")){
      cur = new_token(TK_RESERVED, cur, p, 1);
      p++;
      continue;
    }

    // ブロック
    if(check_symbol(p, "{") || check_symbol(p, "}")){
      cur = new_token(TK_RESERVED, cur, p, 1);
      p++;
      continue;
    }

    // カンマ演算子
    if(check_symbol(p, ",")){
      cur = new_token(TK_RESERVED, cur, p, 1);
      p++;
      continue;
    }

    // int
    if(check_symbol(p, "int") && !is_alnum(p[3])){
      cur = new_token(TK_RESERVED, cur, p, 3);
      p += 3;
      continue;
    }

    // 変数，関数
    if(is_alpha(*p)){
      int l = 1;
      while(is_alnum(p[l])){
        l++;
      }
      cur = new_token(TK_IDENT, cur, p, l);
      p += l;
      continue;
    }

    // 数値
    if(isdigit(*p)){
      cur = new_token(TK_NUM, cur, p, 0);
      cur->val = strtol(p, &p, 10);
      continue;
    }

    // それ以外
    error_at(p, "トークナイズできない文字です．");
  }

  new_token(TK_EOF, cur, p, 0);
  return head.next;
}

