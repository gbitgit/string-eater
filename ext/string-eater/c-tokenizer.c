#include <ruby.h>

/* not used in production - useful for debugging */
#define puts_inspect(var) \
  ID inspect = rb_intern("inspect"); \
  VALUE x = rb_funcall(var, inspect, 0); \
  printf("%s\n", StringValueCStr(x));

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
  unsigned int curr_token_ix;
  long n_tokens_to_find = RARRAY_LEN(tokens_to_find_indexes);
  size_t str_len = strlen(input_string);
  size_t ix;
  char c;
  char looking_for;
  size_t looking_for_len;
  size_t looking_for_ix = 0;
  long find_ix = 0;
  const char*  looking_for_token;
  unsigned int n_tokens = (unsigned int)RARRAY_LEN(rb_iv_get(self, "@tokens"));

  size_t startpoint = 0;

  long n_tokens_to_extract = RARRAY_LEN(tokens_to_extract_indexes);
  long last_token_extracted_ix = 0;

  long next_token_to_extract_ix = NUM2UINT(rb_ary_entry(tokens_to_extract_indexes, last_token_extracted_ix));

  curr_token = rb_ary_entry(tokens_to_find_strings, find_ix);
  curr_token_ix = NUM2UINT(rb_ary_entry(tokens_to_find_indexes, find_ix));
  looking_for_token = StringValueCStr(curr_token);
  looking_for_len = strlen(looking_for_token);
  looking_for = looking_for_token[looking_for_ix];

  for(ix = 0; ix < str_len; ix++)
  {
    c = input_string[ix];
    if(c == looking_for)
    {
      if(looking_for_ix == 0)
      {
        /* entering new token */
        if(curr_token_ix > 0)
        {
          /* extract, if necessary */
          if((curr_token_ix - 1) == next_token_to_extract_ix)
          {
            last_token_extracted_ix++;
            if(last_token_extracted_ix < n_tokens_to_extract)
            {
              next_token_to_extract_ix = NUM2UINT(rb_ary_entry(tokens_to_extract_indexes, last_token_extracted_ix));
            }
            else
            {
              next_token_to_extract_ix = -1;
            }
            rb_hash_aset(extracted_tokens,
                rb_ary_entry(tokens_to_extract_names, curr_token_ix - 1),
                rb_usascii_str_new(input_string + startpoint,
                  ix - startpoint));
          }
        }
        startpoint = ix;
      }
      if(looking_for_ix >= looking_for_len - 1)
      {
        /* leaving token */
        if(curr_token_ix >= n_tokens-1)
        {
          break;
        }
        else
        {
          startpoint = ix + 1;
        }


        /* next token */
        find_ix++;
        if(find_ix >= n_tokens_to_find)
        {
          /* done! */
          break;
        }

        curr_token = rb_ary_entry(tokens_to_find_strings, find_ix);
        curr_token_ix = NUM2UINT(rb_ary_entry(tokens_to_find_indexes, find_ix));
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

  curr_token_ix = n_tokens - 1;

  if(ix < str_len && curr_token_ix == next_token_to_extract_ix)
  {
    rb_hash_aset(extracted_tokens,
        rb_ary_entry(tokens_to_extract_names, curr_token_ix),
        rb_usascii_str_new(input_string + startpoint,
          str_len - startpoint));
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
