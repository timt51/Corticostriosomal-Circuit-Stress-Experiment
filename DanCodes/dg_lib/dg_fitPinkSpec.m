function [pinkBL, cfun] = dg_fitPinkSpec(BL, varargin)
%pinkBL = dg_fitPinkSpec(BL)
% Creates a new baseline spectrum structure by fitting a smooth pink noise
% spectrum to <BL>.  There are two free parameters: slope and amplitude.
% Fitting is done by the Curve Fitting Toolbox using f(x) = a*x^b, where a
% is amplitude and b is slope.  The first two points are ignored in doing
% the fit and are simply extrapolated linearly back to x=0.
%INPUTS
% BL: as returned by lfp_BLspectrum; requires the following fields:
%   BL.sum: a column vector containing the sum of all spectral
%       observations; the mean spectrum computed as BL.sum/BL.N is exactly
%       as computed by lfp_mtspectrum(..., 'avg').
%   BL.N: the number of observations (windows times tapers) that produced
%       the sums.
%   BL.f: the frequency represented by each point in BL.sum and BL.sumsqrs.
%       It is assumed that BL.f(1) = 0.
%OUTPUTS
% pinkBL: a partial baseline spectrum structure, with fields
%   'f' - same as BL.f
%   'N' - set to 1.
%   'sum' - the fitted pink spectrum (same length as <pinkBL.f>).  Values
%       are NaN at frequencies greater than <freqlim(2)> (see OPTIONS) and
%       are linearly extrapolated from the first two points inside
%       <freqlim> at frequencies below <freqlim(1)>.
% cfun: the fit result object returned by Matlab 'fit' function, normally a
%   one-term power series function.
%OPTIONS
% 'freqlim', freqlim - <freqlim> is a two-element numeric vector specifying
%   the lower limit (f >= freqlim(1)) and upper limit (f < freqlim(2)) of
%   the frequency range to fit.  All f < freqlim(1) are extrapolated
%   linearly.  Default range of points to fit is BL.f(3:end).
% 'logfit' - tranforms to log-log scale before doing the fit so that
%   instead of minimizing squared absolute error, minimizes square error
%   relative to value.  In this case, <cfun> is a first order polynomial
%   function fitted to the natural logarithms of the frequencies and
%   spectrum in <BL>.

%$Rev: 210 $
%$Date: 2015-02-09 22:45:59 -0500 (Mon, 09 Feb 2015) $
%$Author: dgibson $

argnum = 1;
freqlim = [];
weighting = 'linear';
while argnum <= length(varargin)
    if ischar(varargin{argnum})
        switch varargin{argnum}
            case 'freqlim'
                argnum = argnum + 1;
                freqlim = varargin{argnum};
            case 'logfit'
                weighting = 'log';
            otherwise
                error('dg_fitPinkSpec:badoption', ...
                    'The option %s is not recognized.', ...
                    dg_thing2str(varargin{argnum}));
        end
    else
        error('dg_fitPinkSpec:badoption2', ...
            'The value %s occurs where an option name was expected', ...
            dg_thing2str(varargin{argnum}));
    end
    argnum = argnum + 1;
end

if isempty(freqlim)
    idxrange = 3:length(BL.f);
else
    idxrange = find(BL.f >= freqlim(1) & BL.f < freqlim(2));
end
if isempty(idxrange)
    error('dg_fitPinkSpec:badfreqlim', ...
        'There are no frequency points in the %s range.', ...
        dg_thing2str(freqlim));
end
if idxrange(1) == 1
    % Under no circumstances can we attempt to fit a power law to zero Hz!
    idxrange(1) = [];
end
f = reshape(BL.f(idxrange), [], 1);
p = reshape(BL.sum(idxrange) / BL.N, [], 1);
pinkBL.f = BL.f;
pinkBL.N = 1;
pinkBL.sum = NaN(size(BL.sum));
switch weighting
    case 'linear'
        % Fit Model: p = a * BL.f(idxrange) .^ b
        [cfun,gof,output] = fit( f, p, 'Power1' ); %#ok<ASGLU>
        pinkBL.sum(idxrange) = cfun.a * BL.f(idxrange) .^ cfun.b;
    case 'log'
        % Transform: y = log(p); x = log(f); c = log(a);
        % consequently, a = exp(c).
        % Fit Model: y = c + b * x;
        x = log(f);
        y = log(p);
        [cfun,gof,output] = fit( x, y, 'poly1' ); %#ok<ASGLU>
        pinkBL.sum(idxrange) = exp(cfun.p2) * BL.f(idxrange) .^ cfun.p1;
end
if output.exitflag <= 0
    error('dg_fitPinkSpec:fit', ...
        'Curve fitting failed.');
end
m = diff(pinkBL.sum(idxrange(1:2))) / diff(BL.f(idxrange(1:2)));
b = pinkBL.sum(idxrange(1)) - m * BL.f(idxrange(1));
pinkBL.sum(1:idxrange(1)-1) = m * BL.f(1:idxrange(1)-1) + b;


