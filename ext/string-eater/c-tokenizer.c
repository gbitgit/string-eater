#include <ruby.h>

static VALUE CTokenizer;
static VALUE StringEater;

static VALUE say_hi(VALUE self)
{
  printf("HELLO\n");

  return self;
}

void Init_c_tokenizer_ext(void) {
  StringEater = rb_define_module("StringEater");
  CTokenizer = rb_define_class_under(StringEater, "CTokenizer", rb_cObject);

  rb_define_method(CTokenizer, "say_hi", say_hi, 0);
}
