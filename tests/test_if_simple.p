PROGRAM Basic;

CLASS Basic
BEGIN

VAR a : integer;
    p, q : boolean;

FUNCTION MersennePrimes;
BEGIN
    a := 1;
    IF (a = 1) THEN
        a := 2
    ELSE
        a := 1
END

END
.
