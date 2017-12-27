load ('TrainingSamplesDCT_8_new.mat')
%a)
n=1053+250;
C=[1053;250];

PYgrass=C(1)/n;
PYcheetah=C(2)/n;

%b)
mean0=mean(TrainsampleDCT_BG,1);
mean1=mean(TrainsampleDCT_FG,1);
cov0=cov(TrainsampleDCT_BG);
cov1=cov(TrainsampleDCT_FG);
var0=var(TrainsampleDCT_BG);
var1=var(TrainsampleDCT_FG);
% x=(-1:.01:1);
% y0=zeros(64,201);
% y1=zeros(64,201);
x=(-0.06:0.001:0.06);

%选择好的feature
% nump=[1,14,17,18,21,24,40,47];
% startp=[-1,-0.4,-0.3,-0.3,-0.2,-0.15,-0.1,-0.06];
% endp=[6,0.4,0.3,0.3,0.2,0.15,0.1,0.06];

%选择差的feature
% nump=[5,58,59,60,61,62,63,64];
% startp=[-0.7,-0.025,-0.02,-0.02,-0.02,-0.015,-0.015,-0.015];
% endp=[0.6,0.025,0.02,0.02,0.02,0.02,0.015,0.015,0.015];

%选择all feature
nump=[1,2:10,11:15,16:20,21:30,31:40,41:50,51:60,61:64];
startp=zeros(1,64);
startp(1)=-1;startp(2:10)=-0.7;startp(11:15)=-0.4;startp(16:20)=-0.3;
startp(21:30)=-0.2;startp(31:40)=-0.1;startp(41:50)=-0.1;startp(51:60)=-0.03;
startp(61:64)=-0.02;
endp(1)=6;endp(2:10)=0.7;endp(11:15)=0.4;endp(16:20)=0.3;
endp(21:30)=0.2;endp(31:40)=0.1;endp(41:50)=0.1;endp(51:60)=0.03;
endp(61:64)=0.02;


% 对应feature画图
figure;
for i=1:64
    x=(startp(i):(endp(i)-startp(i))/100:endp(i));
    y0=normpdf(x,mean0(nump(i)),sqrt(var0(nump(i))));
    y1=normpdf(x,mean1(nump(i)),sqrt(var1(nump(i))));
    subplot(8,8,i);
    plot(x,y0,'r',x,y1,'b');
    titletmp=sprintf(titlestring,nump(i));
    title(titletmp);
end





c)
算出255x270的图像每个pixel的1-64的dct值
pict=imread('cheetah.bmp');
pict=im2double(pict);
pictpad=zeros(300,300);
pictpad(1:255,1:270)=pict;
pict2vec=zeros(255,270);
zigzag=textread('Zig-Zag Pattern.txt','%u',-1)+1 ;

imgdct=zeros(255,270,64);
for i=1:255
    for j=1:270
        pictdct=dct2(pictpad(i:i+7,j:j+7));
        tmp8x8(zigzag)=pictdct';
        tmp1x64=reshape(tmp8x8,1,64);
        imgdct(i,j,:)=tmp1x64;
    end
end
save('imgdct.mat','imgdct')

load('imgdct.mat','imgdct');
imgdct8=zeros(255,270,8);mean08=zeros(1,8);mean18=zeros(1,8);
tmpTrain0=zeros(1053,8);tmpTrain1=zeros(250,8);
% nump=[1,14,17,18,21,24,40,47];
% nump=[1,2,3,4,36,45,47,50];
nump=[1,2,3,6,8,25,32,40];
for i=1:8
    imgdct8(:,:,i)=imgdct(:,:,nump(i));
    mean08(i)=mean0(nump(i));
    mean18(i)=mean1(nump(i));
    tmpTrain0(:,i)=TrainsampleDCT_BG(:,nump(i));
    tmpTrain1(:,i)=TrainsampleDCT_FG(:,nump(i));
end
cov08=cov(tmpTrain0);
cov18=cov(tmpTrain1);


img=zeros(255,270);
for i =1:248
    for j=1:262
%        p0=mvnpdf(reshape(imgdct8(i,j,:),[1 8]),mean08,cov08);
         p0=mvnpdf(reshape(imgdct(i,j,:),[1 64]),mean0,cov0);
%        p1=mvnpdf(reshape(imgdct8(i,j,:),[1 8]),mean18,cov18);
         p1=mvnpdf(reshape(imgdct(i,j,:),[1 64]),mean1,cov1);
        if PYcheetah*p1>p0*PYgrass
            img(i,j)=1;
        end
    end
end

imagesc(img)
colormap(gray(255))

picttest=imread('cheetah_mask.bmp');
grass2grass=0;
cheetah2cheetah=0;
cheetah2grass=0;
grass2cheetah=0;
for i=1:255
    for j=1:270
        if img(i,j)==0 && picttest(i,j)==0
            grass2grass=grass2grass+1;
        end
        if img(i,j)==0 && picttest(i,j)==255
            cheetah2grass=cheetah2grass+1;
        end
        if img(i,j)==1 && picttest(i,j)==0
            grass2cheetah=grass2cheetah+1;
        end
        if img(i,j)==1 && picttest(i,j)==255
            cheetah2cheetah=cheetah2cheetah+1;
        end
    end
end
N_all=255*270;
Ncheetah=sum(sum(picttest))/255;
Ngrass=N_all-Ncheetah;
%consider cheetah as positive, grass as negative
TruePositiveRate=cheetah2cheetah/Ncheetah;
TrueNegativeRate=grass2grass/Ngrass;

%Overall Accurate, without BDR into consideration P(error)
Accurate_All=1-(cheetah2cheetah+grass2grass)/N_all;
Accurate_All=Accurate_All*100;
%BDR Accurate, ∑ P(error|z)P(z)
Accurate_BDR=grass2cheetah/Ngrass*PYgrass + cheetah2grass/Ncheetah*PYcheetah;
Accurate_BDR=Accurate_BDR*100;  