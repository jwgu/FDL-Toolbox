%Load light field data as an image sequence.
% Inputs :
% - path : (string) path to the light field data. The folder must contain image files of each view named as "(Path)/(LFPrefix)(v)_(u).(fileExt)", for a view (u,v).
% - LFPrefix : (string) Name of the Light Field (=prefix of the filename before the view indices digits).
% - fileExt : (string) file extension (without the dot).
% - uRange : indices of u.
% - vRange : indices of v.
% - crop : vector of the form [CropLeft,CropRight,CropTop,CropBottom].
% - rescale : (default=1) Scaling factor to apply to the light field.
%
% Ouput:
% - LF: Light Field image data in a 5D array with dimensions:
%   1. Vertical spatial axis (Y)
%   2. Horizontal spatial axis (X)
%   3. Color components
%   4. Vertical angular axis (V)
%   5. Horizontal angular axis (U);

function LF = loadLF(path, LFnamePrefix, fileExt, uRange, vRange, crop, rescale)

if(~exist('crop','var')),crop=[];end
if(~exist('rescale','var')||isempty(rescale)),rescale=1;end

fDir = dir([path '/']);

InitData=true;
idxU=1;
for u=uRange
    idxV=1;
    for v=vRange        
        str_u = num2str(u);
        str_v = num2str(v);
        fName = regexp({fDir.name},['^' LFnamePrefix '0*' str_v '_0*' str_u '[.]' fileExt '$'],'match');
        fName=[fName{:}];
        if(isempty(fName)), error(['Can''t find image file of light field view (u=' str_u ',v=' str_v ') in folder ' path '/']);end
        fName=fName{1};
        
        %Load view
        TmpImg = imread([path '/' fName]);
        
        %Size reduction / cropping
        if(~isempty(crop))
            TmpImg = TmpImg(1+crop(3):end-crop(4),1+crop(1):end-crop(2),:);
        end
        if(rescale~=1)
            TmpImg=imresize(TmpImg, rescale);
        end
        
        if(InitData)
            sz = size(TmpImg); sz(end+1:3) = 1;
            LF = zeros([sz,length(vRange),length(uRange)],class(TmpImg));
            InitData=false;
        end
        LF(:,:,:,idxV,idxU) = TmpImg;
        
        idxV = idxV+1;
    end
    idxU = idxU+1;
end