PROGRAM Test_while;

CLASS Test_while
BEGIN

VAR a, b : integer;
	p, q : boolean;

FUNCTION Test_while;
BEGIN
	a := 1;
	b := 1;

	WHILE (2 + 1 > a) THEN
	BEGIN
		a := a + 1;
		WHILE (b > 2 + 1)
		BEGIN
			b := b + 1
		END
	END
END
.