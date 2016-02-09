function new_proposals = generate_new_proposals(proposal_scores, all_proposals)

new_proposals = cell(1, length(all_proposals));

for i = 1:length(all_proposals)
   proposal_scores_i = cell2mat(proposal_scores(i,:));
   summing_along_rows = sum(proposal_scores_i, 2);
   [~, max_id] = max(summing_along_rows);
   
   new_proposals{i} = all_proposals{i}{max_id};
   
end

end