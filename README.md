# MARS-evaluation

This code provides evaluation procedure of the MARS dataset. Please kindly cite the Arxiv paper if you use this dataset.

Liang Zheng\*, Zhi Bie\*, Yifan Sun\*, Jingdong Wang, Chi Su, Shengjin Wang, Qi Tian, "MARS: A Video Benchmark for Large-Scale Person Re-identification", ECCV, 2016. (* equal contribution)

This code uses the 1024-dim IDE descriptor [1] and KISSME [2] and XQDA [3] distance metrics. 
To run this code, one should follow the three steps below.

1. Download the pre-computed IDE feature: http://pan.baidu.com/s/1mhBrwMG or https://drive.google.com/folderview?id=0B6tjyrV1YrHed3BnZnNaSUs3eEE&usp=sharing. Unzip it in the root folder.

2. Run "test_mars.m".

If you want to try your own descriptor or to learn new features, you should do as follows.

1. Download the dataset: http://pan.baidu.com/s/1hswMDfu or https://drive.google.com/folderview?id=0B6tjyrV1YrHeMVV2UFFXQld6X1E&usp=sharing. Training should be done with images in folder "bbox_train".

2. Bounding box feature extraction should follow the order specified in "root/info/test\_name.txt" and "root/info/train\_name.txt." The newly extracted feature should be loaded in line 19-20 in "root/test_mars.m"




If you have any suggestions or comments, please email me at liangzheng06@gmail.com




References

[1] L. Zheng et al. Person Re-identification in the Wild. Arxiv, 2016. 

[2] S. Liao et al. Person re-identification by local maximal occurrence representation and metric learning. CVPR 2015. 

[3] M. Kostinger et al. Large scale metric learning from equivalence constraints. CVPR 2012.
