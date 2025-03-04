## Copyright (C) 1995-2015 Kurt Hornik
## Copyright (C) 2016 Dag Lyberg
## Copyright (C) 2023 Andreas Bertsatos <abertsatos@biol.uoa.gr>
##
## This file is part of Octave.
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
## @deftypefn  {statistics} {@var{y} =} burrpdf (@var{x}, @var{a}, @var{c}, @var{k})
##
## Burr type XII probability density function (PDF).
##
## For each element of @var{x}, compute the probability density function (PDF)
## at @var{x} of the Burr type XII distribution with parameters @var{a},
## @var{c}, and @var{k}.  The size of @var{y} is the common size of @var{x},
## @var{a}, @var{c}, and @var{k}.  A scalar input functions as a constant matrix
## of the same size as the other inputs.
##
## @seealso{burrcdf, burrinv, burrrnd}
## @end deftypefn

function y = burrpdf (x, a, c, k)

  if (nargin != 4)
    print_usage ();
  endif

  if (! isscalar (x) || ! isscalar (a) || ! isscalar (c) || ! isscalar (k))
    [retval, x, a, c, k] = common_size (x, a, c, k);
    if (retval > 0)
      error ("burrpdf: X, ALPHA, C, AND K must be of common size or scalars.");
    endif
  endif

  if (iscomplex (x) || iscomplex(a) || iscomplex (c) || iscomplex (k))
    error ("burrpdf: X, ALPHA, C, AND K must not be complex.");
  endif

  if (isa (x, "single") || isa (a, "single") ...
      || isa (c, "single") || isa (k, "single"))
    y = zeros (size (x), "single");
  else
    y = zeros (size (x));
  endif

  j = isnan (x) | ! (a > 0) | ! (c > 0) | ! (k > 0);
  y(j) = NaN;

  j = (x > 0) & (0 < a) & (a < Inf) & (0 < c) & (c < Inf) ...
       & (0 < k) & (k < Inf);
  if (isscalar (a) && isscalar (c) && isscalar(k))
    y(j) = (c * k / a) .* (x(j) / a).^(c-1) ./ ...
           (1 + (x(j) / a).^c).^(k + 1);
  else
    y(j) = (c(j) .* k(j) ./ a(j) ).* x(j).^(c(j)-1) ./ ...
           (1 + (x(j) ./ a(j) ).^c(j) ).^(k(j) + 1);
  endif

endfunction


%!shared x,y
%! x = [-1, 0, 1, 2, Inf];
%! y = [0, 0, 1/4, 1/9, 0];
%!assert (burrpdf (x, ones(1,5), ones (1,5), ones (1,5)), y)
%!assert (burrpdf (x, 1, 1, 1), y)
%!assert (burrpdf (x, [1, 1, NaN, 1, 1], 1, 1), [y(1:2), NaN, y(4:5)])
%!assert (burrpdf (x, 1, [1, 1, NaN, 1, 1], 1), [y(1:2), NaN, y(4:5)])
%!assert (burrpdf (x, 1, 1, [1, 1, NaN, 1, 1]), [y(1:2), NaN, y(4:5)])
%!assert (burrpdf ([x, NaN], 1, 1, 1), [y, NaN])

## Test class of input preserved
%!assert (burrpdf (single ([x, NaN]), 1, 1, 1), single ([y, NaN]))
%!assert (burrpdf ([x, NaN], single (1), 1, 1), single ([y, NaN]))
%!assert (burrpdf ([x, NaN], 1, single (1), 1), single ([y, NaN]))
%!assert (burrpdf ([x, NaN], 1, 1, single (1)), single ([y, NaN]))

## Test input validation
%!error burrpdf ()
%!error burrpdf (1)
%!error burrpdf (1,2)
%!error burrpdf (1,2,3)
%!error burrpdf (1,2,3,4,5)
%!error burrpdf (ones (3), ones (2), ones(2), ones(2))
%!error burrpdf (ones (2), ones (3), ones(2), ones(2))
%!error burrpdf (ones (2), ones (2), ones(3), ones(2))
%!error burrpdf (ones (2), ones (2), ones(2), ones(3))
%!error burrpdf (i, 2, 2, 2)
%!error burrpdf (2, i, 2, 2)
%!error burrpdf (2, 2, i, 2)
%!error burrpdf (2, 2, 2, i)

