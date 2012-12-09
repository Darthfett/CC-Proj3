PROGRAM Basic;

CLASS Basic
BEGIN

VAR abc, def, ghi : integer;
	pq, rs : boolean;

FUNCTION MersennePrimes;
BEGIN
	abc := 2 + 3 * 5 mod 7;
	def := abc + abc * abc mod abc;
	ghi := 3000 / 3;
	
	abc := 1;
	def := 2;
	
	pq := abc < ghi;
	rs := abc > ghi;
	pq := abc <= ghi;
	rs := abc >= ghi;
	pq := abc <> ghi;
	rs := abc = ghi
	
END

END
.
