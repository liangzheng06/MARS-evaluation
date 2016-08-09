function [cmc] = compute_cmc(good_image, index)

cmc = zeros(length(index), 1);
pos = find(index == good_image);
cmc(pos:end) = 1;

end


