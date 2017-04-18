function significance = dg_chi2test2(N, userules)
%significance = dg_chi2test2(N, userules)
%  N is a histogram row vector with equal bin widths for all bins.  Returns
%  the statistical significance level, i.e. the probability that the
%  differences from the mean in counts among the columns would be greater
%  than or equal to the given values if the identity of the bin doesn't
%  matter. If userules is true, then the following rules of thumb are
%  applied and cause NaN to be returned if they are violated:
%  ·	no expected value for a category should be less than 1 (it does not
%  matter what the observed values are)
%  ·	no more than one-fifth of expected values should be less than 5
%  Since all bins are assumed to be of equal width, these two rules reduce
%  to the single rule that the expected value must be at least 5.
%
% Based on material of
% http://helios.bto.ed.ac.uk/bto/statistics/tress9.html, "Chi-squared test
% for categories of data".

%$Rev: 25 $
%$Date: 2009-03-31 21:56:57 -0400 (Tue, 31 Mar 2009) $
%$Author: dgibson $

if any(any(isnan(N)))
    significance = NaN;
    return
end
if nargin < 2
    userules = false;
end
chi2 = 0;
Ntot = sum(N);
expected = Ntot/length(N);
if userules && (isnan(expected) || expected < 5)
    warning('dg_chi2test2:lt5', ...
        'The expected count per bin is less than 5.' );
    significance = NaN;
    return
end
df = length(N) - 1;
for col = (1:length(N))
    if df == 1
        % Use Yates correction
        chi2 = chi2 + ...
            (abs(N(col) - expected) - 0.5 )^2 / expected;
    else
        % No Yates correction
        chi2 = chi2 + (N(col) - expected)^2 / expected;
    end
end
significance = 1-chi2cdf(chi2,df);
