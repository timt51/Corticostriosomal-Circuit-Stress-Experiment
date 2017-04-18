function [TS, Samples, Hdr] = dg_readCSC(filename, varargin)
% Does not read return values that are not used.  Note that this is based
% purely on the number of return values, so values whose return is
% suppressed by using '~' *do* still get read.
% OPTIONS
%   'header' - reads only header, returns empty for TS and Samples
%   'mode', modenum, modearg - invokes the Neuralynx "Extraction Mode"
%       specified by <modenum> (default is 1).  In keeping with the new
%       convention of Nlx library v5.0.1, the first record is record 1,
%       whereas in releases through v4.1.3 it was record 0.
%         1. Extract All
%         2. Extract Record Index Range
%         3. Extract Record Index List
%         4. Extract Timestamp Range
%         5. Extract Timestamp List

%$Rev: 213 $
%$Date: 2015-03-21 14:30:03 -0400 (Sat, 21 Mar 2015) $
%$Author: dgibson $

TS = [];
Samples = [];
if nargout >= 2
    selectary = [1, 0, 0, 0, 1];
else
    selectary = [1, 0, 0, 0, 0];
end
if nargout >= 3
    readheader = 1;
else
    readheader = 0;
end
headeronly = false;
modenum = 1;
modearg = [];
argnum = 1;
while argnum <= length(varargin)
    switch varargin{argnum}
        case 'header'
            headeronly = true;
        case 'mode'
            argnum = argnum + 1;
            modenum = varargin{argnum};
            argnum = argnum + 1;
            modearg = varargin{argnum};
        otherwise
            error('dg_readCSC:badoption', ...
                ['The option "' varargin{argnum} '" is not recognized.'] );
    end
    argnum = argnum + 1;
end
[p, n, ext] = fileparts(filename); %#ok<ASGLU>
if strcmpi(ext, '.dat')
    tempfn = [tempname '.ncs'];
    while exist(tempfn) %#ok<EXIST>
        tempfn = [tempname '.ncs'];
    end
    warning('dg_readCSC:ext', ...
        'This Nlx function requires .ncs extension; making temporary copy of %s to %s.', ...
        filename, tempfn );
    dg_copyfile(filename, tempfn);
    file2read = tempfn;
else
    file2read = filename;
end
% file2read = filename;
if ispc
    if ismember(modenum, [2 3])
        % v4.1.1 uses 0 to denote the first record
        modearg = modearg - 1;
    end
    if headeronly
        fid = fopen(file2read);
        if fid < 0
            error('dg_readCSC:fopen', ...
                'Could not open %s for reading', ...
                file2read);
            
        end
        headerchars = fread(fid, 2^14, '*char');
        fclose(fid);
        Hdr = reshape( ...
            regexp(reshape(headerchars(headerchars~=0), 1, []), ...
            '\o015\o012', 'split'), [], 1 );
        Hdr(end) = [];
    else
        if nargout > 2
            [TS, Samples, Hdr] = Nlx2MatCSC_411(file2read, selectary, ...
                readheader, modenum, modearg);
        elseif nargout == 2
            [TS, Samples] = Nlx2MatCSC_411(file2read, selectary, ...
                readheader, modenum, modearg);
        else
            % nargout must be 1
            TS = Nlx2MatCSC_411(file2read, selectary, ...
                readheader, modenum, modearg);
        end
    end
elseif ismac || isunix
    if ismember(modenum, [2 3])
        % The unix version uses 0 to denote the first record
        modearg = modearg - 1;
    end
    if headeronly
        Hdr = Nlx2MatCSC_v3(file2read, [0, 0, 0, 0, 0], 1, 1);
    else
        if nargout > 2
            [TS, Samples, Hdr] = Nlx2MatCSC_v3(file2read, selectary, ...
                readheader, modenum, modearg);
        elseif nargout == 2
            [TS, Samples] = Nlx2MatCSC_v3(file2read, selectary, ...
                readheader, modenum, modearg);
        else
            % nargout must be 1
            TS = Nlx2MatCSC_v3(file2read, selectary, ...
                readheader, modenum, modearg);
        end
    end
    if strcmpi(ext, '.dat')
        dg_forcedeletefile(tempfn);
    end
else
    error('dg_readCSC:arch', ...
        'Unrecognized computer platform');
end
if exist('Hdr', 'var') && ...
        (isempty(Hdr{end}) || ~isempty(regexp(Hdr{end}, '^\s*$', 'once' )))
    Hdr(end) = [];
end

