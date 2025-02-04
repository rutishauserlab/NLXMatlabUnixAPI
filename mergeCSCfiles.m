function mergeCSCfiles()
% JD/sep16
% this function can be used to merge several CSC files

CSCfiles = cell(1,1);
count = 0;
chooseAnother=1;
while chooseAnother
    count = count + 1;
    % choose CSC1.ncs file
    [CSCfile,CSCdir] = uigetfile('CSC*.ncs',sprintf('Please select CSC1 file #%d\n',count));
    CSCfiles{count} = fullfile(CSCdir,CSCfile);
    fprintf('%d: %s\n',count,CSCfiles{count});
    if count>=2
        chooseAnother = input('Would you like to choose another file? (0 or 1): ');
    end
end

order = input('If incorrect, enter correct order (e.g., [2 1]); otherwise, hit return: ');
if ~isempty(order)
    CSCfiles = CSCfiles(order);
end

for i = 1:length(CSCfiles)
    fprintf('%d: %s\n',i,CSCfiles{i});
end

outDir = fullfile(CSCdir,'..','merged'); 
mkdir(outDir);

cd(outDir);

ch = 1;
while exist(strrep(CSCfiles{i},'CSC1',sprintf('CSC%d',ch)),'file'),
    timestampsAll  = [];
    dataSamplesAll = [];
    sampleFreqAll  = [];
    headerInfoAll  = [];
    for i = 1:length(CSCfiles)
        [timestamps,nrBlocks,nrSamples,sampleFreq,isContinous,headerInfo] = getRawCSCTimestamps(strrep(CSCfiles{i},'CSC1',sprintf('CSC%d',ch)));
        keyboard
        [timestamps,dataSamples] = getRawCSCData(strrep(CSCfiles{i},'CSC1',sprintf('CSC%d',ch)), 1, length(timestamps), 2 );
        timestampsAll  = [timestampsAll timestamps];
        dataSamplesAll = [dataSamplesAll;dataSamples];
        sampleFreqAll  = [sampleFreqAll sampleFreq];
        headerInfoAll  = [headerInfoAll;headerInfo(2:end)];
        % compare headerInfo
        if sum(diff(sampleFreqAll)~=0)>0,error('Sample frequencies need to be the same across files to merge');end
    end
    headerInfo = unique(headerInfoAll);

    
    putRawCSC(sprintf('CSC%d.ncs',ch), timestampsAll, dataSamplesAll, ch, sampleFreq, 512*ones(1,length(timestampsAll)), headerInfo);
    ch = ch + 1;
end