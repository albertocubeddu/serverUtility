# From the man xargs:
# -I replstr
#             Execute utility for each input line, replacing one or more occurrences of replstr in up to replacements (or 5 if no -R flag is specified) arguments to utility with the entire line of input.  The
#             resulting arguments, after replacement is done, will not be allowed to grow beyond 255 bytes; this is implemented by concatenating as much of the argument containing replstr as possible, to the
#             constructed arguments to utility, up to 255 bytes.  The 255 byte limit does not apply to arguments to utility which do not contain replstr, and furthermore, no replacement will be done on
#             utility itself.  Implies -x.

cat fileName | xargs -I{} cp {} directory/


#Multiple commands
cat fileName | xargs -I{} sh -c 'command1; command2 {}; ...'
