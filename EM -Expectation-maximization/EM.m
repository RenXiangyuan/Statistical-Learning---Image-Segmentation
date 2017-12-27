thres=1;
c=8;%确定C的数目
timethres=5;

load('TrainingSamplesDCT_8_new.mat');

%导入预先数据
%算出255x270的图像每个pixel的1-64的dct值
pict=imread('cheetah.bmp');
pict=im2double(pict);
pictpad=zeros(300,300);
pictpad(1:255,1:270)=pict;
pict2vec=zeros(255,270);
zigzag=textread('Zig-Zag Pattern.txt','%u',-1)+1 ;

%导入mask
picttest=imread('cheetah_mask.bmp');

imgdct=zeros(255*270,64);
for i=1:255
    for j=1:270
        pictdct=dct2(pictpad(i:i+7,j:j+7));
        tmp8x8(zigzag)=pictdct';
        tmp1x64=reshape(tmp8x8,1,64);
        imgdct((i-1)*270+j,:)=tmp1x64;
    end
end









i_FGall=zeros(255*270,5*11);
i_BGall=zeros(255*270,5*11);
for times=1:timethres
for class=1:2
    if class==1
        X=TrainsampleDCT_FG;n_sample=250;end
    if class==2
        X=TrainsampleDCT_BG;n_sample=1053;end
    % π_c init
    pi_c_rand=[0,sort(rand(1,c-1)),1];  pi_c=zeros(1,c);
    for i=1:c
        pi_c(i)=pi_c_rand(i+1)-pi_c_rand(i);end
    %?怎么取random，均匀？多大？
    %μ_c init
    %rand('seed',times*10+class)
    mu_c=rand(c,64)*4;
    %∑_c init
    sigma_c=zeros(c,64,64);
    for i=1:c
        sigma_c(i,:,:)=(rand(1,64)*4+zeros(64,64)+8).*eye(64,64);end
    %reshape(sigma_c(i,:,:),64,64)

    inc=10000;L=0;iter=0;
    while abs(inc)>thres
        % h_ij 
        tmphij=zeros(n_sample,c);
        for j=1:c
            tmphij(:,j)=pi_c(j)*mvnpdf(X,mu_c(j,:),squeeze(sigma_c(j,:,:)));
        end
        hij=tmphij./sum(tmphij,2);

        for j=1:c

            pi_c(j)=sum(hij(:,j))/n_sample; %π
            tmpvar=zeros(64,64);%∑
            for i=1:n_sample
                tmpvar=tmpvar+hij(i,j)*(X(i,:)-mu_c(j,:))'*(X(i,:)-mu_c(j,:));
            end
            sigma_c(j,:,:)=tmpvar/sum(hij(:,j)).*eye(64,64) +0.0001*eye(64,64);
            
            mu_c(j,:)=sum(hij(:,j).*X,1)/sum(hij(:,j));%μ
        end
        Lold=L;
        L=0;
        for j=1:c
        L=L+sum(hij(:,j).*log( sum(mvnpdf(X,mu_c(j,:), squeeze(sigma_c(j,:,:)))) * pi_c(j)));
        end
        inc=L-Lold;
        iter=iter+1;
    end
    %%%%%%%%%%%%%%%%print%%%%%%%%%%
    iter
    if class==1
        tmpi=0;
        for d=[1,2,4,8,16,24,32,40,48,56,64]
            tmpi=tmpi+1;
        i_FGtmp=zeros(255*270,1);
        for j=1:c
            i_FGtmp=i_FGtmp+pi_c(j)*mvnpdf(imgdct(:,1:d),mu_c(j,1:d),squeeze(sigma_c(j,1:d,1:d)));end
        i_FGall(:,times*11-11+tmpi)=i_FGtmp;
        end
    end
    if class==2
        tmpi=0;
        for d=[1,2,4,8,16,24,32,40,48,56,64]
            tmpi=tmpi+1;
        i_BGtmp=zeros(255*270,1);
        for j=1:c
            i_BGtmp=i_BGtmp+pi_c(j)*mvnpdf(imgdct(:,1:d),mu_c(j,1:d),squeeze(sigma_c(j,1:d,1:d)));end
        i_BGall(:,times*11-11+tmpi)=i_BGtmp;
        end
    end
end
end

PY_FG=250/(250+1053); PY_BG=1053/(250+1053);





for timesFG=1:timethres
    Error_BDR=zeros(5,11);
for timesBG=1:timethres
    tmpi=0;
    for d=[1,2,4,8,16,24,32,40,48,56,64]
        tmpi=tmpi+1;
    i_BG=i_BGall(:,timesBG*11-11+tmpi);
    i_FG=i_FGall(:,timesFG*11-11+tmpi);
    imgpre=ones(255*270,1).*(i_FG*PY_FG>i_BG*PY_BG);

    for i=1:255
        imgpre((i-1)*270+260:(i-1)*270+270)=0;
    end
    for i=240:255
        imgpre(i*270:255*270)=0;
    end
    grass2grass=0;cheetah2cheetah=0;cheetah2grass=0;grass2cheetah=0;
    %img=zeros(255,270);
    for i=1:255
        for j=1:270
            if imgpre((i-1)*270+j)==0 && picttest(i,j)==0
                grass2grass=grass2grass+1;end
            if imgpre((i-1)*270+j)==0 && picttest(i,j)==255
                cheetah2grass=cheetah2grass+1;end
            if imgpre((i-1)*270+j)==1 && picttest(i,j)==0
                grass2cheetah=grass2cheetah+1;
                %img(i,j)=1;
            end
            if imgpre((i-1)*270+j)==1 && picttest(i,j)==255
                cheetah2cheetah=cheetah2cheetah+1;
                %img(i,j)=1;
            end
        end
    end
    %figure(timesFG*10+timesBG);
    %imagesc(img)
    %colormap(gray(255))
    N_all=255*270;Ncheetah=sum(sum(picttest))/255;Ngrass=N_all-Ncheetah;
    %tell=(grass2cheetah/Ngrass*PY_BG + cheetah2grass/Ncheetah*PY_FG) *100
    Error_BDR(timesBG,tmpi)=(grass2cheetah/Ngrass*PY_BG + cheetah2grass/Ncheetah*PY_FG) *100;
    end
end
figure(timesFG);
plot([1,2,4,8,16,24,32,40,48,56,64],Error_BDR(1,:),'r',...
[1,2,4,8,16,24,32,40,48,56,64],Error_BDR(2,:),'b',...
[1,2,4,8,16,24,32,40,48,56,64],Error_BDR(3,:),'g',...
[1,2,4,8,16,24,32,40,48,56,64],Error_BDR(4,:),'m',...
[1,2,4,8,16,24,32,40,48,56,64],Error_BDR(5,:),'k'...
);
legend('BG_1','BG_2','BG_3','BG_4','BG_5');
ylabel('BDR Error');xlabel('Dimension');
title(sprintf('FG initiated %d',timesFG));
end