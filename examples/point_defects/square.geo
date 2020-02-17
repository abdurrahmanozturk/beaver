// Gmsh project created on Mon Feb 17 10:48:18 2020
SetFactory("OpenCASCADE");
//+
Point(1) = {0, 0, 0, 1.0};
//+
Point(2) = {1, 0, 0, 1.0};
//+
Point(3) = {1, 1, 0, 1.0};
//+
Point(4) = {0, 1, 0, 1.0};
//+
Line(1) = {1, 2};
//+
Line(2) = {2, 3};
//+
Line(3) = {3, 4};
//+
Line(4) = {4, 1};
//+
Curve Loop(1) = {3, 4, 1, 2};
//+
Curve Loop(2) = {1, 2, 3, 4};
//+
Plane Surface(1) = {2};
//+
Disk(2) = {0.5, 0.5, 0, 0.1, 0.1};
//+
BooleanDifference{ Surface{1}; Delete; }{ Surface{2}; Delete; }
//+
Physical Surface("domain") = {1};
//+
//Physical Curve("outside") = {7, 9, 8, 6};
//+
Physical Curve("void") = {5};
//+
Physical Curve("left") = {7};
//+
Physical Curve("right") = {8};
//+
Physical Curve("top") = {9};
//+
Physical Curve("bottom") = {6};
