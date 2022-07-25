function vc = restrict(v)
% A function to calculate the downsample of potential v.
% Author: Jialin Liu (liujl11@math.ucla.edu) Modified: 2018-10-10

Mx = size(v,1)-1;  My = size(v,2)-1;
Mxc = Mx/2; Myc = My/2;
vc = zeros(Mxc+1, Myc+1);

ind = 3:2:(Mx-1);  
vc(2:Mxc,2:Myc) = ( 4*v(ind,ind) + ...
                    2*(v(ind-1,ind)+v(ind+1,ind)+ ...
                       v(ind,ind-1)+v(ind,ind+1)) + ...
                      (v(ind-1,ind-1)+v(ind-1,ind+1)+ ...
                       v(ind+1,ind-1)+v(ind+1,ind+1)) )/16;
vc(1,2:Myc) = ( 4*v(1,ind) + 2*(v(2,ind)+ ...
                v(1,ind-1)+v(1,ind+1)) + ...
                (v(2,ind-1)+v(2,ind+1)) )/12;
vc(Mxc+1, 2:Myc) = ( 4*v(Mx+1,ind) + 2*(v(Mx,ind)+ ...
                       v(Mx+1,ind-1)+v(Mx+1,ind+1)) + ...
                      (v(Mx,ind-1)+v(Mx,ind+1)) )/12;
vc(2:Mxc, 1) = ( 4*v(ind,1) + ...
                    2*(v(ind-1,1)+v(ind+1,1)+ v(ind,2)) + ...
                      (v(ind-1,2)+ v(ind+1,2)) )/12;
vc(2:Mxc, Myc+1) = ( 4*v(ind,My+1) + ...
                    2*(v(ind-1,My+1)+v(ind+1,My+1)+ v(ind,My)) + ...
                      (v(ind-1,My)+ v(ind+1,My)) )/12;
vc(1,1) = ( 4*v(1,1) + 2*(v(2,1)+v(1,2)) + v(2,1) )/9;
vc(1,Myc+1) = ( 4*v(1,My+1) + 2*(v(2,My+1)+ v(1,My)) + v(2,My) )/9;
vc(Mxc+1,1) = ( 4*v(Mx+1,1) + 2*(v(Mx,1)+ v(Mx+1,2)) + v(Mx,2) )/9;
vc(Mxc+1,Myc+1) = ( 4*v(Mx+1,My+1) + ...
                    2*(v(Mx,My+1)+v(Mx+1,My)) + v(Mx,My) )/9;
end
