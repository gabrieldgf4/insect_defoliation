
% Try to find the central line of a leaf
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano (BRAZIL) - 2022) 

function ref_line = find_ReferenceLine(leaf)

bw = logical(leaf(:,:,2));
bw = bwconvhull(bw);
e_bordas = bwmorph(bw, 'remove');

[rows, columns] = find(e_bordas);

xy = [rows, columns];
D = pdist(xy, 'euclidean');
Z = squareform(D);

[a, b] = find( Z == max(Z(:)), 1 );

p1 = xy( a, : );
p2 = xy( b, : );

ref_line = [ p1; p2 ];

% % show the central line
% e_bordas = imdilate(e_bordas, strel('disk', 5));
% e_bordas = insertShape(double(e_bordas),'line',...
%     [ ref_line(3), ref_line(1), ref_line(4), ref_line(2) ], 'LineWidth',5);
% figure; imshow(e_bordas); 

end