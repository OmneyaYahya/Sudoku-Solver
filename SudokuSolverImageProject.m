function [ NumbersMatrix ] = SudokuSolverImageProject( IM )
%This is the main Function of our project (take 'IM' is the image of sudoku
%and return 'NumbersMatrix' is a 2D matrix of numbers in the grid of sudoku
%and save the matrix in text file 'SudokuProblem.txt'

%IM=imread('3.1.jpg');


% 1.Filter from Noise then Binarize with adaptive threshold.
% Convert Matrix to Grayscale Image Still 3D Image.
%-----------------------------------------------------
  IM=mat2gray(IM);
%-----------------------------------------------------
%Filter Using Mean Filter (Memory Efficient).
% WS window size C Value.
%-----------------------------------------------------
  ws=25; C=0.05;
  mIM=imfilter(IM,fspecial('average',ws),'replicate');
  sIM=mIM-IM-C;
  FilteredImage=im2bw(sIM,0);
%-----------------------------------------------------
  % More enhancement
  background = imopen(FilteredImage,strel('disk',15));
  I2 = FilteredImage - background;
  binaryImage = imfill(I2, 'holes');
  %Grid with numbers (white background) also with some noise.
  B=binaryImage-I2;
%-----------------------------------------------------
% 2. Get Connected Component using area
%-----------------------------------------------------
  [labeledImage, numberOfBlobs] = bwlabel(binaryImage);
  blobMeasurements = regionprops(labeledImage, 'area', 'Centroid');
  % Get all the areas
  allAreas = [blobMeasurements.Area];
  % Sort The Areas in descend Order
  [sortedAreas, sortIndexes] = sort(allAreas, 'descend');
%-----------------------------------------------------
  % Finding the Grid
  % If there it's 9 Biggest areas that means the 9 blocks of sudoku grid
  % They are toghter the total grid.
  % Else only get the first big area assugmed to be the total grid.
%------------------------------------------------------
   if numberOfBlobs==9
       biggestBlob = ismember(labeledImage, sortIndexes(1:9));
   else
       biggestBlob = ismember(labeledImage, sortIndexes(1:1));
   end
%-----------------------------------------------------
   % Get the Rows and Columns of the white Pixels.
 [rows,cols] = find(biggestBlob==1);
 [Counter]=size(rows);
 biggestBlobWithoutGrid=biggestBlob;
 %Replacing the white pixels with grid contant from 
 %Original Filtered Image.
 %-----------------------------------------------------
  for i=1:Counter
      biggestBlob(rows(i),cols(i))=FilteredImage(rows(i),cols(i));
  end
%Display Only the grid with it's contant(Numbers).
figure,imshow(biggestBlob), title('Grid only from Original Image'); 
%-----------------------------------------------------
Iprops=regionprops(biggestBlob,'BoundingBox','Area', 'Image');
area = Iprops.Area;
% Find Index to get Bounding Box the of Largest Area.
MaxAreas=max(area);
Index=find(area==MaxAreas);
boundingBox=Iprops(Index).BoundingBox;
%all above step are to find location of number plate
CroppedImage = imcrop(biggestBlob, boundingBox);
CroppedImage = imresize(CroppedImage, [257 256]);
figure,imshow(CroppedImage);

%-----------------------------------------------------
%3.Finding the corners of the Croped Image(Only Grid).
%-----------------------------------------------------
[I,J]=find(CroppedImage>max(CroppedImage(:))/2);
    IJ=[I,J];  
    [~,idx]=min(IJ*[1 1; 1 -1; -1 1 ; -1 -1].');
    corners=IJ(idx,:);
%-----------------------------------------------------
% 4. Apply Transformation To correct the orientation 
% using cropped image Corners.
%-----------------------------------------------------
I=CroppedImage;
A=corners;
[h,w] = size(CroppedImage);
B = [0 0; 0 h;  w 0;  w h];
aff = cp2tform(A(1:4,:), [0 0; w 0;0 h; w h], 'affine');
A = tformfwd(aff, A);
B = tformfwd(aff, B);
% estimate homography between A and B
T = cp2tform(B, A, 'projective');
T = fliptform(T);
H = T.tdata.Tinv;
%disp(H);
TransformedImage = imtransform(I, T);
figure(2)
subplot(121), imshow(I), title('Cropped Grid Image');
subplot(122), imshow(TransformedImage), title('Warped Image');
% % Another Transformation
% % [ TransformationMatrix ] = GetTransformationMatrix(CroppedImage,corners );
% % Result = GeometricLinearTransform(CroppedImage,TransformationMatrix,corners);
% % Image=Result*255;
% % figure,imshow(Image);
[labeledIm, ~] = bwlabel(TransformedImage);
Iprops=regionprops(labeledIm,'BoundingBox','Area', 'Image');
AllAreas = Iprops.Area;

MaxArea=max(AllAreas);
Indx=find(AllAreas==MaxArea);
BoundingBox=Iprops(Indx).BoundingBox;

CroppedImageAfterTrans = imcrop(labeledIm, BoundingBox);
figure,imshow(CroppedImageAfterTrans), title('Cropped Image After Transformation');
%---------------------------------------------------------------
%5. Get Image Numbers Without Grid Borders
%---------------------------------------------------------------
[labeledCroppedImage, ~] = bwlabel(CroppedImageAfterTrans);
CroppedProps=regionprops(labeledCroppedImage,'all');
AllAreaz = [Iprops.Area]; 
[SortedAreas, SortIndexz] = sort(AllAreaz, 'descend');
count = numel(CroppedProps);
ImageContantWithoutGrid = ismember(labeledCroppedImage, SortIndexz(2:count));
figure,imshow(ImageContantWithoutGrid),title('Numbers Without Grid Borders');
[h, w] = size(ImageContantWithoutGrid);
windowsize = h/9;
%Indcies Used To Access Each Block From the Image.
FirstR=5;
FirstC=5;
LastC = w/9;
LastR=h/9;
Counter=1;
Position=[];
%Plate='';
noPlate=[]; % Initializing the variable of number plate string.
NumbersMatrix=zeros(9,9);
for i=1:9
    for j=1:9
     mstd = ImageContantWithoutGrid(FirstR:LastR,FirstC:LastC);%, counter1:Last);%, windowsize, 'Endpoints', 'discard'); 
     [labeledIm, NUM] = bwlabel(mstd);
%If Number of objects equal zero that means the block have not number.
     if NUM==0
         letter='0';
         R=(FirstR+LastR)/2;
         C=(FirstC+LastC)/2;
         Position=[Position; R C];
         noPlate=[noPlate letter];
%Else Get the Largest Area Object(Because if there is noise with the
%Object) Send Image of that object to Function FindNumbers To predict
%The number,Then add it to the NumbersMatrix(9*9).
     else
     Iprops=regionprops(mstd,'all');
     allArs = [Iprops.Area]; 
     [sortedAreas, sortIndexs] = sort(allArs, 'descend');
% Number Now Contains Largest Area which assugmend to be the Number.
     Number = ismember(labeledIm, sortIndexs(1:1));
     [labeledIm, ~] = bwlabel(Number);
     Iprop=regionprops(labeledIm,'all');
      %background = imopen(Iprop(1).Image,strel('square',2));%,strel('square',2));%Iprops(1).Image,strel('square',2));
       letter=FindNumbers(Iprop(1).Image,Counter); % Reading the letter corresponding the binary image 'N'.
       Counter=Counter+1;
       NumbersMatrix(i,j)=str2num(letter);
% Appending every subsequent character in noPlate variable.
       noPlate=[noPlate letter]; 
     end
     FirstC=windowsize+FirstC;
     if j==8
         LastC=w;
     else
     LastC=windowsize+LastC;
     end
         end
    FirstR=FirstR+windowsize ;
    %LastR=LastR+windowsize ;
    FirstC=5;
    LastC = h/9;
    if i==8
        LastR=h;
    else
    LastR=LastR+windowsize ;
    end

end
%Open File To Add The Sudoku Problem(Numbers) on it.
fid = fopen('SudokuProblem.txt','wt');
for ii = 1:size(NumbersMatrix,1)
    fprintf(fid,'%g ',NumbersMatrix(ii,:));
    fprintf(fid,'\n');
end
fclose(fid);

end

