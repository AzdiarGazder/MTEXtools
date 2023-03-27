function outebsd = erode(inebsd,ingrain)
%% Function description:
% Erodes the ebsd data surrounding individual grains of interest by one
% pixel.
%
%% Note to users:
% Requires the pad.m function to run.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgments:
% The original image erosion algorithm by Aaron Angel can be found at:
% https://www.imageeprocessing.com/2012/09/image-erosion-without-using-matlab.html
%
%% Syntax:
%  [ebsd] = erode(ebsd,grain)
%
%% Input:
%  ebsd        - @EBSD
%  grain       - @grain2d
%
%% Output:
%  ebsd        - @EBSD
%%

% check for input variables contents
if isempty(inebsd) || isempty(ingrain)
    return;
end

% check for input variable types
if ~isa(inebsd,'EBSD')
    error('First input must be an EBSD variable.');
    return;
end

if ~isa(ingrain,'grain2d')
    error('Second input must be a grain2d variable.');
    return;
end


% calculate the ebsd map step size
xx = [inebsd.unitCell(:,1);inebsd.unitCell(1,1)]; % repeat the 1st x co-ordinate to close the unit pixel shape
yy = [inebsd.unitCell(:,2);inebsd.unitCell(1,2)]; % repeat the 1st y co-ordinate to close the unit pixel shape
unitPixelArea = polyarea(xx,yy);
if size(inebsd.unitCell,1) == 6 % hexGrid
    stepSize = sqrt(unitPixelArea/sind(60));
else % squareGrid
    stepSize = sqrt(unitPixelArea);
end

% gridify the ebsd map data
gebsd = gridify(inebsd);
xMap = stepSize.*floor(gebsd.prop.x./stepSize);
yMap = stepSize.*floor(gebsd.prop.y./stepSize);

% gridify the ebsd data of the grain of interest
ggrain = gridify(gebsd(ingrain));
xGrain = stepSize.*floor(ggrain.prop.x./stepSize);
yGrain = stepSize.*floor(ggrain.prop.y./stepSize);

% create a gridded map using any grain of interest property
if any(ismember(fields(ggrain.prop),'imagequality'))
    grainMap = ggrain.prop.imagequality;
elseif any(ismember(fields(ggrain.prop),'iq'))
    grainMap = ggrain.prop.iq;
elseif any(ismember(fields(ggrain.prop),'bandcontrast'))
    grainMap = ggrain.prop.bandcontrast;
elseif any(ismember(fields(ggrain.prop),'bc'))
    grainMap = ggrain.prop.bc;
elseif any(ismember(fields(ggrain.prop),'bandslope'))
    grainMap = ggrain.prop.bandslope;
elseif any(ismember(fields(ggrain.prop),'bs'))
    grainMap = ggrain.prop.bs;
elseif any(ismember(fields(ggrain.prop),'oldId'))
    grainMap = ggrain.prop.oldId;
elseif any(ismember(fields(ggrain.prop),'grainId'))
    grainMap = ggrain.prop.grainId;
elseif any(ismember(fields(ggrain.prop),'confidenceindex'))
    grainMap = ggrain.prop.confidenceindex;
elseif any(ismember(fields(ggrain.prop),'ci'))
    grainMap = ggrain.prop.ci;
elseif any(ismember(fields(ggrain.prop),'fit'))
    grainMap = ggrain.prop.fit;
elseif any(ismember(fields(ggrain.prop),'semsignal'))
    grainMap = ggrain.prop.semsignal;
elseif any(ismember(fields(ggrain.prop),'mad'))
    grainMap = ggrain.prop.mad;
elseif any(ismember(fields(ggrain.prop),'error'))
    grainMap = ggrain.prop.error;
end

% replace NaNs with 0s in the grainMap
% now the grainMap comprises the grain property values surrounded by 0
grainMap(isnan(grainMap)) =  0;
% replace grain property values with 1s in the grainMap
% now the grainMap becomes a binary map
grainMap(grainMap > 0) =  1;

% pad the grainMap with ones on the two left and right -sides
padMap = pad(grainMap,[0 1],'ones');
% figure; imagesc(padMap)

% define a structuring element array for erosion
strucElement = [1 1 0];

% define a blank grainMap for erosion
erodeMap = false(size(grainMap));

% perform the erosion
for ii = 1:size(padMap,1)
    for jj = 1:size(padMap,2)-2
        In = padMap(ii, jj:jj+2);
        % find the position of the ones in the structuring element array
        In1 = (strucElement == 1);
        % check whether the elements in the window have the value = one in
        % the same positions of the structuring element
        if In(In1) == 1
            erodeMap(ii,jj) = 1;
        end
    end
end

% convert the logical map to a numeric map
erodeMap = double(erodeMap);

[rIdx,cIdx] = find(erodeMap == 1); % rows and columns of pixels = 1
idx = sub2ind(size(ggrain),rIdx,cIdx); % the indices of pixels = 1
[logChk,~] = inpolygon(xMap,yMap,xGrain(idx),yGrain(idx));

% define a new ebsd variable with eroded ebsd map data
temp_outebsd = gebsd(logChk);

% un-gridify the eroded ebsd map data
outebsd = EBSD(temp_outebsd);

end