function [ap, CMC ] = calcmAP( M, data_test, data_query, label_query, label_gallery, cam_query, cam_gallery )

dist = sqdist(data_test, data_query, M);
CMC = zeros(size(dist, 2), size(dist, 1));
ap = zeros(size(dist, 2), 1);
junk0 = find(label_gallery == 0);
count = 0;
for k = 1:size(dist, 2)
    % find groudtruth index (good and junk)
    score = dist(:, k);
    q_label = label_query(k);
    q_cam = cam_query(k);
    pos = find(label_gallery == q_label);
    pos2 = cam_gallery(pos) ~= q_cam;
    good_image = pos(pos2);
    pos3 = cam_gallery(pos) == q_cam;
    junk = pos(pos3);
    junk_image = [junk0; junk];
    [~, index] = sort(score, 'ascend');
    if isempty(good_image)
        ap(k) = -1;
        CMC(k, :) = 0;
        count = count + 1;
    else
        [ap(k), CMC(k, :)] = compute_AP(good_image, junk_image, index);
    end
%     CMC(k, :) = compute_cmc(k, index);% see compute_AP
end
%% cmc and mAP
CMC = sum(CMC)./(size(dist, 2) - count);
% CMC = mean(CMC);

end

