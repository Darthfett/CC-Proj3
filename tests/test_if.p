PROGRAM Basic;

CLASS Basic
BEGIN

VAR a : integer;
    p, q : boolean;

FUNCTION MersennePrimes;
BEGIN
    a := 1;
    IF (1 + 1 > a) THEN
        a := 2
    ELSE
        a := 3
    ;
            
    IF (1 + 1 > a) THEN
        BEGIN
            a := 2;
            IF (a = 2) THEN
                a := 666
            ELSE
                a := a
        END
    ELSE
        BEGIN
            a := 3;
            IF (a = 3) THEN
                a := 777
            ELSE
                a := a
        END
END

END
.
