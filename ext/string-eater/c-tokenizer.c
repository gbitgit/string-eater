#include <ruby.h>

#define MAX_LITERAL_LENGTH 100

typedef struct t_literal_token
{
  unsigned int orig_id;
  const char* string;
  unsigned int length;
} t_literal_token;

static VALUE rb_cCTokenizer;
static VALUE rb_mStringEater;

static t_literal_token* g_pLiterals;

#define GET_SUBARRAY_ELEMENT(ary, i, j) RARRAY_PTR(RARRAY_PTR(ary)[i])[j]

static VALUE setup(VALUE self, VALUE tokens_to_find, VALUE tokens_to_extract)
{
  struct RArray* literals = RARRAY(tokens_to_find);
  long n_literals;
  long i;
  
  n_literals = RARRAY_LEN(tokens_to_find);

  g_pLiterals = (t_literal_token *)calloc(n_literals, sizeof(t_literal_token));

  for(i = 0; i < n_literals; i++)
  {
    printf("Lilteral %ld:\n", i);
    g_pLiterals[i].orig_id = NUM2INT(GET_SUBARRAY_ELEMENT(tokens_to_find, i, 0));
    g_pLiterals[i].string = StringValueCStr(GET_SUBARRAY_ELEMENT(tokens_to_find, i, 1));
    g_pLiterals[i].length = strlen(g_pLiterals[i].string);
    printf("  orig_id: %d\n", g_pLiterals[i].orig_id);
    printf("  string: '%s'\n", g_pLiterals[i].string);
    printf("  length: %d\n", g_pLiterals[i].length);
  }

  printf("Seting up with %ld literals\n", n_literals);

  return self;
}

static VALUE tokenize_string(VALUE self, VALUE string)
{
  const char* input_string = StringValueCStr(string);
  printf("Got: %s\n", input_string);

  return self;
}

void finalize_c_tokenizer_ext(VALUE unused)
{
  /* free memory, etc */
  free(g_pLiterals);
}

void Init_c_tokenizer_ext(void)
{
  rb_mStringEater = rb_define_module("StringEater");
  rb_cCTokenizer = rb_define_class_under(rb_mStringEater, 
      "CTokenizer", rb_cObject);

  rb_define_method(rb_cCTokenizer, "ctokenize", tokenize_string, 1);
  rb_define_method(rb_cCTokenizer, "do_ext_setup", setup, 2);

  /* set the callback for when the extension is unloaded */
  rb_set_end_proc(finalize_c_tokenizer_ext, 0);
}
