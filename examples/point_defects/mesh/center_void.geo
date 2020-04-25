//+
Point(1) = {0, 0, 0, 1.0};
//+
Point(2) = {1, 0, 0, 1.0};
//+
Point(3) = {1, 1, 0, 1.0};
//+
Point(4) = {0, 1, 0, 1.0};
//+
Point(5) = {0.5, 0.4, 0, 1.0};
//+
Point(6) = {0.5, 0.5, 0, 1.0};
//+
Point(7) = {0.5, 0.6, 0, 1.0};
//+
Line(1) = {1, 2};
//+
Line(2) = {2, 3};
//+
Line(3) = {3, 4};
//+
Line(4) = {4, 1};
//+
Circle(5) = {5, 6, 7};
//+
Circle(6) = {7, 6, 5};
//+
Curve Loop(1) = {3, 4, 1, 2};
//+
Curve Loop(2) = {5, 6};
//+
Plane Surface(1) = {1, 2};
//+
Physical Curve(1) = {1};
//+
Physical Curve(2) = {1};
//+
Physical Curve(3) = {3};
//+
Physical Curve(4) = {4};
//+
Physical Curve(5) = {5, 6};
//+
Physical Surface(0) = {1};
//+
Transfinite Curve {6, 5} = 50 Using Progression 1;
