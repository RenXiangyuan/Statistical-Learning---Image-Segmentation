
### Segment the “cheetah” image  into its two components, cheetah (foreground) and grass (background)
---
#### a) Using the training data in TrainingSamplesDCT 8.mat, what are reasonable estimates for the prior probabilities?

* *The prior probabilities expresses one's beliefs about this quantity before some evidence is taken into account.*
* For this problem, prior probabilities represents the portion of how many times it shows.
* Thus:
```math
P_Y (cheetah) = n(cheetah)/[n(cheetah)+n(grass)]

=250/(250+1053)

=19.19\%

P_Y (grass) = n(grass)/[n(cheetah)+n(grass)]

=1053/(250+1053)

=80.81\%
```

---
#### b) Using the training data in TrainingSamplesDCT 8.mat, compute and plot the index histograms PX|Y (x|cheetah) and PX|Y (x|grass).
#### Taking **grass** *(BG)* for example:
* First, get X *(find the place of each block)*
```
[~,maxindex0(1:1053)]= max(TrainsampleDCT_BG,[],2);
for i=1:1053
    TrainsampleDCT_BG(i,maxindex0(i))=0;    
end
[~,maxindex0(1:1053)]= max(TrainsampleDCT_BG,[],2);
```

* Since there are too many 0s in the feature, I add 1 for each place of block, so every place has at least shown 1 time. 
* *(Otherwise, my Matlab outputs wrong histogram)*

```
maxindex0p(1:64)=1:64;
maxindex0p(65:64+1053)=maxindex0(1:1053);
```


* Using function hist() to store the value of X in vector **times0**. Minus 1 for each bin to get the correct value *(Add 1 before)*
```
[times0p,~]=hist(maxindex0p,64);
 times0=times0p-1;
```
* Then create the histogram we need:

```
subplot(2,1,1);
bar(1:64,times0(1:64));
title 'Grass-64'
```
![image](http://note.youdao.com/yws/public/resource/1ba3fcc3afdc6b54fc36c98c8d56def0/xmlnote/WEBRESOURCEff55b54adb82e75a547e85695c025f10/582)

* To get the conditional probability:

```
Pxy0=times0/1053;
Pxy1=times1/250;
```
* Vector Pxy0 annd Pxy1 store the conditional probability, here are some Results.

Class\Place | 2|3|4|5
---|---|---|---|---
Cheetah |0.156|0.176|0.04|0.052
Grass | 0.301|0.396|0.038|0.092


---
#### c) Compute the state variable Y using the minimum probability of error rule based on the probabilities obtained in a) and b). Store the state in an array A. Create a picture of that array.

* First, get the Bayes Rule for our decision by comparing posterior probability

```
BDR=zeros(1,64);
for i=1:64
     if times1p(i)>times0p(i)
         BDR(i)=1;
     end
end
```
*Second, read image and compute feature for each block using zigzag and dct2 *(use absolute value for DCT)*

```
%Reading
pict=imread('cheetah.bmp');
pict=im2double(pict);

%Padding
pictpad=zeros(300,300);
pictpad(1:255,1:270)=pict;

%Computing
for i=1:255
    for j=1:270
    %DCT
        pictdct=abs(dct2(pictpad(i:i+7,j:j+7)));
    %ZigZag
        tmp8x8(zigzag)=pictdct';
        tmp1x64=reshape(tmp8x8,1,64);
    %Second Max
        [~,tmpmaxindex]=max(tmp1x64);
        tmp1x64(tmpmaxindex)=0;
        [~,tmpmaxindex]=max(tmp1x64);
        pict2vec(i,j)=tmpmaxindex;
    end
end
```
* Finally, decide the prediction for each pixel according to its block, using BDR. Show the final image.

```
for i=1:255
    for j=1:270
        img(i,j)=BDR(pict2vec(i,j));
    end
end

imagesc(img)
colormap(gray(255))
```
![image](http://note.youdao.com/yws/public/resource/1ba3fcc3afdc6b54fc36c98c8d56def0/xmlnote/WEBRESOURCE779369730e6143774cdf7d1075761e56/632)

#### d) Compute the probability of error of your algorithm.

* The hit counts add 1 for each time: predictor and test are both zero or both positive.

```
for i=1:255
    for j=1:270
        if img(i,j)==0 && picttest(i,j)==0
            count=count+1;
        end
        if img(i,j)==1 && picttest(i,j)==255
            count=count+1;
        end
    end
end
100-count/255/270*100
```
* The final error rate is :
* 16.7756%
