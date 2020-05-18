// Gmsh project created on Mon Feb 17 10:48:18 2020
SetFactory("OpenCASCADE");
//+
Point(1) = {0, 0, 0, 1.0};
//+
Point(2) = {256, 0, 0, 1.0};
//+
Point(3) = {256, 256, 0, 1.0};
//+
Point(4) = {0, 256, 0, 1.0};
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
Disk(2) = {128, 128, 0, 25.6, 25.6};
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
//+
Transfinite Curve {5} = 10 Using Progression 1;
//+
Transfinite Curve {5} = 100 Using Progression 1;
//+
Transfinite Curve {5} = 50 Using Progression 1;
//+
Transfinite Curve {5} = 25 Using Progression 1;
//+
Transfinite Curve {9, 7, 8, 6} = 10 Using Progression 1;
//+
Transfinite Curve {9, 7, 8, 6} = 20 Using Progression 1;
//+
Transfinite Curve {5} = 50 Using Progression 1;
//+
Transfinite Curve {9, 7, 8, 6} = 25 Using Progression 1;
//+
Transfinite Curve {5} = 75 Using Progression 1;
