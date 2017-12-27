load('BDR.mat','BDR');
pict=imread('cheetah.bmp');
pict=im2double(pict);
pictpad=zeros(300,300);
pictpad(1:255,1:270)=pict;
pict2vec=zeros(255,270);
zigzag=textread('Zig-Zag Pattern.txt','%u',-1)+1 ;
% 
% for i=1:255
%     for j=1:270
%         pictdct=abs(dct2(pictpad(i:i+7,j:j+7)));
%         tmp8x8(zigzag)=pictdct';
%         tmp1x64=reshape(tmp8x8,1,64);
%         [~,tmpmaxindex]=max(tmp1x64);
%         tmp1x64(tmpmaxindex)=0;
%         [~,tmpmaxindex]=max(tmp1x64);
%         pict2vec(i,j)=tmpmaxindex;
%     end
% end
% save('featurematrix.mat','pict2vec')


load('featurematrix.mat')
pict2vec(:,270)=pict2vec(:,269);
for i=1:255
    for j=1:270
        img(i,j)=BDR(pict2vec(i,j));
    end
end

img(1:255,1:4)=0;img(1:4,1:270)=0;img(251:255,1:270)=0;img(1:255,270)=0;

imagesc(img)
colormap(gray(255))

picttest=imread('cheetah_mask.bmp');
count=0;
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
