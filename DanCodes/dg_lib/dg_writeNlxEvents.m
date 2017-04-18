function dg_writeNlxEvents(filename, TS, TTL, ES, Hdr)
%dg_writeNlxEvents(filename, TS, TTL, ES, Hdr)
%   TS:  Timestamps in clock ticks (units as recorded)
%   TTL:  TTL IDs.  These are returned as signed integers, with 2^15 bit 
%       (strobe/sync) propagated to the left.  To extract the lower 15
%       bits, add 2^15 to negative values to yield positive integers.
%   ES:  Event strings.
%   Reshapes <TS>, <TTL>, and <ES> as needed by Neuralynx conversion
%   function; the only restriction is that they must each containg the same
%   number of elements, except that if <ES> is empty or not given, then
%   string values will be calculated with 'RecID: 4098 Port: 0'.  Only the
%   bottom 16 bits are converted; the state of the strobe bit is preserved.
%NOTES
%   See dg_txt2nev for converting from text files to Nlx.
%   The dg_write* series of functions for creating Neuralynx format files
%   only works on Windows.  The dg_save* series can be used to save .mat
%   files in lfp_lib-compatible format.

%$Rev: 171 $
%$Date: 2013-03-01 18:57:45 -0500 (Fri, 01 Mar 2013) $
%$Author: dgibson $

createstringsflag = false;
if nargin < 5 || isempty(Hdr)
    Hdr = {'######## Neuralynx Data File Header'
    '## File Name: C:\RData\2005-7-27_13-9-11\Events.Nev '
    '## Time Opened: (m/d/y): 7/27/2005  At Time: 13:9:16.937 '
    '-CheetahRev 3.0.6 '
    '-NLX_Base_Class_Name	Events '
    '-NLX_Base_Class_Type	EventAcqEnt '
    '-RecordSize  184 '
    ' '};
%     Hdr = {'######## dg_writeNlxEvents File Header'
%         sprintf('## File Name: %s', filename)
%         sprintf('## Time Opened: %s', datestr(now))
%         ' '
%         };
end
if nargin < 4 || isempty(ES)
    ES = cell(numel(TS),1);
    createstringsflag = true;
end

if numel(TTL) ~= numel(TS) ...
        || numel(ES) ~= numel(TS)
    error('dg_writeNlxEvents:badsize', ...
        'TS, TTL, and ES must all have the same number of elements' );
end

TS = reshape(TS, 1, []);
TTL = reshape(TTL, 1, []);
ES = reshape(ES, [], 1);
NlxEvtIDs = ones(size(TS));
Extras = zeros(8, numel(TS));

if isempty(Hdr{end}) || ~isempty(regexp(Hdr{end}, '^\s*$'))
    Hdr(end) = [];
end
if createstringsflag
    for k = 1:numel(TS)
        if TTL(k) < 0
            u16ttl = TTL(k) + 2^16;
        else
            u16ttl = TTL(k);
        end
        ES{k} = sprintf('RecID: 4098 Port: 0 TTL Value: 0x%.0X', u16ttl);
    end
end
Mat2NlxEV_411(filename, 0, 1, 1, numel(TS), [1,1,1,1,1,1], ...
    TS, NlxEvtIDs, TTL, ...
        Extras, ES, Hdr);
    