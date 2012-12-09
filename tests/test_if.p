PROGRAM Test_if;

CLASS Test_if
BEGIN

VAR a : integer;
	p, q : boolean;

FUNCTION Test_if;
BEGIN
	a := 1;
	IF (1 + 1 > a) THEN
		a := 2
	ELSE
		a := 3;
		
	IF (1 + 1 > a) THEN
		BEGIN
			a := 2;
			IF (a == 2) THEN
				a := 666
		END
	ELSE
		BEGIN
			a := 3;
			IF (a == 3) THEN
				a := 777;
		END
END

END
.