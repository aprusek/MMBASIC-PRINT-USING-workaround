' ============================================================
' USNG$(fmt$, val$) - PRINT USING formatter for MMBasic
' fmt$ = format string  e.g. "###.##" or "!!" or "\"  \"
' val$ = the data as a string (numeric or text)
' Returns: formatted string
' ============================================================
FUNCTION USNG$(fmt$, val$) AS STRING
  LOCAL i%, fc$, out$, lead$, trail$
  LOCAL numval!, intpart&, ldig%, rdig%, dotpos%
  LOCAL istr$, fstr$, tmp!, digit%, j%, pad$
  LOCAL hasdot%, hasplus%, hasminus%, hasstar%, hasdollar%, hascomma%, hasexp%
  LOCAL width%, slen%

  ' ---- Detect format type: string field or numeric field ----
  fc$ = LEFT$(fmt$, 1)

  ' --- String field: ! (first char only) ---
  IF fc$ = "!" THEN
    USNG$ = LEFT$(val$, 1)
    EXIT FUNCTION
  END IF

  ' --- String field: & (output as-is) ---
  IF fc$ = "&" THEN
    USNG$ = val$
    EXIT FUNCTION
  END IF

  ' --- String field: \...\  (fixed width from backslash count) ---
  IF fc$ = "\" THEN
    ' Count chars between (and including) the two backslashes
    width% = 2
    FOR i% = 2 TO LEN(fmt$)
      IF MID$(fmt$, i%, 1) = "\" THEN EXIT FOR
      width% = width% + 1
    NEXT i%
    slen% = LEN(val$)
    IF slen% >= width% THEN
      USNG$ = LEFT$(val$, width%)        ' truncate if too long
    ELSE
      out$ = val$
      DO WHILE LEN(out$) < width%
        out$ = out$ + " "               ' right-pad with spaces
      LOOP
      USNG$ = out$
    END IF
    EXIT FUNCTION
  END IF

  ' ============================================================
  ' NUMERIC FIELD
  ' ============================================================

  numval! = VAL(val$)

  ' --- Scan format string for specials ---
  hasdot%    = 0 : dotpos%  = 0
  ldig%      = 0 : rdig%    = 0
  hasplus%   = 0 : hasminus% = 0
  hasstar%   = 0 : hasdollar% = 0
  hascomma%  = 0 : hasexp%  = 0
  lead$      = "" : trail$  = ""

  ' Handle leading ** **$ $$ prefix
  IF LEFT$(fmt$, 3) = "**$" THEN
    hasstar% = 1 : hasdollar% = 1
    fmt$ = RIGHT$(fmt$, LEN(fmt$) - 3)
  ELSEIF LEFT$(fmt$, 2) = "**" THEN
    hasstar% = 1
    fmt$ = RIGHT$(fmt$, LEN(fmt$) - 2)
  ELSEIF LEFT$(fmt$, 2) = "$$" THEN
    hasdollar% = 1
    fmt$ = RIGHT$(fmt$, LEN(fmt$) - 2)
  END IF

  ' Handle leading + sign
  IF LEFT$(fmt$, 1) = "+" THEN
    hasplus% = 1
    fmt$ = RIGHT$(fmt$, LEN(fmt$) - 1)
  END IF

  ' Check for trailing - sign
  IF RIGHT$(fmt$, 1) = "-" THEN
    hasminus% = 1
    fmt$ = LEFT$(fmt$, LEN(fmt$) - 1)
  END IF

  ' Check for trailing + sign
  IF RIGHT$(fmt$, 1) = "+" THEN
    hasplus% = 2                         ' 2 = trailing
    fmt$ = LEFT$(fmt$, LEN(fmt$) - 1)
  END IF

  ' Check for exponential ^^^^ at end
  IF RIGHT$(fmt$, 4) = "^^^^" THEN
    hasexp% = 1
    fmt$ = LEFT$(fmt$, LEN(fmt$) - 4)
  END IF

  ' Count # digits and find decimal point position
  FOR i% = 1 TO LEN(fmt$)
    fc$ = MID$(fmt$, i%, 1)
    IF fc$ = "." THEN
      hasdot% = 1 : dotpos% = i%
    ELSEIF fc$ = "#" THEN
      IF hasdot% = 0 THEN
        ldig% = ldig% + 1
      ELSE
        rdig% = rdig% + 1
      END IF
    ELSEIF fc$ = "," THEN
      IF hasdot% = 0 THEN hascomma% = 1
    END IF
  NEXT i%

  ' ** and $$ each add 2 to effective digit positions  
  IF hasstar% THEN ldig% = ldig% + 2
  IF hasdollar% AND NOT hasstar% THEN ldig% = ldig% + 2

  ' ---- Exponential format ----
  IF hasexp% THEN
    LOCAL exp%!, mant$
    IF numval! = 0 THEN
      exp% = 0
    ELSE
      exp% = INT(LOG(ABS(numval!)) / LOG(10))
    END IF
    tmp! = numval! / (10 ^ exp%)
    ' Round mantissa to rdig% decimal places
    IF rdig% > 0 THEN tmp! = INT(ABS(tmp!) * (10^rdig%) + 0.5) / (10^rdig%)
    mant$ = STR$(ABS(tmp!))
    IF INSTR(mant$, ".") = 0 THEN mant$ = mant$ + "."
    ' Pad fractional part
    LOCAL dotidx%
    dotidx% = INSTR(mant$, ".")
    DO WHILE LEN(mant$) - dotidx% < rdig%
      mant$ = mant$ + "0"
    LOOP
    ' Build exponent string
    LOCAL esgn$, estr$
    IF exp% >= 0 THEN esgn$ = "+" ELSE esgn$ = "-"
    estr$ = RIGHT$("0" + STR$(ABS(exp%)), 2)
    out$ = ""
    IF numval! < 0 THEN out$ = "-"
    out$ = out$ + mant$ + "E" + esgn$ + estr$
    IF hasplus% = 1 AND numval! >= 0 THEN out$ = "+" + out$
    IF hasplus% = 2 THEN
      IF numval! >= 0 THEN out$ = out$ + "+" ELSE out$ = out$ + "-"
    END IF
    USNG$ = out$
    EXIT FUNCTION
  END IF

  ' ---- Standard numeric ----

  ' Round to rdig% decimal places
  IF rdig% > 0 THEN
    numval! = INT(ABS(numval!) * (10^rdig%) + 0.5) / (10^rdig%)
  ELSE
    numval! = INT(ABS(numval!) + 0.5)
  END IF

  ' Integer part
  intpart& = INT(numval!)
  istr$ = STR$(intpart&)
  IF LEFT$(istr$, 1) = " " THEN istr$ = MID$(istr$, 2)  ' strip STR$ space

  ' Apply comma grouping if needed
  IF hascomma% AND LEN(istr$) > 3 THEN
    LOCAL tmp2$, k%
    tmp2$ = ""
    k% = 0
    FOR i% = LEN(istr$) TO 1 STEP -1
      k% = k% + 1
      tmp2$ = MID$(istr$, i%, 1) + tmp2$
      IF k% MOD 3 = 0 AND i% > 1 THEN tmp2$ = "," + tmp2$
    NEXT i%
    istr$ = tmp2$
  END IF

  ' Pad integer part to ldig% wide (with spaces or asterisks)
  ' Reserve 1 position for sign if +/- lead is needed
  LOCAL signwidth%
  signwidth% = 0
  IF hasplus% = 1 OR VAL(val$) < 0 THEN signwidth% = 1
  IF hasdollar% THEN signwidth% = signwidth% + 1

  DO WHILE LEN(istr$) < (ldig% - signwidth%)
    IF hasstar% THEN
      istr$ = "*" + istr$
    ELSE
      istr$ = " " + istr$
    END IF
  LOOP

  ' Build fractional string
  fstr$ = ""
  IF rdig% > 0 THEN
    tmp! = ABS(numval!) - INT(ABS(numval!))
    FOR j% = 1 TO rdig%
      tmp! = tmp! * 10
      digit% = INT(tmp! + 0.0000001)    ' guard float drift
      fstr$ = fstr$ + CHR$(48 + digit%)
      tmp! = tmp! - digit%
    NEXT j%
  END IF

  ' Assemble output
  out$ = ""

  ' Leading sign / dollar
  IF VAL(val$) < 0 THEN
    ' Replace leading space/asterisk with minus sign
    IF LEFT$(istr$, 1) = " " OR LEFT$(istr$, 1) = "*" THEN
      istr$ = "-" + MID$(istr$, 2)
    ELSE
      istr$ = "-" + istr$
    END IF
  ELSEIF hasplus% = 1 THEN
    IF LEFT$(istr$, 1) = " " OR LEFT$(istr$, 1) = "*" THEN
      istr$ = "+" + MID$(istr$, 2)
    ELSE
      istr$ = "+" + istr$
    END IF
  END IF

  ' Dollar sign just left of number
  IF hasdollar% THEN
    LOCAL dpos%
    dpos% = 1
    DO WHILE dpos% < LEN(istr$) AND (MID$(istr$, dpos%, 1) = " " OR MID$(istr$, dpos%, 1) = "*")
      dpos% = dpos% + 1
    LOOP
    istr$ = LEFT$(istr$, dpos% - 1) + "$" + MID$(istr$, dpos%)
  END IF

  out$ = istr$
  IF hasdot% THEN out$ = out$ + "."
  IF rdig% > 0 THEN out$ = out$ + fstr$

  ' Trailing sign
  IF hasminus% THEN
    IF VAL(val$) < 0 THEN out$ = out$ + "-" ELSE out$ = out$ + " "
  END IF
  IF hasplus% = 2 THEN
    IF VAL(val$) >= 0 THEN out$ = out$ + "+" ELSE out$ = out$ + "-"
  END IF

  ' Overflow check: number too wide for field?
  ' (ignore sign chars and separators when measuring)
  LOCAL numonly$
  numonly$ = ""
  FOR i% = 1 TO LEN(out$)
    fc$ = MID$(out$, i%, 1)
    IF fc$ >= "0" AND fc$ <= "9" THEN numonly$ = numonly$ + fc$
  NEXT i%
  IF LEN(numonly$) > (ldig% + rdig%) THEN out$ = "%" + out$

  USNG$ = out$
END FUNCTION
