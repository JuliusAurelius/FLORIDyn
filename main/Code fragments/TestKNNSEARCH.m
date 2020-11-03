OP.pos = rand(10,3);
search = rand(4,3);


[Idx,D] = knnsearch(OP.pos,search);

figure
hold on
scatter3(OP.pos(:,1),OP.pos(:,2),OP.pos(:,3))
scatter3(search(:,1),search(:,2),search(:,3),'filled')
quiver3(search(:,1),search(:,2),search(:,3),...
    OP.pos(Idx,1)-search(:,1),...
    OP.pos(Idx,2)-search(:,2),...
    OP.pos(Idx,3)-search(:,3))
hold off