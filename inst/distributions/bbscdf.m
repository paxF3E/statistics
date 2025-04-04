## Copyright (C) 1995-2015 Kurt Hornik
## Copyright (C) 2016 Dag Lyberg
## Copyright (C) 2018 John Donoghue
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
## @deftypefn  {statistics} {@var{p} =} bbscdf (@var{x}, @var{shape}, @var{scale}, @var{location})
##
## Birnbaum-Saunders cumulative distribution function (CDF).
##
## For each element of @var{x}, compute the cumulative distribution function
## (CDF) at @var{x} of the Birnbaum-Saunders distribution with parameters
## @var{shape}, @var{scale}, and @var{location}.  The size of @var{p} is the
## common size of @var{x}, @var{shape}, @var{scale}, and @var{location}.  A
## scalar input functions as a constant matrix of the same size as the other
## inputs.
##
## @seealso{bbsinv, bbspdf, bbsrnd}
## @end deftypefn

function p = bbscdf (x, shape, scale, location)

  if (nargin != 4)
    print_usage ();
  endif

  if (! isscalar (x) || ! isscalar (shape) || ! isscalar (scale) ...
                     || ! isscalar (location))
    [retval, x, shape, scale, location] = ...
        common_size (x, shape, scale, location);
    if (retval > 0)
      error (strcat (["bbscdf: X, SHAPE, SCALE, and LOCATION must be of"], ...
                     [" common size or scalars."]));
    endif
  endif

  if (iscomplex (x) || iscomplex (shape) || iscomplex (scale) ...
                    || iscomplex(location))
    error ("bbscdf: X, SHAPE, SCALE, and LOCATION must not be complex.");
  endif

  if (isa (x, "single") || isa (shape, "single") || isa (scale, "single") ...
                        || isa (location, "single"))
    p = zeros (size (x), "single");
  else
    p = zeros (size (x));
  endif

  k = isnan(x) | ! (-Inf < location) | ! (location < Inf) ...
      | ! (scale > 0) | ! (scale < Inf) | ! (shape > 0) | ! (shape < Inf);
  p(k) = NaN;

  k = (x > location) & (x <= Inf) & (-Inf < location) & (location < Inf) ...
      & (0 < scale) & (scale < Inf) & (0 < shape) & (shape < Inf);
  if (isscalar (location) && isscalar(scale) && isscalar(shape))
    a = x(k) - location;
    b = sqrt(a ./ scale);
    p(k) = normcdf ((b - b.^-1) / shape);
  else
    a = x(k) - location(k);
    b = sqrt(a ./ scale(k));
    p(k) = normcdf ((b - b.^-1) ./ shape(k));
  endif
endfunction

## Test results
%!shared x,y
%! x = [-1, 0, 1, 2, Inf];
%! y = [0, 0, 1/2, 0.76024993890652337, 1];
%!assert (bbscdf (x, ones (1,5), ones (1,5), zeros (1,5)), y, eps)
%!assert (bbscdf (x, 1, 1, zeros (1,5)), y, eps)
%!assert (bbscdf (x, 1, ones (1,5), 0), y, eps)
%!assert (bbscdf (x, ones (1,5), 1, 0), y, eps)
%!assert (bbscdf (x, 1, 1, 0), y, eps)
%!assert (bbscdf (x, 1, 1, [0, 0, NaN, 0, 0]), [y(1:2), NaN, y(4:5)], eps)
%!assert (bbscdf (x, 1, [1, 1, NaN, 1, 1], 0), [y(1:2), NaN, y(4:5)], eps)
%!assert (bbscdf (x, [1, 1, NaN, 1, 1], 1, 0), [y(1:2), NaN, y(4:5)], eps)
%!assert (bbscdf ([x, NaN], 1, 1, 0), [y, NaN], eps)

## Test class of input preserved
%!assert (bbscdf (single ([x, NaN]), 1, 1, 0), single ([y, NaN]), eps('single'))
%!assert (bbscdf ([x, NaN], 1, 1, single (0)), single ([y, NaN]), eps('single'))
%!assert (bbscdf ([x, NaN], 1, single (1), 0), single ([y, NaN]), eps('single'))
%!assert (bbscdf ([x, NaN], single (1), 1, 0), single ([y, NaN]), eps('single'))

## Test input validation
%!error bbscdf ()
%!error bbscdf (1)
%!error bbscdf (1,2,3)
%!error bbscdf (1,2,3,4,5)
%!error bbscdf (ones (3), ones (2), ones(2), ones(2))
%!error bbscdf (ones (2), ones (3), ones(2), ones(2))
%!error bbscdf (ones (2), ones (2), ones(3), ones(2))
%!error bbscdf (ones (2), ones (2), ones(2), ones(3))
%!error bbscdf (i, 4, 3, 2)
%!error bbscdf (1, i, 3, 2)
%!error bbscdf (1, 4, i, 2)
%!error bbscdf (1, 4, 3, i)

