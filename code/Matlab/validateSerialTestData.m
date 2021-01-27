function [pass, report] = validateSerialTestData(varargin)
    defaultlogconstant =  2^16/7;
    defaultcountperiod = 1;
    defaulttolerance = 0.01;
    defaultfilename = 'Speedtest_Data.bin';
    defaultfoldername = '.';

    startfolder = pwd();

    p = inputParser;
    addParameter(p,'filename',defaultfilename)
    addParameter(p,'foldername',defaultfoldername)
    addParameter(p,'countperiod', defaultcountperiod); 
    addParameter(p,'logscale_constant',defaultlogconstant);
    addParameter(p,'logtolerance',defaulttolerance);
    if isempty(varargin)
        parse(p);
    else
        parse(p,varargin{:});
    end
    in = p.Results;

    cd(in.foldername);
    if (~ls(in.filename))
        [in.filename, in.foldername] = uigetfile('Speedtest_Data.bin',"Choose file");
        cd(in.foldername);
    end
    
    fid = fopen(in.filename);
    serdat = fread(fid,Inf,'uint16=>int');
    [refdat, target] = generateSerialComparisonData(length(serdat), in.countperiod, in.logscale_constant);
    report.numvals = length(serdat);
    report.minutes = length(serdat)/60000;
    report.missind = find(refdat ~= serdat);
    report.missdif = serdat(report.missind) - refdat(report.missind);
    report.misstarget = target(report.missind);
    report.misstol = (report.missdif == sign(0.5-mod(target(report.missind),1))) & (abs(mod(target(report.missind),1) - 0.5) < in.logtolerance);
    report.serdat = serdat;
    if isempty(report.missind) || all(report.misstol)
        pass = true;
    else
        pass = false;
    end
    cd(startfolder);
end


function [val, target] = generateSerialComparisonData(numSamples, countperiod, logscale_constant)

    zerocode = 0x0100;
    onecode =  0x0101;

    val = zeros(numSamples,1,'int32');
    target = zeros(numSamples,1);
    n=0;

    for i=1:numSamples
        t = mod(countperiod*n, 2^32);
        switch t
            case 0
                val(i) = zerocode;
                target(i) = zerocode;
            case 1
                val(i) = onecode;
                target(i) = onecode;
            otherwise
                target(i) = logscale_constant*log10(single(t));
                val(i) = round(target(i));
        end
        n = n + 1;
        n = mod(n, 2^16);
    end
end
