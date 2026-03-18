' ============================================================
' DEMO / TEST - remove or comment out in production
' ============================================================
PRINT USNG$("###.##",   "1234.5")      ' Expected: %1234.50  (overflow)
PRINT USNG$("####.##",  "1234.5")      ' Expected:  1234.50
PRINT USNG$("####.##",  "-42.7")       ' Expected:   -42.70
PRINT USNG$("##.##",    ".78")         ' Expected:     0.78
PRINT USNG$("+###.##",  "-68.95")      ' Expected:  -68.95
PRINT USNG$("###.##-",  "-7.01")       ' Expected:     7.01-
PRINT USNG$("$$###.##", "456.78")      ' Expected:  $456.78
PRINT USNG$("**###.##", "2.34")        ' Expected:  ***2.34
PRINT USNG$("####,###.##", "1234567.89") ' Expected: 1,234,567.89 (overflow %)
PRINT USNG$("##.##^^^^", "234.56")     ' Expected:  2.35E+02
PRINT USNG$("!",         "HELLO")      ' Expected:  H
PRINT USNG$("&",         "WORLD")      ' Expected:  WORLD
PRINT USNG$("\   \",     "HELLO")      ' Expected:  HELLO  (5 chars)
PRINT USNG$("\  \",      "HI")         ' Expected:  HI   (4 chars, padded)
