load('TrainingSamplesDCT_8.mat');

[~,maxindex0(1:1053)]= max(TrainsampleDCT_BG,[],2);
%0->BG 1-1053
[~,maxindex1(1:250)]= max(TrainsampleDCT_FG,[],2);
%1->FG 1-250
for i=1:1053
    TrainsampleDCT_BG(i,maxindex0(i))=0;    
end
for i=1:250
    TrainsampleDCT_FG(i,maxindex1(i))=0;
end
[~,maxindex0(1:1053)]= max(TrainsampleDCT_BG,[],2);
maxindex0p(1:64)=1:64;maxindex0p(65:64+1053)=maxindex0(1:1053);
[~,maxindex1(1:250)]= max(TrainsampleDCT_FG,[],2);
maxindex1p(1:64)=1:64;maxindex1p(65:64+250)=maxindex1(1:250);

[times0p,~]=hist(maxindex0p,64);
times0=times0p-1;
[times1p,~]=hist(maxindex1p,64);
times1=times1p-1;

Pxy0=times0/1053;
Pxy1=times1/250;

subplot(2,1,1);
bar(1:64,times0(1:64));
title 'Grass-64'
subplot(2,1,2);
bar(1:64,times1(1:64));
title 'Cheetah-64'

len=1;

% mark=12;
BDR=zeros(1,64);
%  for i=mark:len:63
%      if times1(1+i/len)>times0(1+i/len)
%          BDR(i+1:i+len)=1;
%      end
%  end

 for i=1:64
     if times1p(i)>times0p(i)
         BDR(i)=1;
     end
  end
%BDR(14:30)=1;
save('BDR.mat','BDR');