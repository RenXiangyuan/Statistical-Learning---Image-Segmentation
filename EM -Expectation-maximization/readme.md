
### Use the cheetah image to evaluate the performance of a classifier based on mixture models estimated with EM
---
#### a)  For each class, learn 5 mixtures of C = 8 components, using a random initialization (recall that the mixture weights must add up to one). Plot the probability of error vs. dimension for each of the 25 classifiers obtained with all possible mixture pairs. Comment the dependence of the probability of error on the initialization.

* Initiate the μ (the mixture weights), to make them add up to one:

```matlab
pi_c_rand=[0,sort(rand(1,c-1)),1];  pi_c=zeros(1,c);
for i=1:c
        pi_c(i)=pi_c_rand(i+1)-pi_c_rand(i);end
```

* To plot different mixtures, I plot 5 different back ground mixture for each different foreground:

```matlab
figure(timesFG);
plot([1,2,4,8,16,24,32,40,48,56,64],Error_BDR(1,:),'r',...
[1,2,4,8,16,24,32,40,48,56,64],Error_BDR(2,:),'b',...
[1,2,4,8,16,24,32,40,48,56,64],Error_BDR(3,:),'g',...
[1,2,4,8,16,24,32,40,48,56,64],Error_BDR(4,:),'m',...
[1,2,4,8,16,24,32,40,48,56,64],Error_BDR(5,:),'k'...
);
```

* The result:
![FG-1.png](http://upload-images.jianshu.io/upload_images/9147346-0b733bb3d2d9957f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![FG-2.png](http://upload-images.jianshu.io/upload_images/9147346-e9df3902b5f00ff8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![FG-3.png](http://upload-images.jianshu.io/upload_images/9147346-2d12c193e7cc0a4e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![FG-4.png](http://upload-images.jianshu.io/upload_images/9147346-804ce188c22afe06.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![FG-5.png](http://upload-images.jianshu.io/upload_images/9147346-32b3c524d6e94a5b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

* Comment the dependence of the probability of error on the initialization:
&nbsp;&nbsp;&nbsp; For the different PoE range of each plot, we can find the different performances of each Foreground. We can tell that the FG-4 has the lowest PoE, indicating that it is the best Mixture for foreground, whose initiation leads to a better local minimum. Also, the FG-2 has the highest PoE, indicating that it is the worst Mixture for foreground, with a worse initiation and worse local minimum.
&nbsp;&nbsp;&nbsp; Within each plot, we can find the different performances of each background. The background 5 always has the highest PoE, indicating that it is the worst background Mixture, whose initiation leads to worst local minimum. Also background 4 has the second highest PoE. Besides, the background 3, 4, 5 has similar performance, the background 3 has the best performance on average, showing that it has the best initiation leading to the best local minimum.

---
#### b)  For each class, learn mixtures with C ∈ {1, 2, 4, 8, 16, 32}. Plot the probability of error vs. dimension for each number of mixture components. What is the effect of the number of mixture components on the probability of error?

* Here is the result:
![Components.png](http://upload-images.jianshu.io/upload_images/9147346-cbcfcdcef6fce6af.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

* The effect of the number of mixture components on the probability of error:
&nbsp;&nbsp;&nbsp; As is shown, c=1 will lead to the worst performance, which is reasonable, since it doesn't contain hidden variable (one fixed hidden state). Besides, as c increases, the performance improves, because there are more components for hidden variables. However, when c=32 the performance decreases, because actually there are not so many hidden states. Therefore, when c is more close to the proper number of hidden variables, the performance is more accurate.
&nbsp;&nbsp;&nbsp; For different components, PoE on different the dimensions is also different. On average, the best numbers of dimension to include is 30-50. It is obvious that more dimensions included will include more information. However, more dimensions are more than 50, there are only trivial information left, which is similar to over-fitting, lowering the performance.

