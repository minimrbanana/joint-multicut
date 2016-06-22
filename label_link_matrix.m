function link_matrix = label_link_matrix(edges,labels_edges,num_node)
link_matrix = zeros(num_node);
for i  = 1: length(labels_edges)
    if labels_edges(i) ==1
        e_idx = edges(i,1) +1;
        s_idx = edges(i,2) +1;
        link_matrix(s_idx, e_idx) = 1;
    end
end
link_matrix = sparse(link_matrix);
end
