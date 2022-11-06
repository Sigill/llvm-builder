// char* sh_single_quote (char *string)
// {
//   register int c;
//   char *result, *r, *s;

//   result = (char *)xmalloc (3 + (4 * strlen (string)));
//   r = result;
//   *r++ = '\'';

//   for (s = string; s && (c = *s); s++)
//   {
//     *r++ = c;

//     if (c == '\'')
//     {
//       *r++ = '\\';  /* insert escaped single quote */
//       *r++ = '\'';
//       *r++ = '\'';  /* start new quoted string */
//     }
//   }

//   *r++ = '\'';
//   *r = '\0';

//   return (result);
// }

/**
 * Does shell-like quoting using single quotes.
 *
 * Based on the sh_single_quote function from Bash.
 * @param str
 * @returns
 */
function _sh_single_quote(str: string) {
  // Doesn't need quoting, return as is.
  if (!/['"\s]/.test(str)) {
    return str;
  }

  let res = "";
  res += '\'';

  for (const c of str) {
    res += c;
    if (c === "'") {
      res += '\\';
      res += '\'';
      res += '\'';
    }
  }

  res += '\'';

  return res;
}

export function sh_single_quote(...str: string[]) {
  return str.map(_sh_single_quote).join(' ');
}