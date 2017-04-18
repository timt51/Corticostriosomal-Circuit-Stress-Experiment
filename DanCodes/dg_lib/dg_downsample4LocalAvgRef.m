function dg_downsample4LocalAvgRef(filenames, sessiondir, N, varargin)
%dg_downsample4LocalAvgRef(filenames, sessiondir, N)
% dg_downsample all the files listed in <filenames>, after checking them
% as a group for timestamp conflicts.  If there are conflicts or disordered
% timestamps, it is an error.
%INPUTS
% filenames: names of files to downsample, either as a cell string vector
%   or a cell vector of cell arrays of strings (i.e. in the form of
%   <localavgrefs> used for supplying literal filenames to
%   dg_makeLocalAvgRefs).
% sessiondir: string
% N: integer
%OUTPUTS
% ...to same <sessiondir> that it reads inputs from, filenames constructed
%   as in 'suffix' option to dg_downsampleAndConvert.  Gracefully handles
%   filenames that already have a suffix indicating they were downsampled.
%OPTIONS
% 'outdir', outdir - writes output files to <outdir> instead of to
%   <sessiondir>.  <outdir> must already exist or else
%   dg_downsample4LocalAvgRef will uncermoniously fail to write the output
%   files.
% 'ncs' - for each filename in <filenames>, substitute the extension '.ncs'
%   for whatever extension (or lack thereof) each filename has.
% 'noTScheck' - skips the timestamp check; this should only be used in
%   cases where it is already known that there are no TS problems.
% 'verbose' - that.

argnum = 1;
downsample_opts = {};
ncsflag = false;
outdir = sessiondir;
TScheckflag = true;
while argnum <= length(varargin)
    switch varargin{argnum}
        case 'ncs'
            ncsflag = true;
        case 'noTScheck'
            TScheckflag = false;
        case 'outdir'
            argnum = argnum + 1;
            outdir = varargin{argnum};
        case 'verbose'
            downsample_opts{end+1} = 'verbose'; %#ok<AGROW>
        otherwise
            error('dg_downsample4LocalAvgRef:badoption', ...
                'The option %s is not recognized.', ...
                dg_thing2str(varargin{argnum}));
    end
    argnum = argnum + 1;
end

if iscell(filenames{1})
    % This is a cell vector of cell arrays of strings, and we must flatten
    % it into a cell vector.
    filenamevector = {};
    for refidx = 1:length(filenames)
        for fileidx = 1:length(filenames{refidx})
            filenamevector{end+1} = filenames{refidx}{fileidx}; %#ok<AGROW>
        end
    end
    filenames = unique(filenamevector);
end

[~, name, ext] = fileparts(filenames{1});
if TScheckflag
    if ncsflag || ~isequal(lower(ext), '.mat')
        if ncsflag
            infilename = [name '.ncs'];
        else
            infilename = filenames{1};
        end
        TS = dg_readCSC(fullfile(sessiondir, infilename));
        if any(diff(TS)<0)
            error('dg_downsample4LocalAvgRef:TS1', ...
                'TS, Elliot...');
        end
        for fileidx = 2:length(filenames)
            fprintf('Loading file #%d\n', fileidx);
            if ncsflag
                [~, name] = fileparts(filenames{fileidx});
                infilename = [name '.ncs'];
            else
                infilename = filenames{fileidx};
            end
            TS2 = dg_readCSC(fullfile(sessiondir, infilename));
            if ~isequal(TS, TS2)
                error('dg_downsample4LocalAvgRef:TS2', ...
                    'TS, Elliot...');
            end
        end
    else
        load(fullfile(sessiondir, filenames{1}), '-mat');
        TS = dg_Nlx2Mat_Timestamps;
        if any(diff(TS)<0)
            error('dg_downsample4LocalAvgRef:TS3', ...
                'TS, Elliot...');
        end
        for fileidx = 2:length(filenames)
            fprintf('Loading file #%d\n', fileidx);
            load(fullfile(sessiondir, filenames{fileidx}), '-mat');
            if ~isequal(TS, dg_Nlx2Mat_Timestamps) || any(diff(TS)<0)
                error('dg_downsample4LocalAvgRef:TS4', ...
                    'TS, Elliot...');
            end
        end
    end
end

for fileidx = 1:length(filenames)
    [~,name,ext] = fileparts(filenames{fileidx});
    Nprevtokens = regexp(name, '^(.*)_down(\d+).*$', 'tokens');
    if isempty(Nprevtokens)
        prevname = name;
        Nprev = 1;
    else
        prevname = Nprevtokens{1}{1};
        Nprev = str2double(Nprevtokens{1}{2});
    end
    if ncsflag
        [~, name, ext] = fileparts(filenames{fileidx});
        infilename = [name '.ncs'];
    else
        infilename = filenames{fileidx};
    end
    outfilename = lower(sprintf('%s_down%d%s', prevname, N * Nprev, ext));
    dg_downsample(fullfile(sessiondir, infilename), ...
        fullfile(outdir, outfilename), N, 'skip', downsample_opts{:});
end


