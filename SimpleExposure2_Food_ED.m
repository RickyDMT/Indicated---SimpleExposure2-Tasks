 function SimpleExposure2_Food_ED(varargin)

global KEYS COLORS w wRect XCENTER YCENTER PICS STIM SimpExpFood trial

% This is for food & or model exposure!

prompt={'SUBJECT ID' 'Session' 'fMRI: 1 = Yes; 0 = No'};
defAns={'4444' '1' '1'};

answer=inputdlg(prompt,'Please input subject info',1,defAns);

ID=str2double(answer{1});
SESS = str2double(answer{2});
fmri = str2double(answer{3});
% COND = str2double(answer{2});
% prac = str2double(answer{4});


rng(ID); %Seed random number generator with subject ID
d = clock;

KEYS = struct;
if fmri == 1;
    KEYS.ONE= KbName('0)');
    KEYS.TWO= KbName('1!');
    KEYS.THREE= KbName('2@');
    KEYS.FOUR= KbName('3#');
    KEYS.FIVE= KbName('4$');
    KEYS.SIX= KbName('5%');
    KEYS.SEVEN= KbName('6^');
    KEYS.EIGHT= KbName('7&');
    KEYS.NINE= KbName('8*');
%     KEYS.TEN= KbName('9(');
else
    KEYS.ONE= KbName('1!');
    KEYS.TWO= KbName('2@');
    KEYS.THREE= KbName('3#');
    KEYS.FOUR= KbName('4$');
    KEYS.FIVE= KbName('5%');
    KEYS.SIX= KbName('6^');
    KEYS.SEVEN= KbName('7&');
    KEYS.EIGHT= KbName('8*');
    KEYS.NINE= KbName('9(');
%     KEYS.TEN= KbName('0)');
end

rangetest = cell2mat(struct2cell(KEYS));
% KEYS.all = min(rangetest):max(rangetest);
KEYS.all = rangetest;

%Top trigger is for Macs, bottom trigger is for PCs. Comment out whichever
%is not being used...
KEYS.trigger = KbName('''"');
% KEYS.trigger = KbName('''');


COLORS = struct;
COLORS.BLACK = [0 0 0];
COLORS.WHITE = [255 255 255];
COLORS.RED = [255 0 0];
COLORS.BLUE = [0 0 255];
COLORS.GREEN = [0 255 0];
COLORS.YELLOW = [255 255 0];
COLORS.rect = COLORS.GREEN;

STIM = struct;
STIM.blocks = 1;
STIM.trials = 40;
STIM.totes = STIM.blocks*STIM.trials;
STIM.trialsper = 20;
STIM.trialdur = 5;
% STIM.rate_dur = 1;
STIM.jitter = [4 5 6 7 8];

%% Keyboard stuff for fMRI...

%list devices
[keyboardIndices, productNames] = GetKeyboardIndices;

isxkeys=strcmp(productNames,'Xkeys');

xkeys=keyboardIndices(isxkeys);
macbook = keyboardIndices(strcmp(productNames,'Apple Internal Keyboard / Trackpad'));

%in case something goes wrong or the keyboard name isn?t exactly right
if isempty(macbook)
    macbook=-1;
end

%in case you?re not hooked up to the scanner, then just work off the keyboard
if isempty(xkeys)
    xkeys=macbook;
end

%% Find & load in pics
%find the image directory by figuring out where the .m is kept
%HARDCODE mdir HERE.
mdir = '';
% [mdir,~,~] = fileparts(which('SimpleExposure2_Food_ED.m'));

%UPDATE HERE TO CHANGE IMAGE DIRECTORY
imgdir = fullfile(mdir,'Pics');

cd(imgdir);
 


PICS =struct;

PICS.in.hi = dir('Healthy*');%struct('name',{p.PicRating_Food.H(1:30).name}');
PICS.in.lo = dir('Binge*');%struct('name',{p.PicRating_Food.U(1:30).name}');
% neutpics = dir('water*');

%Check if pictures are present. If not, throw error.
%Could be updated to search computer to look for pics...
if isempty(PICS.in.hi) || isempty(PICS.in.lo)
    error('Could not find pics. Please ensure pictures are found in a folder names IMAGES within the folder containing the .m task file.');
end

%% Fill in rest of pertinent info
SimpExpFood = struct;

%1 = Healthy, 0 = Unhealthy
pictype = [ones(STIM.trialsper,1); zeros(STIM.trialsper,1)];

%Make long list of randomized #s to represent each pic
piclist = [randperm(length(PICS.in.hi),STIM.trialsper)'; randperm(length(PICS.in.lo),STIM.trialsper)']; %randperm(30)'; randperm(30)'];


%Concatenate these into a long list of trial types.
trial_types = [pictype piclist];
shuffled = trial_types(randperm(size(trial_types,1)),:);

jitter = BalanceTrials(STIM.totes,1,STIM.jitter);

 for x = 1:STIM.blocks
     for y = 1:STIM.trials;
         tc = (x-1)*STIM.trials + y;
         SimpExpFood.data(tc).pictype = shuffled(tc,1);
         
         if shuffled(tc,1) == 1
            SimpExpFood.data(tc).picname = PICS.in.hi(shuffled(tc,2)).name;
         elseif shuffled(tc,1) == 0
             SimpExpFood.data(tc).picname = PICS.in.lo(shuffled(tc,2)).name;
         end
         
         SimpExpFood.data(tc).jitter = jitter(tc);
         SimpExpFood.data(tc).fix_onset = NaN;
         SimpExpFood.data(tc).pic_onset = NaN;
         SimpExpFood.data(tc).rate_onset = NaN;
%          SimpExpFood.data(tc).rate_RT = NaN;
%          SimpExpFood.data(tc).rating = NaN;
     end
 end

    SimpExpFood.info.ID = ID;
    SimpExpFood.info.date = sprintf('%s %2.0f:%02.0f',date,d(4),d(5));
    


commandwindow;


%%
%change this to 0 to fill whole screen
DEBUG=1;

%set up the screen and dimensions

%list all the screens, then just pick the last one in the list (if you have
%only 1 monitor, then it just chooses that one)
Screen('Preference', 'SkipSyncTests', 1);

screenNumber=max(Screen('Screens'));

if DEBUG==1;
    %create a rect for the screen
    winRect=[0 0 640 480];
    %establish the center points
    XCENTER=320;
    YCENTER=240;
else
    %change screen resolution
%     Screen('Resolution',0,1024,768,[],32);
    
    %this gives the x and y dimensions of our screen, in pixels.
    [swidth, sheight] = Screen('WindowSize', screenNumber);
    XCENTER=fix(swidth/2);
    YCENTER=fix(sheight/2);
    %when you leave winRect blank, it just fills the whole screen
    winRect=[];
end

%open a window on that monitor. 32 refers to 32 bit color depth (millions of
%colors), winRect will either be a 1024x768 box, or the whole screen. The
%function returns a window "w", and a rect that represents the whole
%screen. 
[w, wRect]=Screen('OpenWindow', screenNumber, 0,winRect,32,2);

%%
%you can set the font sizes and styles here
Screen('TextFont', w, 'Arial');
%Screen('TextStyle', w, 1);
Screen('TextSize',w,30);

KbName('UnifyKeyNames');

%% Where should pics go
STIM.framerect = [XCENTER-300; YCENTER-350; XCENTER+300; YCENTER+50];

%% fMRI Synch

if fmri == 1;
    DrawFormattedText(w,'Synching with fMRI: Waiting for trigger','center','center',COLORS.WHITE);
    Screen('Flip',w);
    
    scan_sec = KbTriggerWait(KEYS.trigger,xkeys);
else
    scan_sec = GetSecs();
end

%% Initial screens
%UPDATE INSTRUCTIONS
DrawFormattedText(w,'We are going to show you some pictures of food. \nPUT INSTRUCTIONS HERE. \nPress any key when you are ready to begin the task.','center','center',COLORS.WHITE,50,[],[],1.5);
Screen('Flip',w);
% KbWait([],3);
FlushEvents();
while 1
    [pracDown, ~, pracCode] = KbCheck(); %waits for R or L index button to be pressed
    if pracDown == 1 && any(pracCode(KEYS.all))
        break
    end
end
Screen('Flip',w);
WaitSecs(1);

%% Trials

for block = 1:STIM.blocks
    for trial = 1:STIM.trials
        tcounter = (block-1)*STIM.trials + trial;
        tpx = imread(getfield(SimpExpFood,'data',{tcounter},'picname'));
        texture = Screen('MakeTexture',w,tpx);
        
        DrawFormattedText(w,'+','center','center',COLORS.WHITE);
        fixon = Screen('Flip',w);
        SimpExpFood.data(tcounter).fix_onset = fixon - scan_sec;
        WaitSecs(SimpExpFood.data(tcounter).jitter);
        
        Screen('DrawTexture',w,texture,[],STIM.framerect);
%         DrawFormattedText(w,verbage,'center',(wRect(4)*.75),COLORS.WHITE);
%         drawRatings([],w);
        picon = Screen('Flip',w);
        SimpExpFood.data(tcounter).pic_onset = picon - scan_sec;
        WaitSecs(STIM.trialdur);
        
    end
    
    
end

%% Save all the data

%Export SimpExpFood to text and save with subject number.
%find the mfilesdir by figuring out where show_faces.m is kept

%get the parent directory, which is one level up from mfilesdir
savedir = [mdir filesep 'Results' filesep];

% cd(savedir)
savename = sprintf('SimpExp_Food_%d-%d.mat',ID,SESS);%['SimpExp_Food_' num2str(ID) '.mat'];

if exist([savedir savename],'file')==2;
    savename = ['SimpExp_Food_' num2str(ID) '_' sprintf('%s_%2.0f%02.0f',date,d(4),d(5)) '.mat'];
end


try
save([savedir savename],'SimpExpFood');
catch
    warning('Something is amiss with this save. Retrying to save in a more general location...');
    try
        save([mdir filesep savename],'SimpExpFood');
    catch
        warning('STILL problems saving....Try right-clicking on ''SimpExp'' and Save as...');
        save SimpExpFood
    end
end

%also save to .csv.
SimpExpFood_table = struct2table(SimpExpFood.data);
SimpExpFood_table.SUBID = repmat(SimpExpFood.info.ID,height(SimpExpFood_table),1);
temp_date_cell = cell(height(SimpExpFood_table),1);
[temp_date_cell{1:height(SimpExpFood_table)}] = deal(SimpExpFood.info.date);
SimpExpFood_table.Date = temp_date_cell;

savename_csv = [savedir sprintf('SimpExp_Food_%d-%d.csv',ID,SESS)];
writetable(SimpExpFood_table,savename_csv);


DrawFormattedText(w,'That concludes this task.','center','center',COLORS.WHITE);
Screen('Flip', w);
WaitSecs(10);

sca

 end



