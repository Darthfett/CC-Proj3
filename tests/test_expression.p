PROGRAM Basic;

CLASS Basic
BEGIN

VAR a, b, c : integer;
	p, q : boolean;

FUNCTION MersennePrimes;
BEGIN
	a = 2 + 3 * 5 mod 7;
	b = a + a * a mod a;
	c = 3000 / 3;
	
	a = 1;
	b = 2;
	
	p = a < c;
	q = a > c;
	p = a <= c;
	q = a >= c;
	p = a <> c;
	q = a == c
	
END

END
.