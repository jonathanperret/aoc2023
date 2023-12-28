include<day24.scad>

module dot(){cube(2,center=true);}
len=1;

p1=[+406.22654861265,+249.663107713011,+205.09292626108999];
v1=[-68,+327,-148];
t1=0.075777689017;
p2=[+23.266736725159,+167.214437607609,+280.252910405315];
v2=[+125,+118,+132];
t2=1.030012709502;

bottom = p1+t1*v1;
top = p2+t2*v2;

union() {
    color("white")
    union() {
    lines();
    }

    s=1;

*    color("blue", alpha=0.5)
    hull() {
        translate(bottom - (top-bottom))
        scale(s)dot();
        translate(top - (bottom-top))
        scale(s)dot();
    }
}


*union() {
    color("green")
    translate(p1) hull() { dot(); translate( t1*v1) dot(); }

    color("red")
    translate(p2) hull() { dot(); translate(t2*v2) dot(); }
}