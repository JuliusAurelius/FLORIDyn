col = sqrt(sum(OP.u(narc_height,:).^2,2));
smol = col<7.9;
sliceOP = OP_pos_old(narc_height,1:2);
[v_vor,c_vor] = voronoin(OP_pos_old(narc_height,1:2));

figure
hold on
for ii=1:length(c_vor)
    if smol(ii)
        patch('Faces',c_vor{ii},...
            'Vertices',v_vor,...
            'FaceVertexCData',col(ii),...
            'FaceColor','flat',...
            'EdgeColor','none');
    end
end
colorbar
hold off

%% Issues:
%   creates patches of huge size.
%   Solution: filter out patches with out-of-field coordinates
% ----------
%   With deplaced turbines, there will be large patches which don't belong
%   there - connecting wakes / turbines etc. -> will lead to issues.