#include <ruby.h>

static VALUE CTokenizer;
static VALUE StringEater;

void Init_c_tokenizer_impl(void) {
  StringEater = rb_define_module("StringEater");
  CTokenizer = rb_define_class_under("CTokenizer", rb_cObject);
}
