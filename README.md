# ProtectLeaf

It is a software for leaf analysis which provides estimation of defoliation level, detection and segmentation of insect bites, and leaf reconstruction.

# Citation

Original papers URL: 

[https://www.mdpi.com/2073-4395/12/11/2769/htm](https://www.mdpi.com/2073-4395/12/11/2769/htm)

[https://www.sciencedirect.com/science/article/pii/S2772375522000211](https://www.sciencedirect.com/science/article/pii/S2772375522000211)     

[https://ieeexplore.ieee.org/document/9529869](https://ieeexplore.ieee.org/document/9529869)

If you use this project, cite:

    @article{gabrielIPA2022,
        Author = Author={Vieira, Gabriel and 
                  Fonseca, Afonso and
                  Sousa, Naiane and
                  Ferreira, Julio and
                  Soares, Fabrizzio},
        Title = {An automatic method for estimating foliar defoliation with border damage},
        journal={Information Processing in Agriculture},
        volume={},
        pages={},
        doi={},
        url = {},
        year={2022}
    }

<img src="https://user-images.githubusercontent.com/63321757/180870855-387484c8-6edd-4c7c-9c76-83218c656767.png" width=75% height=75%>

# Code

You can download the code by:

    git clone https://github.com/gabrieldgf4/insect_defoliation.git
    cd insect_defoliation
    
    Then, open MATLAB and execute the file "test.m"

# Software outputs

    Damaged Leaf

<img src="https://user-images.githubusercontent.com/63321757/200846622-9bcec98a-d492-46f4-9aa2-199aa812bd50.png" width=15% height=15% >

    Defoliation Estimate

<img src="https://user-images.githubusercontent.com/63321757/200847581-664ac5a8-78cd-4f13-b744-eefec635e3c8.png" width=15% height=15%>

    Insect Predation

<img src="https://user-images.githubusercontent.com/63321757/200847847-f25890df-e14b-4f91-8327-3196c7d94885.png" width=15% height=15%>

    Leaf Contours

<img src="https://user-images.githubusercontent.com/63321757/200848370-486b5c77-a5b3-4fba-a911-3579085055ec.png" width=15% height=15%>

    Leaf Reconstruction

<img src="https://user-images.githubusercontent.com/63321757/200848642-edfe0a07-1124-4504-be69-2f1c1b4670cd.png" width=15% height=15%>

    Statistical Information
    
    #### DEFOLIATION ESTIMATE #### 
    Actual Damage (GT): 18.8709
    Defoliation Estimate (DE) Index: 20.5667
    Jaccard Index: 0.7397
    Dice Index: 0.8504

    #### INSECT PREDATION - BITE SEGMENTS #### 
    True positive bites: 3
    False positive bites: 0
    False negative bites: 0

    #### LEAF RECONSTRUCTION #### 
    SSSIM model (Leaf Model): 0.6902
    SSSIM model (Image Blending): 0.8440
    SSSIM model (Image Inpaint): 0.8309
    
