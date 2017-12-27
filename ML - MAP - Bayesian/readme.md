## The Result Curve:
![strategy 1](http://upload-images.jianshu.io/upload_images/9147346-881b3b223a0c2fb2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![strategy 2](http://upload-images.jianshu.io/upload_images/9147346-cbe6f1448d3021af.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

---
## Explanation:
#### 1) the relative behavior of these three curves
* For constant error of ML solution: 
![theta_ML](http://upload-images.jianshu.io/upload_images/9147346-16a58c0fb865cd52.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
Since ML choose the theta only based on the dataset distribution, the theta for all alpha is the same. So the ML decision is invariant (error is constant ), and the curve of it is flat.

* For similarity between ML and MAP when alpha is large:
![theta_MAP](http://upload-images.jianshu.io/upload_images/9147346-7a357df9fb8a44a1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
At first, alpha is really small, we are quite certain about the parameters' distribution and MAP quite reflect it (our prior influences the result). However, as alpha increases, we are more uncertain about the prior. The influences from the prior decreases. Then MAP is mostly influences by the dataset distribution, which is close to ML *(completely based on the dataset distribution)*

* For changes on both MAP solution and Predictive equation:
As alpha increases, sigma0 increases, which means that we are more uncertain about the parameters' distribution. Therefore, information not captured by theta_ML appears to take effect. So, error begins to change when alpha changes. *( how it changes is shown in 2) and 3) )*
#### 2) how that behavior changes from dataset to dataset

* Trend:
For D1 to D4, the data size increases, while other parameters remain almost same. Thus, the trend should remain same *(if increases once, increase always)*. 

* Vast distance in D1 :
When data is limited, the error rate will be much larger than others. As is shown in the plot, error rate among D2,D3,D4 is similar, but the error rate in D1 is much larger. 
Besides, predictive equation performs obviously best in D1 for both strategy, because it can capture all the information in the dataset. But there is so limited data to use for ML and MAP that they work worse. *( in the dataset2 strategy1 the predictive equation performs a little worse, it is probably due to the existence of outlier)*

#### 3) how all of the above change when strategy 1 is replaced by strategy 2.
The most difference between strategy 1 and 2 is that strategy 1 offers a good prior, while the strategy 2 offers the bad one.  

* Trend:
The increase of alpha leads to less influence of the prior. Therefore, in strategy 1, the error rate decrease, since the good prior take less effect. In strategy 2, the error rate increases, since the bad prior take less effect.
* Start point:
For strategy 1, all MAP and Predictive equation start with low error rate, since they incorporate good prior, while for strategy 2 they starts with high error rate with bad prior.




