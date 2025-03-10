## Copyright (C) 2012 Rik Wehbring
## Copyright (C) 1995-2016 Kurt Hornik
## Copyright (C) 2023 Andreas Bertsatos <abertsatos@biol.uoa.gr>
##
## This file is part of the statistics package for GNU Octave.
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
## @deftypefn  {statistics} {@var{p} =} stdnormal_cdf (@var{x})
##
## Standard normal cumulative distribution function (CDF).
##
## For each element of @var{x}, compute the cumulative distribution function
## (CDF) at @var{x} of the standard normal distribution (mean = 0, standard
## deviation = 1).
##
## @seealso{normcdf, stdnormal_inv, stdnormal_pdf, stdnormal_rnd}
## @end deftypefn

function p = stdnormal_cdf (x)

  if (nargin != 1)
    print_usage ();
  endif

  if (iscomplex (x))
    error ("stdnormal_cdf: X must not be complex.");
  endif

  p = erfc (x / (-sqrt(2))) / 2;

endfunction


%!shared x,y
%! x = [-Inf 0 1 Inf];
%! y = [0, 0.5, 1/2*(1+erf(1/sqrt(2))), 1];
%!assert (stdnormal_cdf ([x, NaN]), [y, NaN])

## Test class of input preserved
%!assert (stdnormal_cdf (single ([x, NaN])), single ([y, NaN]), eps ("single"))

## Test input validation
%!error stdnormal_cdf ()
%!error stdnormal_cdf (1,2)
%!error stdnormal_cdf (i)
