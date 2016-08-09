%% test MARS
% We provide the train/test codes for the MARS dataset described in:
% Liang Zheng et al, MARS: A Video Benchmark for Large-Scale Person
% Re-identification, ECCV 2016.
% Plese kindly cite this paper if you use MARS in your research.

%% load data
addpath 'utils/'
addpath 'LOMO_XQDA/code'
addpath 'CM_Curve/' % draw confusion matrix
run('KISSME/init.m');

track_train = importdata('info/tracks_train_info.mat');
track_test = importdata('info/tracks_test_info.mat');

% replace your frame features here, according to train_name.txt and
% test_name.txt
% feature_train.mat and feature_test_mat can be downloaded on my webpage.
box_feature_train = importdata('ide_feat_train.mat'); % 1024*509914
box_feature_test = importdata('ide_feat_test.mat'); % 1024*681089

% replace your video features here.
video_feat_train = process_box_feat(box_feature_train, track_train); % pooled video features for train
video_feat_test = process_box_feat(box_feature_test, track_test); % video video features for test (gallery+query)

query_IDX = importdata('info/query_IDX.mat');  % load pre-defined query index

% train, gallery, and query labels
label_train = track_train(:, 3);
label_gallery = track_test(:, 3);
label_query = label_gallery(query_IDX);
cam_train = track_train(:, 4);
cam_gallery = track_test(:, 4);
cam_query = cam_gallery(query_IDX);
feat_gallery = video_feat_test;
feat_query = video_feat_test(:, query_IDX);

%% train and test XQDA
[train_sample1, train_sample2, label1, label2] = gen_train_sample_xqda(label_train, cam_train, video_feat_train); % generate pairwise training features for XQDA
[W, M_xqda] = XQDA(train_sample1, train_sample2, label1, label2);% train XQDA
dist_xqda = MahDist(M_xqda, feat_gallery' * W, feat_query' * W); % calculate MahDist between query and gallery boxes with learnt subspace. Smaller distance means larger similarity
[CMC_xqda, map_xqda, r1_pairwise, ap_pairwise] = evaluation_mars(dist_xqda, label_gallery, label_query, cam_gallery, cam_query);
[ap_CM, r1_CM] = draw_confusion_matrix(ap_pairwise, r1_pairwise, cam_query);
fprintf('average of confusion matrix for XQDA:  mAP = %f, r1 precision = %f\r\n', (sum(ap_CM(:))-sum(diag(ap_CM)))/30, (sum(r1_CM(:))-sum(diag(r1_CM)))/30);

%% train and test of kissme, Mahalanobis and Euclidean distance
params.numCoeffs = 200; %dimensionality reduction by PCA to 200 dimension
[idxa,idxb,flag] = gen_train_sample_kissme(label_train, cam_train); % generate pairwise training features for kissme

pair_metric_learn_algs = {...
    LearnAlgoKISSME(params), ...
    LearnAlgoMahal(), ...
    LearnAlgoMLEuclidean()
    };

% dimension reduction by PCA
[ux_train,u,m] = applypca2(video_feat_train);
ux_gallery = u'*(feat_gallery-repmat(m,1,size(feat_gallery,2)));
ux_query = u'*(feat_query-repmat(m,1,size(feat_query,2)));
ux_train = ux_train(1:params.numCoeffs,:);
ux_gallery = ux_gallery(1:params.numCoeffs,:);
ux_query = ux_query(1:params.numCoeffs,:);

% Metric learning
[M_kissme, M_mahal, M_eu] = KISSME(pair_metric_learn_algs, ux_train, ux_gallery, ux_query, idxa, idxb, flag);

% Calculate distance
dist_kissme = MahDist(M_kissme, ux_gallery', ux_query');
dist_mahal = MahDist(M_mahal, ux_gallery', ux_query');
dist_eu = MahDist(M_eu, ux_gallery', ux_query');

% Calcuate CMC and mAP
[CMC_kissme, map_kissme, r1_pairwise, ap_pairwise] = evaluation_mars(dist_kissme, label_gallery, label_query, cam_gallery, cam_query);
[ap_CM, r1_CM] = draw_confusion_matrix(ap_pairwise, r1_pairwise, cam_query);
fprintf('average of confusion matrix for KISSME:  mAP = %f, r1 precision = %f\r\n', (sum(ap_CM(:))-sum(diag(ap_CM)))/30, (sum(r1_CM(:))-sum(diag(r1_CM)))/30);

[CMC_mahal, map_mahal, r1_pairwise, ap_pairwise] = evaluation_mars(dist_mahal, label_gallery, label_query, cam_gallery, cam_query);
[ap_CM, r1_CM] = draw_confusion_matrix(ap_pairwise, r1_pairwise, cam_query);
fprintf('average of confusion matrix for Mahalanobis distance:  mAP = %f, r1 precision = %f\r\n', (sum(ap_CM(:))-sum(diag(ap_CM)))/30, (sum(r1_CM(:))-sum(diag(r1_CM)))/30);

[CMC_eu, map_eu, r1_pairwise, ap_pairwise] = evaluation_mars(dist_eu, label_gallery, label_query, cam_gallery, cam_query);
[ap_CM, r1_CM] = draw_confusion_matrix(ap_pairwise, r1_pairwise, cam_query);
fprintf('average of confusion matrix for Euclidean distance:  mAP = %f, r1 precision = %f\r\n', (sum(ap_CM(:))-sum(diag(ap_CM)))/30, (sum(r1_CM(:))-sum(diag(r1_CM)))/30);

%% Draw Curves
CMC = [CMC_xqda; CMC_kissme; CMC_mahal; CMC_eu];
mAP = [map_xqda, map_kissme, map_mahal, map_eu];
s = 50;
plot1 = plot(1:s, CMC(:, 1:s));
set(plot1(1),'DisplayName', sprintf('XQDA, mAP = %0.4f', map_xqda));
set(plot1(2),'DisplayName', sprintf('KISSME, mAP = %0.4f', map_kissme));
set(plot1(3),'DisplayName', sprintf('Mahalanobis distance, mAP = %0.4f', map_mahal));
set(plot1(4),'DisplayName', sprintf('Euclidean distance, mAP = %0.4f', map_eu));
legend(sprintf('XQDA, mAP = %0.4f', map_xqda), sprintf('KISSME, mAP = %0.4f', map_kissme),...
    sprintf('Mahalanobis distance, mAP = %0.4f', map_mahal), sprintf('Euclidean distance, mAP = %0.4f', map_eu));


