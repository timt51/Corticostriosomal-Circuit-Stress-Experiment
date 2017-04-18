function [hF, hA, hL, offset] = dg_compactStripchart(data, offset, varargin)
% Plots each row of <data> as one line, with a downwards vertical offset of
% <offset> for each successive row of <data>, all in a single axes.
%INPUTS
% data: CSC data in channels/trials x samples format.  "Empty" rows can be
%   created by setting all samples in the row to NaN.
% offset: the distance, in the same units as <data>, by which each
%   successive trace is displaced downwards.  If <offset> is empty, then it
%   is set to the smallest value necessary to prevent successive traces
%   from crossing each other.
%OUTPUTS
% hF: figure handle
% hA: axes handle
% hL: column vector of handles to the line objects plotted
% offset: the value of <offset> actually used in plotting
%OPTIONS
% 'axes', hA - existing axes handle into which waveforms are to be plotted.
% 'colors', colors - <colors> is a three-column array where each row
%   specifies the RGB color used for the corresponding line plot.
% 'fig', hF - existing figure handle where new axes object is created.
% 'samplesize', sampsz - <sampsz> is used to calibrate the X axis.  Where
%   samples represent time points, <sampsz> is the sample period.  Default
%   value is 1.
% 'x0', x0 - <x0> is the sample number that should be calibrated as zero in
%   the x values plotted.  Default is 1.

%$Rev: 93 $
%$Date: 2010-12-26 21:23:25 -0500 (Sun, 26 Dec 2010) $
%$Author: dgibson $

colors = [];
hA = [];
hF = [];
sampsz = 1;
x0 = 1;
argnum = 1;
while argnum <= length(varargin)
    switch varargin{argnum}
        case 'axes'
            argnum = argnum + 1;
            hA = varargin{argnum};
            hF = get(hA, 'Parent');
        case 'colors'
            argnum = argnum + 1;
            colors = varargin{argnum};
        case 'fig'
            argnum = argnum + 1;
            hF = varargin{argnum};
        case 'samplesize'
            argnum = argnum + 1;
            sampsz = varargin{argnum};
        case 'x0'
            argnum = argnum + 1;
            x0 = varargin{argnum};
        otherwise
            error('dg_compactStripchart:badoption', ...
                ['The option "' dg_thing2str(varargin{argnum}) '" is not recognized.'] );
    end
    argnum = argnum + 1;
end

numrows = size(data,1);
if isempty(hF)
    hF = figure;
end
if isempty(hA)
    hA = axes('Parent', hF, 'NextPlot', 'add');
else
    set(hA, 'NextPlot', 'add');
end
if isempty(colors)
    colors = get(hA, 'ColorOrder');
end
if isempty(offset)
    offset = max(max(abs(diff(data, 1))));
end

xvals = ((0:size(data,2)-1) - x0 + 1) * sampsz;
hL = NaN(size(data,1), 1);

for rownum = 1:numrows
    vpos = -(rownum - 1) * offset;
    hL(rownum) = plot(xvals, data(rownum, :) + vpos, 'Color', colors( ...
        mod((rownum - 1), size(colors, 1)) + 1, : ));
end

end