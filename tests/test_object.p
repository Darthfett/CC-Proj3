PROGRAM Test_object;

CLASS A
BEGIN
VAR a : integer;

FUNCTION A(aa : integer);
BEGIN
    a := aa
END

FUNCTION square : integer;
BEGIN
    square := a*a
END
END


CLASS B
BEGIN
VAR a : A;

FUNCTION B(aa : integer);
BEGIN
    a = NEW A(aa);
END
END


CLASS Test_object
BEGIN
VAR b : B;
    p, q : boolean;
FUNCTION Test_object;
BEGIN
	b = NEW B(6);
	b.a.a := b.a.square
END
END
.