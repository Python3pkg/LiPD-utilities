function [L,E]=createEmptyLiPDGoogle1_2(dataSetName,nPDT,nCDT,nCol)
%creates a blank LiPD google file
E=readLiPD('Empty.lpd');

if nargin < 4
   nCol=5;
end
if nargin < 3
   nCDT=1;
end
if nargin < 2
   nPDT=1;
end
   
if nCol>2
for i=3:nCol
   E.paleoData{1}.paleoMeasurementTable{1}.(['dummy' num2str(i)])= E.paleoData{1}.paleoMeasurementTable{1}.dummy2;
   E.paleoData{1}.paleoMeasurementTable{1}.(['dummy' num2str(i)]).variableName=['dummy' num2str(i)];
      E.paleoData{1}.paleoMeasurementTable{1}.(['dummy' num2str(i)]).number=i;

end
if nCDT>0
    for i=1:nCol
    E.chronData{1}.chronMeasurementTable{1}.(['dummy' num2str(i)])= E.chronData{1}.chronMeasurementTable{1}.dummy2;
   E.chronData{1}.chronMeasurementTable{1}.(['dummy' num2str(i)]).variableName=['dummy' num2str(i)];
      E.chronData{1}.chronMeasurementTable{1}.(['dummy' num2str(i)]).number=i;

    end
else
   E=rmfield(E,'chronData');
end
end

%replicate for multiple PDTs
if nPDT>1
    for i=2:nPDT
    E.paleoData{i}= E.paleoData{1};
    end
end


%replicate for multiple CDTs
if nCDT>1
    for i=2:nCDT
     E.chronData{i}= E.chronData{1};
    end
end




% %create a new TSid
% 
% tsidCell=GetGoogleSpreadsheet('15IsdiTf790BRPXVL7GsW_j7wrQDHIEB9NmFI0lqqMuY');
% 
% %generate new random TSID
% stringHex = '01234567879abcdef';
% while 1
%     TSid = ['LPD' stringHex(ceil(rand(1, 8)*length(stringHex)))];
%     %make sure it doesn't exist
%     if ~any(strcmp(TSid,tsidCell(:,1)))
%         break
%     end
% end
% E.paleoData.data.EXAMPLE.TSid=TSid;%for first one

% %repeat for year
% while 1
%     TSid = ['LPD' stringHex(ceil(rand(1, 8)*length(stringHex)))];
%     %make sure it doesn't exist
%     if ~any(strcmp(TSid,tsidCell(:,1)))
%         break
%     end
% end
% E.paleoData.data.year.TSid=TSid;%for second one

%assign in the  name
E.dataSetName=dataSetName;

%write it to google
L=createLiPDGoogleFile(E,1);
end