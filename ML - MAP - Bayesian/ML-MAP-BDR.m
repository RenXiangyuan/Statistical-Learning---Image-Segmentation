load('TrainingSamplesDCT_subsets_8.mat');

load('Alpha.mat');

% FG-cheetah BG-grass

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

%μ0 mean of μ distribution
mu0_FG;%smaller for the (darker) cheetah class (μ0 = 1)
mu0_BG;%larger for the (lighter) grass class (μ0 = 3).

% Σ variance of X distribution
sigma_FG=zeros(4,64,64);
sigma_FG(1,:,:)=cov(D1_FG)*74/75;
sigma_FG(2,:,:)=cov(D2_FG)*124/125;
sigma_FG(3,:,:)=cov(D3_FG)*174/175;
sigma_FG(4,:,:)=cov(D4_FG)*224/225; %([cov(D1_FG)*74/75;cov(D2_FG)*124/125;cov(D3_FG)*174/175;cov(D4_FG)*224/225];

sigma_BG=zeros(4,64,64);
sigma_BG(1,:,:)=cov(D1_BG)*299/300;
sigma_BG(2,:,:)=cov(D2_BG)*499/500;
sigma_BG(3,:,:)=cov(D3_BG)*699/700;
sigma_BG(4,:,:)=cov(D4_BG)*899/900; %[cov(D1_BG)*299/300;cov(D2_BG)*499/500;cov(D3_BG)*699/700;cov(D4_BG)*899/900];

% μML 
muML_FG=[mean(D1_FG);mean(D2_FG);mean(D3_FG);mean(D4_FG)];
muML_BG=[mean(D1_BG);mean(D2_BG);mean(D3_BG);mean(D4_BG)];

PY_FG=[75/(75+300),125/(125+500),175/(175+700),225/(225+900)];
PY_BG=[300/(75+300),500/(125+500),700/(175+700),900/(225+900)];

nFG=[75,125,175,225];
nBG=[300,500,700,900];
for strategy=1:2
    if strategy==1
        load('Prior_1.mat');end
    if strategy==2
        load('Prior_2.mat');end
    for n_dataset=1:4
        Accurate_BDR=zeros(1,9);Accurate_ML=zeros(1,9);Accurate_MAP=zeros(1,9);
        for n_alpha=1:9
            sigma0=zeros(64,64);
            n_alpha;%1,2,3,4
            %Σ0 we assume a diagonal matrix with (Σ0)ii = αwi.
            %Σ0 variance of μ distribution both FG,BG
            for i=1:64
                sigma0(i,i)=alpha(n_alpha)*W0(i);   %alpha(n_alpha)
            end

            % Σ1
            sigma1_FG=inv( inv(sigma0) + nFG(n_dataset)*inv(reshape( sigma_FG(n_dataset,:),64,64)));
            sigma1_BG=inv( inv(sigma0) + nBG(n_dataset)*inv(reshape( sigma_BG(n_dataset,:),64,64)));

            % μ1 
            %mu1_FG= muML_FG(n_dataset,:)/( reshape(sigma_FG(n_dataset,:),64,64)/nFG(n_dataset)/sigma0+eye(64)) ...
            %        + mu0_FG/(nFG(n_dataset)*sigma0/reshape( sigma_FG(n_dataset,:),64,64 ) + eye(64) );
            %mu1_BG= muML_BG(n_dataset,:)/( reshape(sigma_BG(n_dataset,:),64,64)/nBG(n_dataset)/sigma0+eye(64))...
            %        + mu0_BG/(nBG(n_dataset)*sigma0/reshape( sigma_BG(n_dataset,:),64,64 )  + eye(64) );
            
            mu1_FG=(muML_FG(n_dataset,:)*nFG(n_dataset)*inv(reshape(sigma_FG(n_dataset,:),64,64))+mu0_FG*inv(sigma0))*sigma1_FG;
            mu1_BG=(muML_BG(n_dataset,:)*nBG(n_dataset)*inv(reshape(sigma_BG(n_dataset,:),64,64))+mu0_BG*inv(sigma0))*sigma1_BG;
            
            % x,mu1_FG,sigma_FG+sigma1_FG


            i_FG=mvnpdf(imgdct,mu1_FG,reshape( sigma_FG(n_dataset,:),64,64 )+sigma1_FG);
            i_BG=mvnpdf(imgdct,mu1_BG,reshape( sigma_BG(n_dataset,:),64,64)+sigma1_BG);

            iML_FG=mvnpdf(imgdct,muML_FG(n_dataset,:),reshape( sigma_FG(n_dataset,:,:),64,64 ));
            iML_BG=mvnpdf(imgdct,muML_BG(n_dataset,:),reshape( sigma_BG(n_dataset,:,:),64,64 ));

            iMAP_FG=mvnpdf(imgdct,mu1_FG,reshape( sigma_FG(n_dataset,:),64,64 ));
            iMAP_BG=mvnpdf(imgdct,mu1_BG,reshape( sigma_BG(n_dataset,:),64,64));

            imgpre=zeros(255*270,1);imgmlpre=zeros(255*270,1);imappre=zeros(255*270,1);
            for i=1:255*250

                if i_FG(i)*PY_FG(n_dataset)>i_BG(i)*PY_BG(n_dataset)
                    imgpre(i)=1;
                end
                if iML_FG(i)*PY_FG(n_dataset)>iML_BG(i)*PY_BG(n_dataset)
                    imgmlpre(i)=1;
                end
                if iMAP_FG(i)*PY_FG(n_dataset)>iML_BG(i)*PY_BG(n_dataset)
                    imappre(i)=1;
                end
            end
            for i=1:255
                imgpre((i-1)*270+250:(i-1)*270+270)=0;imgmlpre((i-1)*270+250:(i-1)*270+270)=0;imappre((i-1)*270+250:(i-1)*270+270)=0;
            end
            
            grass2grass=0;g2gml=0;g2gmap=0;
            cheetah2cheetah=0;c2cml=0;c2cmap=0;
            cheetah2grass=0;c2gml=0;c2gmap=0;
            grass2cheetah=0;g2cml=0;g2cmap=0;
            for i=1:255
                for j=1:270
                    %
                    if imgpre((i-1)*270+j)==0 && picttest(i,j)==0
                        grass2grass=grass2grass+1;end
                    if imgmlpre((i-1)*270+j)==0 && picttest(i,j)==0
                        g2gml=g2gml+1;end
                    if imappre((i-1)*270+j)==0 && picttest(i,j)==0
                        g2gmap=g2gmap+1;end

                    %
                    if imgpre((i-1)*270+j)==0 && picttest(i,j)==255
                        cheetah2grass=cheetah2grass+1;end
                    if imgmlpre((i-1)*270+j)==0 && picttest(i,j)==255
                        c2gml=c2gml+1;end
                    if imappre((i-1)*270+j)==0 && picttest(i,j)==255
                        c2gmap=c2gmap+1;end

                    %
                    if imgpre((i-1)*270+j)==1 && picttest(i,j)==0
                        grass2cheetah=grass2cheetah+1;end
                    if imgmlpre((i-1)*270+j)==1 && picttest(i,j)==0
                        g2cml=g2cml+1;end
                    if imappre((i-1)*270+j)==1 && picttest(i,j)==0
                        g2cmap=g2cmap+1;end

                    %
                    if imgpre((i-1)*270+j)==1 && picttest(i,j)==255
                        cheetah2cheetah=cheetah2cheetah+1;end
                    if imgmlpre((i-1)*270+j)==1 && picttest(i,j)==255
                        c2cml=c2cml+1;end
                    if imappre((i-1)*270+j)==1 && picttest(i,j)==255
                        c2cmap=c2cmap+1;end
                end
            end
            N_all=255*270;
            Ncheetah=sum(sum(picttest))/255;
            Ngrass=N_all-Ncheetah;

            %Overall Accurate, without BDR into consideration P(error)
            %Accurate_All=1-(cheetah2cheetah+grass2grass)/N_all;
            %Accurate_All=Accurate_All*100

            %BDR Accurate, ∑ P(error|z)P(z)
            Accurate_BDR(n_alpha)=(grass2cheetah/Ngrass*PY_BG(n_dataset) + cheetah2grass/Ncheetah*PY_FG(n_dataset)) *100;
            Accurate_ML(n_alpha)=(g2cml/Ngrass*PY_BG(n_dataset)+c2gml/Ncheetah*PY_FG(n_dataset)) *100;
            Accurate_MAP(n_alpha)=(g2cmap/Ngrass*PY_BG(n_dataset)+c2gmap/Ncheetah*PY_FG(n_dataset))*100;
        end

        figure(strategy);
        subplot(2,2,n_dataset);% (strategy*4-4)+
        plot(alpha,Accurate_BDR,'r',alpha,Accurate_ML,'b',alpha,Accurate_MAP,'g');
        legend('solution based on the predictive equation','ML solution','MAP solution');
        set(gca, 'XScale', 'log');
        ylabel('BDR Error');
        title(sprintf('Strategy%d，Dataset%d',strategy,n_dataset));
    end
end