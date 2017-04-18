function dg_batchProcess(funchandle, varargin)
%BATCHPROCESS executes any function wrapped in error handling with logging,
%and then exits Matlab.
% batchProcess(funchandle, varargin)
%   <funchandle> is an arbitrary function handle, and <varargin> is its
%   argument list, with any dg_batchProcess options prepended.
%   dg_batchProcess options will be removed from the head of <varargin>
%   until a value which is not a dg_batchProcess option is encountered.
%OPTIONS
% 'leaveMarkerFileOnExit' - creates the file "dg_batchProcess_done.txt"
%   immediately before exiting.

%$Rev: 166 $
%$Date: 2013-01-14 16:23:52 -0500 (Mon, 14 Jan 2013) $
%$Author: dgibson $

disp(datestr(now, 0));
fprintf('Matlab version %s\npathdef: %s\n', version, which('pathdef'));
fprintf('Current working directory: %s\n', pwd);
fprintf('funchandle: %s\n', func2str(funchandle));
fprintf('varargin: %s\n', dg_thing2str(varargin));
foundfirstarg = false;
markerflag = false;
while ~foundfirstarg && ~isempty(varargin)
    if isequal(varargin{1}, 'leaveMarkerFileOnExit')
        markerflag = true;
        varargin(1) = [];
    else
        foundfirstarg = true;
    end
end
try
    feval(funchandle, varargin{:});
catch e
    if isempty(varargin)
        logmsg = sprintf('Error while processing %s', ...
            func2str(funchandle));
    else
        logmsg = sprintf('Error while processing %s(%s)', ...
            func2str(funchandle), dg_thing2str(varargin{1}) );
    end
    logmsg = sprintf('%s\n%s\n%s', ...
        logmsg, e.identifier, e.message);
    for stackframe = 1:length(e.stack)
        logmsg = sprintf('%s\n%s\nline %d', ...
            logmsg, e.stack(stackframe).file, e.stack(stackframe).line);
    end
    disp(logmsg);
end
if markerflag
    fid = fopen('dg_batchProcess_done.txt', 'w');
    if fid ~= -1
        fprintf(fid, '%s\n', datestr(now, 0));
        fclose(fid);
    end
end
exit;
