function h = dg_plottick(X, y, size, color)
%DG_PLOTTICK plots tick marks
%dg_plottick(X, Y, size, color)
% Plots tick marks of height <size> at the specified X(k), y coordinates.
% <X> must be a vector.  <y> must be scalar.  <color> can be an RGB triple
% or a Matlab predefined color name.  <h> is a column vector of handles to
% line graphics objects, one handle per tick.

%$Rev: 25 $
%$Date: 2009-03-31 21:56:57 -0400 (Tue, 31 Mar 2009) $
%$Author: dgibson $

y1 = y - size/2;
y2 = y + size/2;
h = zeros(length(X),1);
for k = 1:length(X)
    h(k) = line([X(k) X(k)], [y1 y2], 'Color', color);
end