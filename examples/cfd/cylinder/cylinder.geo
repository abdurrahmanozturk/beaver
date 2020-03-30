//+
Point(1) = {0, 0, 0, 1.0};
//+
Point(2) = {50, 0, 0, 1.0};
//+
Point(3) = {50, 10, 0, 1.0};
//+
Point(4) = {50, 20, 0, 1.0};
//+
Point(5) = {0, 20, 0, 1.0};
//+
Point(6) = {10, 7.5, 0, 1.0};
//+
Point(7) = {10, 10, 0, 1.0};
//+
Point(8) = {10, 12.5, 0, 1.0};
//+
Line(1) = {1, 2};
//+
Line(2) = {2, 3};
//+
Line(3) = {3, 4};
//+
Line(4) = {4, 5};
//+
Line(5) = {5, 1};
//+
Circle(6) = {6, 7, 8};
//+
Circle(7) = {8, 7, 6};
//+
Curve Loop(1) = {4, 5, 1, 2, 3};
//+
Curve Loop(2) = {6, 7};
//+
Plane Surface(1) = {1, 2};
//+
Physical Surface("domain") = {1};
//+
Physical Curve("left") = {5};
//+
Physical Curve("top") = {4};
//+
Physical Curve("right") = {3, 2};
//+
Physical Curve("bottom") = {1};
//+
Physical Curve("wall") = {6, 7};
//+
Transfinite Curve {4, 1} = 75 Using Progression 1;
//+
Transfinite Curve {2, 3} = 15 Using Progression 1;
//+
Transfinite Curve {5} = 30 Using Progression 1;
//+
Transfinite Curve {6, 7} = 100 Using Progression 1;
