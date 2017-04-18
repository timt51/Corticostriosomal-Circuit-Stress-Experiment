function dg_writeCSC(filename, TS, Samples, Hdr)
%dg_writeCSC(filename, TS, Samples, Hdr)
% INPUTS
%   TS:  Timestamps in clock ticks (units as recorded).
%   Samples:  Guess what!
%   Hdr:  Neuralynx format header (<16kB); may be omitted or empty.
% NOTES
%   The dg_write* series of functions for creating Neuralynx format files
%   only works on Windows.  The dg_save* series can be used to save .mat
%   files in lfp_lib-compatible format.

%$Rev: 207 $
%$Date: 2014-10-16 19:07:56 -0400 (Thu, 16 Oct 2014) $
%$Author: dgibson $

if nargin < 4 || isempty(Hdr)
    Hdr = {'######## Neuralynx Data File Header '
        sprintf('## File Name: %s ', filename)
        sprintf('## Time Opened: %s ', datestr(now))
        '## written by dg_writeCSC '
        ' '
        };
end

if ~ispc
    error('dg_writeCSC:notPC', ...
        'Neuralynx format files can only be created on Windows machines.');
end
Mat2NlxCSC_411(filename, 0, 1, 1, length(TS), [1 0 0 0 1 1], TS, ...
    Samples, Hdr);
