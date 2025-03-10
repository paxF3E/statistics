## Copyright (C) 2018 John Donoghue
## Copyright (C) 2016 Dag Lyberg
## Copyright (C) 1997-2015 Kurt Hornik
## Copyright (C) 2023 Andreas Bertsatos <abertsatos@biol.uoa.gr>
##
## This file is part of the statistics package for GNU Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {statistics} {@var{y} =} gppdf (@var{x}, @var{shape}, @var{scale}, @var{location})
##
## Generalized Pareto probability density function (PDF).
##
## For each element of @var{x}, compute the probability density function (PDF)
## at @var{x} of the generalized Pareto distribution with parameters
## @var{shape}, @var{scale}, and @var{location}.  The size of @var{y} is the
## common size of @var{x}, @var{shape}, @var{scale}, and @var{location}.  A
## scalar input functions as a constant matrix of the same size as the other
## inputs.
##
## @seealso{gpcdf, gpinv, gprnd, gpfit, gplike, gpstat}
## @end deftypefn

function y = gppdf (x, shape, scale, location)

  if (nargin != 4)
    print_usage ();
  endif

  if (! isscalar (location) || ! isscalar (scale) || ! isscalar (shape))
    [retval, x, location, scale, shape] = ...
      common_size (x, location, scale, shape);
    if (retval > 0)
      error (strcat (["gppdf: X, SHAPE, SCALE, and LOCATION must be of"], ...
                     [" common size or scalars."]));
    endif
  endif

  if (iscomplex (x) || iscomplex (location) || iscomplex (scale) ...
      || iscomplex (shape))
    error ("gppdf: X, SHAPE, SCALE, and LOCATION must not be complex.");
  endif

  if (isa (x, "single") || isa (location, "single") || isa (scale, "single") ...
      || isa (shape, "single"))
    y = zeros (size (x), "single");
  else
    y = zeros (size (x));
  endif

  k = isnan (x) | ! (-Inf < location) | ! (location < Inf) | ...
      ! (scale > 0) | ! (scale < Inf) | ! (-Inf < shape) | ! (shape < Inf);
  y(k) = NaN;

  k = (-Inf < x) & (x < Inf) & (-Inf < location) & (location < Inf) & ...
        (scale > 0) & (scale < Inf) & (-Inf < shape) & (shape < Inf);
  if (isscalar (location) && isscalar (scale) && isscalar (shape))
    z = (x - location) / scale;

    j = k & (shape == 0) & (z >= 0);
    if (any (j))
      y(j) = exp (-z(j));
    endif

    j = k & (shape > 0) & (z >= 0);
    if (any (j))
      y(j) = (shape * z(j) + 1) .^ (-(shape + 1) / shape) ./ scale;
    endif

    if (shape < 0)
      j = k & (shape < 0) & (0 <= z) & (z <= -1. / shape);
      if (any (j))
        y(j) = (shape * z(j) + 1) .^ (-(shape + 1) / shape) ./ scale;
      endif
    endif
  else
    z = (x - location) ./ scale;

    j = k & (shape == 0) & (z >= 0);
    if (any (j))
      y(j) = exp( -z(j));
    endif

    j = k & (shape > 0) & (z >= 0);
    if (any (j))
      y(j) = (shape(j) .* z(j) + 1) .^ (-(shape(j) + 1) ./ shape(j)) ...
                                      ./ scale(j);
    endif

    if (any (shape < 0))
      j = k & (shape < 0) & (0 <= z) & (z <= -1 ./ shape);
      if (any (j))
        y(j) = (shape(j) .* z(j) + 1) .^ (-(shape(j) + 1) ./ shape(j)) ...
                                        ./ scale(j);
      endif
    endif
  endif

endfunction


%!shared x,y1,y2,y3
%! x = [-Inf, -1, 0, 1/2, 1, Inf];
%! y1 = [0, 0, 1, 0.6065306597126334, 0.36787944117144233, 0];
%! y2 = [0, 0, 1, 4/9, 1/4, 0];
%! y3 = [0, 0, 1, 1, 1, 0];
%!assert (gppdf (x, zeros (1,6), ones (1,6), zeros (1,6)), y1, eps)
%!assert (gppdf (x, 0, 1, zeros (1,6)), y1, eps)
%!assert (gppdf (x, 0, ones (1,6), 0), y1, eps)
%!assert (gppdf (x, zeros (1,6), 1, 0), y1, eps)
%!assert (gppdf (x, 0, 1, 0), y1, eps)
%!assert (gppdf (x, 0, 1, [0, 0, 0, NaN, 0, 0]), [y1(1:3), NaN, y1(5:6)])
%!assert (gppdf (x, 0, [1, 1, 1, NaN, 1, 1], 0), [y1(1:3), NaN, y1(5:6)])
%!assert (gppdf (x, [0, 0, 0, NaN, 0, 0], 1, 0), [y1(1:3), NaN, y1(5:6)])
%!assert (gppdf ([x(1:3), NaN, x(5:6)], 0, 1, 0), [y1(1:3), NaN, y1(5:6)])

%!assert (gppdf (x, ones (1,6), ones (1,6), zeros (1,6)), y2, eps)
%!assert (gppdf (x, 1, 1, zeros (1,6)), y2, eps)
%!assert (gppdf (x, 1, ones (1,6), 0), y2, eps)
%!assert (gppdf (x, ones (1,6), 1, 0), y2, eps)
%!assert (gppdf (x, 1, 1, 0), y2, eps)
%!assert (gppdf (x, 1, 1, [0, 0, 0, NaN, 0, 0]), [y2(1:3), NaN, y2(5:6)])
%!assert (gppdf (x, 1, [1, 1, 1, NaN, 1, 1], 0), [y2(1:3), NaN, y2(5:6)])
%!assert (gppdf (x, [1, 1, 1, NaN, 1, 1], 1, 0), [y2(1:3), NaN, y2(5:6)])
%!assert (gppdf ([x(1:3), NaN, x(5:6)], 1, 1, 0), [y2(1:3), NaN, y2(5:6)])

%!assert (gppdf (x, -ones (1,6), ones (1,6), zeros (1,6)), y3, eps)
%!assert (gppdf (x, -1, 1, zeros (1,6)), y3, eps)
%!assert (gppdf (x, -1, ones (1,6), 0), y3, eps)
%!assert (gppdf (x, -ones (1,6), 1, 0), y3, eps)
%!assert (gppdf (x, -1, 1, 0), y3, eps)
%!assert (gppdf (x, -1, 1, [0, 0, 0, NaN, 0, 0]), [y3(1:3), NaN, y3(5:6)])
%!assert (gppdf (x, -1, [1, 1, 1, NaN, 1, 1], 0), [y3(1:3), NaN, y3(5:6)])
%!assert (gppdf (x, [-1, -1, -1, NaN, -1, -1], 1, 0), [y3(1:3), NaN, y3(5:6)])
%!assert (gppdf ([x(1:3), NaN, x(5:6)], -1, 1, 0), [y3(1:3), NaN, y3(5:6)])

## Test class of input preserved
%!assert (gppdf (single ([x, NaN]), 0, 1, 0), single ([y1, NaN]))
%!assert (gppdf ([x, NaN], 0, 1, single (0)), single ([y1, NaN]))
%!assert (gppdf ([x, NaN], 0, single (1), 0), single ([y1, NaN]))
%!assert (gppdf ([x, NaN], single (0), 1, 0), single ([y1, NaN]))

%!assert (gppdf (single ([x, NaN]), 1, 1, 0), single ([y2, NaN]))
%!assert (gppdf ([x, NaN], 1, 1, single (0)), single ([y2, NaN]))
%!assert (gppdf ([x, NaN], 1, single (1), 0), single ([y2, NaN]))
%!assert (gppdf ([x, NaN], single (1), 1, 0), single ([y2, NaN]))

%!assert (gppdf (single ([x, NaN]), -1, 1, 0), single ([y3, NaN]))
%!assert (gppdf ([x, NaN], -1, 1, single (0)), single ([y3, NaN]))
%!assert (gppdf ([x, NaN], -1, single (1), 0), single ([y3, NaN]))
%!assert (gppdf ([x, NaN], single (-1), 1, 0), single ([y3, NaN]))

## Test input validation
%!error gppdf ()
%!error gppdf (1)
%!error gppdf (1,2)
%!error gppdf (1,2,3)
%!error gppdf (1,2,3,4,5)
%!error gppdf (1, ones (2), ones (2), ones (3))
%!error gppdf (1, ones (2), ones (3), ones (2))
%!error gppdf (1, ones (3), ones (2), ones (2))
%!error gppdf (i, 2, 2, 2)
%!error gppdf (2, i, 2, 2)
%!error gppdf (2, 2, i, 2)
%!error gppdf (2, 2, 2, i)

