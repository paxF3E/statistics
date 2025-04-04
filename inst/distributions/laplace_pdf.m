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
## @deftypefn  {statistics} {@var{y} =} laplace_pdf (@var{x})
## @deftypefnx {statistics} {@var{y} =} laplace_pdf (@var{x}, @var{mu})
## @deftypefnx {statistics} {@var{y} =} laplace_pdf (@var{x}, @var{mu}, @var{beta})
##
## Laplace probability density function (PDF).
##
## For each element of @var{x}, compute the probability density function (PDF)
## at @var{x} of the Laplace distribution with a location parameter @var{mu} and
## a scale parameter (i.e. "diversity") @var{beta}.  The size of @var{y} is the
## common size of @var{x}, @var{mu}, and @var{beta}.  A scalar input functions
## as a constant matrix of the same size as the other inputs.
##
## Default values are @var{mu} = 0, @var{beta} = 1.  Both parameters must be
## reals and @var{beta} > 0.  For @var{beta} <= 0, NaN is returned.
##
## @seealso{laplace_cdf, laplace_inv, laplace_rnd}
## @end deftypefn

function y = laplace_pdf (x, mu = 0, beta = 1)

  ## Check for valid number of input arguments
  if (nargin < 1 || nargin > 3)
    print_usage ();
  endif

  ## Check for common size of X, MU, and BETA
  if (! isscalar (x) || ! isscalar (mu) || ! isscalar(beta))
    [retval, x, mu, beta] = common_size (x, mu, beta);
    if (retval > 0)
      error (strcat (["laplace_pdf: X, MU, and BETA must be of"], ...
                     [" common size or scalars."]));
    endif
  endif

  ## Check for X, MU, and BETA being reals
  if (iscomplex (x) || iscomplex (mu) || iscomplex (beta))
    error ("laplace_pdf: X, MU, and BETA must not be complex.");
  endif

  ## Check for appropriate class
  if (isa (x, "single") || isa (mu, "single") || isa (beta, "single"));
    y = NaN (size (x), "single");
  else
    y = NaN (size (x));
  endif

  ## Compute Laplace PDF
  k1 = ((x == -Inf) & (beta > 0)) | ((x == Inf) & (beta > 0));
  y(k1) = 0;

  k = ! k1 & (beta > 0);
  y(k) = exp (- abs (x(k) - mu(k)) ./ beta(k)) ./ (2 .* beta(k));

endfunction


%!shared x, y
%! x = [-Inf -log(2) 0 log(2) Inf];
%! y = [0, 1/4, 1/2, 1/4, 0];
%!assert (laplace_pdf ([x, NaN]), [y, NaN])
%!assert (laplace_pdf (x, 0, [-2, -1, 0, 1, 2]), [nan(1, 3), 0.25, 0])

## Test class of input preserved
%!assert (laplace_pdf (single ([x, NaN])), single ([y, NaN]))

## Test input validation
%!error laplace_pdf ()
%!error laplace_pdf (1, 2, 3, 4)
%!error<laplace_pdf: X, MU, and BETA must be of common size or scalars.> ...
%! laplace_pdf (1, ones (2), ones (3))
%!error<laplace_pdf: X, MU, and BETA must be of common size or scalars.> ...
%! laplace_pdf (ones (2), 1, ones (3))
%!error<laplace_pdf: X, MU, and BETA must be of common size or scalars.> ...
%! laplace_pdf (ones (2), ones (3), 1)
%!error<laplace_pdf: X, MU, and BETA must not be complex.> laplace_pdf (i, 2, 3)
%!error<laplace_pdf: X, MU, and BETA must not be complex.> laplace_pdf (1, i, 3)
%!error<laplace_pdf: X, MU, and BETA must not be complex.> laplace_pdf (1, 2, i)
