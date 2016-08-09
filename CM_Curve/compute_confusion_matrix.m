function [confusion_matrix]=compute_confusion_matrix(predict_label,num_in_class,name_class)
%  Matlab code for computing and visulization of confusion matrix for
%  multi-classification problem
%
%  Author£º Page( Ø§×Ó)
%           Blog: www.shamoxia.com;
%           QQ:379115886;
%           Email: peegeelee@gmail.com
%  Date:    Dec. 2010
%
num_class=length(num_in_class);

confusion_matrix=size(num_class,num_class);

for ci=1:num_class
    for cj=1:num_class
        c_start=sum(num_in_class(1:(ci-1)))+1;
        c_end=sum(num_in_class(1:ci));
        confusion_matrix(ci,cj)=size(find(predict_label(c_start:c_end)==cj),1)/num_in_class(ci);
    end
end

draw_cm(confusion_matrix,name_class,num_class);

end
