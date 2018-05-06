function [ Number ] = FindNumbers( snap,Counter )

%READNumber reads the character fromthe character's binary image.
%   Number=READNumber(SNAP) outputs the character in class 'char' from the
%   input binary image SNAP.
filename = sprintf('Snap%d.bmp', Counter);
load NumbersTemplate % Loads the templates of characters in the memory.
snap=imresize(snap,[42 24]); % Resize the input image so it can be compared with the template's images.
imwrite( snap , filename );
%figure,imshow(snap);
comp=[ ];
for n=1:length(NumbersTemplate)
    sem=corr2(NumbersTemplate{1,n},snap); % Correlation the input image with every image in the template for best matching.
    comp=[comp sem]; % Record the value of correlation for each template's character.
    %display(sem);
    
end
vd=find(comp==max(comp)); % Find the index which correspond to the highest matched character.
%display(max(comp));
%*------------------*--------------*--------------*------------------
%Accodrding to the index assign to 'Number'.
%number=[one 1 one1 2 one2  3 one3 4   one5 5 one6 6 two 8 three 9
%four 10 fourfill 11 five 12  six  13  sixfill 14 sixfill2 15
%six2 16 seven 17  eight 18 eightfill  19 eight2 20
%eight3 21 nine 22  ninefill 23 ninefill2 24  nine2 25];
%*------------------*--------------*--------------*------------------
%one 1 one1 2 one2  3 one3 4  one4 5 one5 6 one6 7
if length(vd)==3
    if vd==[76,97,98]
        Number='3';
    end
elseif or(or(or(or(or(or(or(or(vd==1, vd==2),vd==3),vd==4),vd==5),vd==6),vd==88) ,vd==87) ,vd==86)
    Number='1';
elseif vd==7%or(or(or(or(vd==12,vd==51),vd==52),vd==53),vd==54)
     Number='2';
elseif or(or(or(or(or(or(or(or(or(or(or(vd==8,vd==39),vd==40),vd==41),vd==42),vd==80),vd==81),vd==82),vd==90),vd==96),vd==97),vd==98)
    Number='3';
elseif or(or(vd==9,vd==10),vd==11)
    Number='4';
elseif or(or(or(or(or(or(or(or(or(vd==12,vd==36),vd==43),vd==44),vd==7),vd==51),vd==83),vd==92),vd==102),vd==76)
    K=imfill(snap,'holes')-snap;
        if K==0
         Number='5';
        else
          Number='6';
        end
%  elseif vd==87
%       Number='5';

elseif or(or(or(or(or(or(or(or(or(or(vd==13,vd==14),vd==15),vd==16),vd==31),vd==32),vd==77),vd==79),vd==89),vd==99),vd==101)
    Number='6';
elseif or(vd==17,vd==91)
    Number='7';
    %six2 16 seven 17  eight 18 eightfill  19 eight2 20
elseif or(or(or(or(or(or(or(or(or(or(or(or(or(vd==18,vd==19),vd==21),vd==27),vd==28),vd==29),vd==30),vd==35),vd==78),vd==20),vd==93),vd==94),vd==95),vd==100)
    Number='8';   
    %nine 22  ninefill 23 ninefill2 24  nine2 25
elseif or(or(or(or(or(or(or(or(vd==22,vd==23),vd==24),vd==25),vd==26),vd==33),vd==34),vd==84),vd==85)
    Number='9';
elseif or(or(or(or(or(vd==37,vd==38),vd==45),vd==46),vd==47),vd>=47)
    Number='0';
else
    Number='0';
end
end

