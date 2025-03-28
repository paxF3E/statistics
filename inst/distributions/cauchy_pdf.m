## Copyright (C) 2012 Rik Wehbring
## Copyright (C) 1995-2016 Kurt Hornik
## Copyright (C) 2023 Andreas Bertsatos <abertsatos@biol.uoa.gr>
##
## This program is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {statistics} {@var{y} =} cauchy_pdf (@var{x})
## @deftypefnx {statistics} {@var{y} =} cauchy_pdf (@var{x}, @var{location}, @var{scale})
##
## Cauchy probability density function (PDF).
##
## For each element of @var{x}, compute the probability density function (PDF)
## at @var{x} of the Cauchy distribution with location parameter @var{location}
## and scale parameter @var{scale}.  The size of @var{y} is the common size of
## @var{x}, @var{location}, and @var{scale}.  A scalar input functions as a
## constant matrix of the same size as the other inputs.
##
## Default values are @var{location} = 0, @var{scale} = 1.
##
## @seealso{cauchy_cdf, cauchy_inv, cauchy_rnd}
## @end deftypefn

function y = cauchy_pdf (x, location = 0, scale = 1)

  if (nargin != 1 && nargin != 3)
    print_usage ();
  endif

  if (! isscalar (location) || ! isscalar (scale))
    [retval, x, location, scale] = common_size (x, location, scale);
    if (retval > 0)
      error (strcat (["cauchy_pdf: X, LOCATION, and SCALE must be of"], ...
                     [" common size or scalars."]));
    endif
  endif

  if (iscomplex (x) || iscomplex (location) || iscomplex (scale))
    error ("cauchy_pdf: X, LOCATION, and SCALE must not be complex.");
  endif

  if (isa (x, "single") || isa (location, "single") || isa (scale, "single"))
    y = NaN (size (x), "single");
  else
    y = NaN (size (x));
  endif

  k = ! isinf (location) & (scale > 0) & (scale < Inf);
  if (isscalar (location) && isscalar (scale))
    y = ((1 ./ (1 + ((x - location) / scale) .^ 2))
              / pi / scale);
  else
    y(k) = ((1 ./ (1 + ((x(k) - location(k)) ./ scale(k)) .^ 2))
              / pi ./ scale(k));
  endif

endfunction


%!shared x,y
%! x = [-1 0 0.5 1 2];
%! y = 1/pi * ( 2 ./ ((x-1).^2 + 2^2) );
%!assert (cauchy_pdf (x, ones (1,5), 2*ones (1,5)), y)
%!assert (cauchy_pdf (x, 1, 2*ones (1,5)), y)
%!assert (cauchy_pdf (x, ones (1,5), 2), y)
%!assert (cauchy_pdf (x, [-Inf 1 NaN 1 Inf], 2), [NaN y(2) NaN y(4) NaN])
%!assert (cauchy_pdf (x, 1, 2*[0 1 NaN 1 Inf]), [NaN y(2) NaN y(4) NaN])
%!assert (cauchy_pdf ([x, NaN], 1, 2), [y, NaN])

## Test class of input preserved
%!assert (cauchy_pdf (single ([x, NaN]), 1, 2), single ([y, NaN]), eps ("single"))
%!assert (cauchy_pdf ([x, NaN], single (1), 2), single ([y, NaN]), eps ("single"))
%!assert (cauchy_pdf ([x, NaN], 1, single (2)), single ([y, NaN]), eps ("single"))

## Cauchy (0,1) == Student's T distribution with 1 DOF
%!test
%! x = rand (10, 1);
%! assert (cauchy_pdf (x, 0, 1), tpdf (x, 1), eps);

## Test input validation
%!error cauchy_pdf ()
%!error cauchy_pdf (1,2)
%!error cauchy_pdf (1,2,3,4)
%!error cauchy_pdf (ones (3), ones (2), ones (2))
%!error cauchy_pdf (ones (2), ones (3), ones (2))
%!error cauchy_pdf (ones (2), ones (2), ones (3))
%!error cauchy_pdf (i, 2, 2)
%!error cauchy_pdf (2, i, 2)
%!error cauchy_pdf (2, 2, i)
