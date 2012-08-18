#include <ruby.h>

static VALUE rb_cCTokenizer;
static VALUE rb_mStringEater;

static VALUE tokenize_string(VALUE self, 
    VALUE string,
    VALUE tokens_to_find_indexes,
    VALUE tokens_to_find_strings,
    VALUE tokens_to_extract_indexes,
    VALUE tokens_to_extract_names)
{
  const char* input_string = StringValueCStr(string);
  VALUE extracted_tokens = rb_hash_new();
  VALUE curr_token;
  long curr_token_ix;
  long n_tokens_to_find = RARRAY_LEN(tokens_to_find_indexes);
  long n_tokens_to_extract = RARRAY_LEN(tokens_to_extract_indexes);
  size_t str_len = strlen(input_string);
  size_t ix;
  char c;
  char looking_for;
  size_t looking_for_len;
  size_t looking_for_ix = 0;
  long find_ix = 0;
  const char*  looking_for_token;

  curr_token = rb_ary_entry(tokens_to_find_strings, find_ix);
  curr_token_ix = rb_ary_entry(tokens_to_find_indexes, find_ix);
  looking_for_token = StringValueCStr(curr_token);
  looking_for_len = strlen(looking_for_token);
  looking_for = looking_for_token[looking_for_ix];

  for(ix = 0; ix < str_len; ix++)
  {
    c = input_string[ix];
    printf("'%c' == '%c'?\n", c, looking_for);
    if(c == looking_for)
    {
      printf("Yes\n");
      if(looking_for_ix == 0)
      {
        /* entering new token */
        if(curr_token_ix > 0)
        {
          /* set breakpoints, decide if we need to extract */
        }
      }
      if(looking_for_ix >= looking_for_len - 1)
      {
        /* leaving token */

        /* set breakpoints */

        /* next token */
        find_ix++;
        if(find_ix >= n_tokens_to_find)
        {
          /* done! */
          break;
        }
        curr_token = rb_ary_entry(tokens_to_find_strings, find_ix);
        curr_token_ix = rb_ary_entry(tokens_to_find_indexes, find_ix);
        looking_for_token = StringValueCStr(curr_token);
        looking_for_len = strlen(looking_for_token);
        looking_for_ix = 0;
      }
      else
      {
        looking_for_ix++;
      }
      looking_for = looking_for_token[looking_for_ix];
    }
  }

  return extracted_tokens;
}

void finalize_c_tokenizer_ext(VALUE unused)
{
  /* free memory, etc */
}

void Init_c_tokenizer_ext(void)
{
  rb_mStringEater = rb_define_module("StringEater");
  rb_cCTokenizer = rb_define_class_under(rb_mStringEater, 
      "CTokenizer", rb_cObject);

  rb_define_method(rb_cCTokenizer, "ctokenize!", tokenize_string, 5);

  /* set the callback for when the extension is unloaded */
  rb_set_end_proc(finalize_c_tokenizer_ext, 0);
}
