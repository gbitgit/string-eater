#include <ruby.h>

#define puts_inspect(var) \
  ID inspect = rb_intern("inspect"); \
  VALUE x = rb_funcall(var, inspect, 0); \
  printf("%s\n", StringValueCStr(x));

#define USE_METHOD(name) \
  static ID name = 0; \
  if(!name){ name = rb_intern(#name); }

static VALUE rb_cCTokenizer;
static VALUE rb_mStringEater;

static void set_token_startpoint(VALUE self, long token_ix, size_t ix)
{
  USE_METHOD(set_token_startpoint);
  rb_funcall(self, 
      set_token_startpoint,
      2, /* # args */
      INT2FIX(token_ix),
      INT2FIX(ix));
}

static void set_token_endpoint(VALUE self, long token_ix, size_t ix)
{
  USE_METHOD(set_token_endpoint);
  rb_funcall(self, 
      set_token_endpoint,
      2, /* # args */
      INT2FIX(token_ix),
      INT2FIX(ix));
}

static unsigned char should_extract_token(VALUE self, long token_ix)
{
  static ID m_extract_token = 0;
  if(!m_extract_token){
    m_extract_token = rb_intern("extract_token?");
  }
  return RTEST(rb_funcall(self,
      m_extract_token,
      1, /* # args */
      INT2FIX(token_ix)));
}

static size_t get_token_startpoint(VALUE self, unsigned int token_ix)
{
  USE_METHOD(get_token_startpoint);
  return FIX2UINT(rb_funcall(self, 
        get_token_startpoint,
        1,
        INT2FIX(token_ix)));
}

static void extract_token(VALUE self,
    VALUE names,
    unsigned int token_ix,
    size_t endpoint,
    const char* input_string)
{
  USE_METHOD(extract_token);

  /* need to fetch the startpoint */
  size_t startpoint = get_token_startpoint(self, token_ix);

  rb_funcall(self,
      extract_token,
      2,
      rb_ary_entry(names, token_ix),
      rb_usascii_str_new(input_string + startpoint,
        endpoint - startpoint));
}

static VALUE tokenize_string(VALUE self, 
    VALUE string,
    VALUE tokens_to_find_indexes,
    VALUE tokens_to_find_strings,
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
          /* set breakpoints, decide if we need to extract */
          set_token_endpoint(self, curr_token_ix - 1, ix);
          if(should_extract_token(self, curr_token_ix - 1))
          {
            /* need to fetch the startpoint */
            size_t startpoint = get_token_startpoint(self, curr_token_ix - 1);

            rb_hash_aset(extracted_tokens,
                rb_ary_entry(tokens_to_extract_names, curr_token_ix - 1),
                rb_usascii_str_new(input_string + startpoint,
                  ix - startpoint));
          }
        }
        set_token_startpoint(self, curr_token_ix, ix);
      }
      if(looking_for_ix >= looking_for_len - 1)
      {
        /* set breakpoints */
        set_token_endpoint(self, curr_token_ix, ix);
        /* leaving token */
        if(curr_token_ix >= n_tokens-1)
        {
          break;
        }
        else
        {
          set_token_startpoint(self, curr_token_ix + 1, ix + 1);
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

  ix = str_len;
  curr_token_ix = n_tokens - 1;
  set_token_endpoint(self, curr_token_ix, ix);

  if(should_extract_token(self, curr_token_ix))
  {
    size_t startpoint = get_token_startpoint(self, curr_token_ix);
    rb_hash_aset(extracted_tokens,
        rb_ary_entry(tokens_to_extract_names, curr_token_ix),
        rb_usascii_str_new(input_string + startpoint,
          ix - startpoint));
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

  rb_define_method(rb_cCTokenizer, "ctokenize!", tokenize_string, 4);

  /* set the callback for when the extension is unloaded */
  rb_set_end_proc(finalize_c_tokenizer_ext, 0);
}
