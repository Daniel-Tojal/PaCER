% The PaCER Toolbox: testPaCER.m
%
% Purpose:
%     - test the PaCER function
%
% Author:
%     - Loic Marx, March 2019

global refDataPath
global inputDataPath
global PACERDIR

%% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which(mfilename));
cd(fileDir);

%% load reference data (function implemented only with niiCT model)
%refData = load([refDataPath filesep 'refData_PaCER_niiCT.mat']);
refData = load ([getenv('PACER_DATA_PATH') filesep 'ref' filesep 'refData_PaCER_niiCT.mat']);

% Load post OP CT 
%niiCT_PostOP_new = NiftiMod([inputDataPath filesep 'CT_POSTOP_with_XML.nii.gz']);
niiCT_PostOP_new = NiftiMod([getenv('PACER_DATA_PATH') filesep 'input' filesep 'CT_POSTOP_with_XML.nii.gz']);

% generate the new output (testing only niiCT input argument)
[elecModels_new, elecPointCloudsStruct_new, intensityProfiles_new, skelSkelmms_new] = PaCER(niiCT_PostOP_new);

% get the fieldnames which are not empty 
% try 
%emptyIndex = find(arrayfun(@(MyStruct) isempty(MyStruct.myField),MyStruct));
fn = fieldnames(refData.elecModels_ref{1});
%tf = refData.elecModels_ref{1}(~structfun('isempty', refData.elecModels_ref{1}))
refData.elecModels_ref{1}
tf = cellfun(@(c) isempty(refData.elecModels_ref{1}.(c)) && (~isnumeric(getfield(elecModels_new{1}, fn))))
S2 = rmfield(refData.elecModels_ref{1}, fn(tf))

refData.elecModels_ref{1}(~cellfun('isempty',refData.elecModels_ref{1}))  
elecModels_new{1}
assert(isequal(getfield(elecModels_new{1}, fn{1}), getfield(refData.elecModels_ref{1}, fn{1})))

S = refData.elecModels_ref{1}
fn = fieldnames(refData.elecModels_ref{1});
fields = {'apprTotalLengthMm','activeContactPoint'};
A = rmfield(S,fields)


%or 
fn = fieldnames(S)
tf = cellfun(@(c) isempty(S.(c)), fn)
S2 = rmfield(S, fn(tf))


%% need to be fixed !

for k = 1:length(fn) 
    if (~isnumeric(getfield(elecModels_new{1}, fn{k})) && ~isnumeric(getfield(refData.elecModels_ref{1}, fn{k})))
        assert(isequal(getfield(elecModels_new{1}, fn{k}), getfield(refData.elecModels_ref{1}, fn{k})))
    end
   k = k+1;
end




% compare the new data against the reference data
assert(norm(elecModels_new, refData.elecModels_ref) < tol)
assert(isequal(elecPointCloudsStruct_new, refData.elecPointCloudsStruct_ref))
assert(isequal(intensityProfiles_new, refData.intensityProfiles_ref))
assert(isequal(skelSkelmms_new, refData.skelSkelmms_ref))

% test the function with XML plan
%load reference data for CT post OP with the corresponding XML file
refData_XML = load ([getenv('PACER_DATA_PATH') filesep 'ref' filesep 'refData_PaCER_xmlPlan.mat']);

% define input arguments (testing niiCT and Xml Plan)
niiCT_Xml_new = niiCT_PostOP_new; 
xml_Plan_new = [getenv('PACER_DATA_PATH') filesep 'input' filesep 'CT_POSTOP_with_XML.xml'];

% generate the new output (function implemented with XML plan)
[elecModels_XML_new, elecPointCloudsStruct_XML_new, intensityProfiles_XML_new, skelSkelmms_XML_new] = PaCER(niiCT_Xml_new,'medtronicXMLPlan', xml_Plan_new);

% compare the new data against the reference data using a XML plan
%assert(isequal(elecModels_XML_new, refData_XML.elecModels_XML_ref))
assert(isequal(elecPointCloudsStruct_XML_new, refData_XML.elecPointCloudsStruct_XML_ref))
assert(isequal(intensityProfiles_XML_new, refData_XML.intensityProfiles_XML_ref))
assert(isequal(skelSkelmms_XML_new, refData_XML.skelSkelmms_XML_ref))
%

%% load reference data (provide brain mask to the CT post OP)
refData_brainMask = load([getenv('PACER_DATA_PATH') filesep 'ref' filesep 'refData_PaCER_WithBrainMask.mat']);

% define input arguments (testing niiCT and brainMask)
niiCT_brainMask_new = NiftiMod([getenv('PACER_DATA_PATH') filesep 'input' filesep 'ct_post.nii.gz']);
brainMaskPath = [getenv('PACER_DATA_PATH') filesep 'input' filesep 'ct_post_mask.nii'];

% generate the new output (testing niiCT and brainMask)
[elecModels_Mask_new, elecPointCloudsStruct_Mask_new, intensityProfiles_Mask_new, skelSkelmms_Mask_new] = PaCER(niiCT_brainMask_new,'brainMask', brainMaskPath);

% compare the new data against the reference data using a BrainMask
%assert(isequal(elecModels_Mask_new{1, 1}, refData_brainMask.elecModels_Mask_Ref{1, 1}))
assert(isequal(elecPointCloudsStruct_Mask_new, refData_brainMask.elecPointCloudsStruct_Mask_Ref))
assert(isequal(intensityProfiles_Mask_new, refData_brainMask.intensityProfiles_Mask_Ref))
assert(isequal(skelSkelmms_Mask_new, refData_brainMask.skelSkelmms_Mask_Ref))

%% test different electrode type: 
% load the reference data
refData_electrodeType = load([getenv('PACER_DATA_PATH') filesep 'ref' filesep 'refData_PaCER_electrodeType.mat']);
% define the input argument 
niiCT_electrodesType = niiCT_PostOP_new; 
xml_Plan_new; 

% generate the new output with Medtronic 3387 electrode type. 
[elecModels_Medtronic3387_new, elecPointCloudsStruct_Medtronic3387_new, intensityProfiles_Medtronic3387_new, skelSkelmms_Medtronic3387_new] = PaCER(niiCT_electrodesType, 'medtronicXMLPlan', xml_Plan_new, 'electrodeType', 'Medtronic 3387');

% compare the new data against the reference data using XML plan and
% providing electrode type (Medtronic 3387)

%assert(isequal(elecModels_Medtronic3387_new, refData_electrodeType.elecModels_Medtronic3387_ref))
assert(isequal(elecPointCloudsStruct_Medtronic3387_new, refData_electrodeType.elecPointCloudsStruct_Medtronic3387_ref))
assert(isequal(intensityProfiles_Medtronic3387_new, refData_electrodeType.intensityProfiles_Medtronic3387_ref))
assert(isequal(skelSkelmms_Medtronic3387_new, refData_electrodeType.skelSkelmms_Medtronic3387_ref))

% generate the new output with Medtronic 3389 electrode type.
[elecModels_Medtronic3389_new, elecPointCloudsStruct_Medtronic3389_new, intensityProfiles_Medtronic3389_new, skelSkelmms_Medtronic3389_new] = PaCER(niiCT_electrodesType, 'medtronicXMLPlan', xml_Plan_new, 'electrodeType', 'Medtronic 3389');

% compare the new data against the reference data using XML plan and
% providing electrode type (Medtronic 3389)
%assert(isequal(elecModels_Medtronic3389_new, refData_electrodeType.elecModels_Medtronic3389_ref))
assert(isequal(elecPointCloudsStruct_Medtronic3389_new, refData_electrodeType.elecPointCloudsStruct_Medtronic3389_ref))
assert(isequal(intensityProfiles_Medtronic3389_new, refData_electrodeType.intensityProfiles_Medtronic3389_ref))
assert(isequal(skelSkelmms_Medtronic3389_new, refData_electrodeType.skelSkelmms_Medtronic3389_ref))

% generate the new output with Boston electrode type.
[elecModels_Boston_new, elecPointCloudsStruct_Boston_new, intensityProfiles_Boston_new, skelSkelmms_Boston_new] = PaCER(niiCT_electrodesType, 'medtronicXMLPlan', xml_Plan_new, 'electrodeType', 'Boston Vercise Directional');

% compare the new data against the reference data using XML plan and
% providing electrode type (Boston Vercise Directional)
%assert(isequal(elecModels_Boston_new, refData_electrodeType.elecModels_Boston_ref))
assert(isequal(elecPointCloudsStruct_Boston_new, refData_electrodeType.elecPointCloudsStruct_Boston_ref))
assert(isequal(intensityProfiles_Boston_new, refData_electrodeType.intensityProfiles_Boston_ref))
assert(isequal(skelSkelmms_Boston_new, refData_electrodeType.skelSkelmms_Boston_ref))

%% test the warning messages
% test if slice thickness is greater than 1 mm
warningMessage = 'Slice thickness is greater than 1 mm! Independent contact detection is most likly not possible. Forcing contactAreaCenter based method.';
assert(verifyFunctionWarning('PaCER', warningMessage, 'inputs', {niiCT_PostOP_new}))

% test if slice thickness is greater than 0.7 mm
warningMessage = 'Slice thickness is greater than 0.7 mm! Independet contact detection might not work reliable in this case. However, for certain electrode types with large contacts spacings you might be lucky.';
assert(verifyFunctionWarning('PaCER', warningMessage, 'inputs', {niiCT_brainMask_new}))



