<H1>PRINT USING replacement</H1>
Ah yes, PRINT USING — completely forgotten by modern programmers, <BR>
yet it faithfully formatted millions of lines of output on the<BR>
TRS-80 Level II, every CP/M machine running Microsoft BASIC, and IBM PC's<BR>
running GW-BASIC.<BR><BR>

But sure, let's reinvent everything from scratch instead.<BR>

USING$ Formats a number or string using a GW-BASIC style format template.<BR>
Pass the format string and your data string, get back a neatly formatted result<BR><BR>
<ul>
 <li>right-justified numbers</li>
 <li>decimal alignment</li>
 <li>sign control</li>
 <li>currency symbols</li>
 <li>fixed-width string fields</li>
</ul>
all without needing PRINT USING.

<H1>Calling convention:</H1>
NEW$ = USNG$("####.##", STR$(myNumber)) <BR>
NEW$ = USNG$("!", myString$)<BR>
Both arguments are strings — convert numbers with STR$() before passing.<BR><BR>

Supported format specifiers:<BR>

| Format	| Behaviour |
|:--- |:--- |
| #       |	Digit position; right-justified, space-padded |
| .	      | Decimal point placement |
| +       | (leading or trailing)	Force sign display |
| -       | (trailing)	Trailing minus for negatives|
| **      | Fill leading spaces with * |
| $$	    | Floating $ sign
| **$	    | Both of the above
| ,	      | Thousands comma separators
| ^^^^    |	Exponential notation
| !	      | First character only
| \...\	  | Fixed-width string field
| &	      | Variable-length string (passthrough)
| %	      | Prepended automatically on overflow
