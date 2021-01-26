function dat = generateSerialComparisonData(numSamples, varargin)
    defaultlogconstant =  2^16/7;
    defaultcountperiod = 1;

    p = inputParser;
    addOptional(p,'countperiod', defaultcountperiod); 
    addParameter(p,'logscale_constant',defaultlogconstant);
    if isempty(varargin)
        parse(p);
    else
        parse(p,varargin);
    end
    in = p.Results;

    zerocode = 0x0100;
    onecode =  0x0101;

    dat = zeros(numSamples,1,'int32');
    n=0;

    for i=1:numSamples
        switch n
            case 0
                dat(i) = zerocode;
            case 1
                dat(i) = onecode;
            otherwise
                dat(i) = round(in.logscale_constant*log10(single(n)));
        end
        if mod(i,in.countperiod) == 0
            n = n+1;
        end
    end

