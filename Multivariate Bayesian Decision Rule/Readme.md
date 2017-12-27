
### Classify our cheetah example. Assume that the class-conditional densities are multivariate Gaussians of 64 dimensions.
---
#### a)  Compute the histogram estimate of the prior probility. Compute the maximum likelihood estimate for the prior probabilities. Compare the result with the estimates that you obtained last week.

* Using the histogram, I get the times that Cheetah and grass appears are 250 and 1053 respectively. Thus:
```math
P_Y (cheetah) = t(cheetah)/[t(cheetah)+t(grass)]

=250/(250+1053)

=19.19\%

P_Y (grass) = t(grass)/[t(cheetah)+t(grass)]

=1053/(250+1053)

=80.81\%
```

* Using the maximum likelihood, Prior Probability is equl to the times that it is observed divided by the total times of observations. And we find that within 1303 observations, there are 250 and 1053 observations for cheetah and grass respectively. Thus:

```math
P_Y (cheetah) = n(cheetah)/n(total)

=250/1303

=19.19\%

P_Y (grass) = n(grass)/n(total)

=1053/1303

=80.81\%
```

* Compare the result with the estimates that I obtained last week. 
* Explanation:
* The prior probabilities expresses one's beliefs about this quantity before some evidence is taken into account, which means that the best way to get it is to calculate the ratio between these classes. For this situation, we only get 1303 observations, and we should find the ratio using these input **(250:1053)**. Actually, the three methods are all doing the same stuff with this ratio. If the input is close to infinite, we will get the most precise prior probability, but the method should remain the same.

---
#### b) Compute the maximum likelihood estimates for the parameters of the class conditional densities. Select, by visual inspection, the best 8 and worst 8 features for classification purposes 
* To compute the maximum likelihood, we can rely on the function mean() and cov() of matlab.


```
mean0=mean(TrainsampleDCT_BG,1);
cov0=cov(TrainsampleDCT_BG);
```

**Means**

Class | 1|2|3|4|
---|---|---|---|---|
Cheetah |2.9153|-0.0037|0.0066|-0.0007|
Grass | 1.2814|0.0336|-0.0324|0.0171|

**Cov for grass:**

0.3198|0.0050|-0.0024|...
---|---|---|---
0.0050|0.0208|-0.0037|...
-0.0024|-0.0037|0.0308|...
...|...|...|...

**Cov for cheetah:**

0.1916|0.0267|-0.0259|...
---|---|---|---
0.0267|0.0474|-0.0104|...
-0.0259|-0.0104|0.0521|...
...|...|...|...

* Ploting the features and pick up. (Example code for feature 1 to 4)

```
x=(-1:.01:1);
for i=1:4
    y0=normpdf(x,mean0(i),sqrt(var0(i)));
    y1=normpdf(x,mean1(i),sqrt(var1(i)));
    subplot(2,2,i);
    plot(x,y0,'r',x,y1,'b');
end
```
* All 64 dimensions:
![image](http://note.youdao.com/yws/public/resource/1ba3fcc3afdc6b54fc36c98c8d56def0/xmlnote/D9E3C5B09D324F00AE91C4217D7E64D7/895)
* Select, by visual inspection, I found the best 8 features are **1,14,17,18,21,24,40,47**. As is shown below, they all show distinct variances *( Cheetah has clearly larger variance than Grass, and the peak of cheetah is much lower than Grass)*

![image](http://note.youdao.com/yws/public/resource/1ba3fcc3afdc6b54fc36c98c8d56def0/xmlnote/WEBRESOURCE2274ea2cc0a6589226a86fec7673bab2/830)

![image](http://note.youdao.com/yws/public/resource/1ba3fcc3afdc6b54fc36c98c8d56def0/xmlnote/WEBRESOURCE9b46659a2a39744af7ba33211670ccf1/832)

* Also,by visual inspection, I found the worst 8 features are **5,58,59,60,61,62,63,64**. As is shown below, they all show similar variances and means. *(There are large area of overlapping)*

![image](http://note.youdao.com/yws/public/resource/1ba3fcc3afdc6b54fc36c98c8d56def0/xmlnote/WEBRESOURCEe5e416e7c0e54c3afb220a60637dfafb/835)

![image](http://note.youdao.com/yws/public/resource/1ba3fcc3afdc6b54fc36c98c8d56def0/xmlnote/WEBRESOURCEe00941e26826d3a7f7fbcf5bd78665e6/837)

* Plus, with the help of programming, I found another best 8 features, which are **1,2,3,6,8,25,32,40**. I get them by maximizing the (mean0-mean1)/(sigma0-sigma1), and it ture out that it has **lower probability of error** in c)
---
#### c)Compute the Bayesian decision rule and classify the locations of the cheetah image using i) the 64-dimensional Gaussians, and ii) the 8-dimensional Gaussians associated with the best 8 features. Plot the classification masks and compute the probability of error

* To calculate the BDR, I use the matlab's mvnpdf function.
```
img=zeros(255,270);
for i =1:248
    for j=1:262
        p0=mvnpdf(reshape(imgdct8(i,j,:),[1 8]),mean08,cov08);
        p1=mvnpdf(reshape(imgdct8(i,j,:),[1 8]),mean18,cov18);
        
        if p1*PYcheetah>p0*PYgrass
            img(i,j)=1;
        end
    end
end
```
* For the probability of error, I calculate both the overall probabilty of error, which is P(error) and the BDR probability of accurate, which is the sum of P(error|z)P(z). Though these two are very similar, they are not the same.

```
%Counting Hit Point
for i=1:255
    for j=1:270
        if img(i,j)==0 && picttest(i,j)==0
            grass2grass=grass2grass+1;end
        if img(i,j)==0 && picttest(i,j)==255
            cheetah2grass=cheetah2grass+1;end
        if img(i,j)==1 && picttest(i,j)==0
            grass2cheetah=grass2cheetah+1;end
        if img(i,j)==1 && picttest(i,j)==255
            cheetah2cheetah=cheetah2cheetah+1;end
    end
end

%Counting basic numbers
N_all=255*270;
Ncheetah=sum(sum(picttest))/255;
Ngrass=N_all-Ncheetah;

%consider cheetah as positive, grass as negative
TruePositiveRate=cheetah2cheetah/Ncheetah;
TrueNegativeRate=grass2grass/Ngrass;

%Overall Accurate, without BDR into consideration P(error)
Accurate_All=1-(cheetah2cheetah+grass2grass)/N_all;
Accurate_All=Accurate_All*100;

%BDR Accurate, sum of P(error|z)P(z)
Accurate_BDR=grass2cheetah/Ngrass*PYgrass + cheetah2grass/Ncheetah*PYcheetah;
Accurate_BDR=Accurate_BDR*100;  


```


* For the Best 8 feature: **1,14,17,18,21,24,40,47**. The probability of BDR error is 5.4017%. 
The probability of overall error is 5.4016%. *(TPR and TNR are 90% and 96% respectively.)*


![image](http://note.youdao.com/yws/public/resource/1ba3fcc3afdc6b54fc36c98c8d56def0/xmlnote/WEBRESOURCE3d44c4c3b8b133e7d24c86cd11216e79/886)

* It is a good classifer because it excludes the wrong features, which is a kind of noise for classifer. *(The Gaussian distribution of two are similar )*. In another way, it can be treated it a like model that only gives weights to good features instead of bad features. In this way, this classifer is trained by out visually selection. So it performs better.
---
* For the 64-d feature, the probability of BDR error is 8.6420%. 
The probability of overall error is 8.6420%. *(TPR and TNR are 93% and 91% respectively.)* 


![image](http://note.youdao.com/yws/public/resource/1ba3fcc3afdc6b54fc36c98c8d56def0/xmlnote/WEBRESOURCE2c154d8e5283334f33de15af3aa9482d/888)

* It makes sense, since like I said, it is kind of model that is trained uniformly, giving every feature the same weight.
---
* Plus, for the *"Calculated"* Best 8 feature:**1,2,3,6,8,25,32,40**.
The probability of BDR error is 4.8149%. 
The probability of overall error is 4.8148%. *(TPR and TNR are 91% and 96% respectively.)*

![image](http://note.youdao.com/yws/public/resource/1ba3fcc3afdc6b54fc36c98c8d56def0/xmlnote/WEBRESOURCE5512b47b1ec6312ef996d810fca772d7/892)
