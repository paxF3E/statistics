## Copyright (C) 2006, 2007 Arno Onken <asnelt@asnelt.org>
##
## This file is part of the statistics package for GNU Octave.
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {statistics} {[@var{m}, @var{v}] =} unidstat (@var{n})
##
## Compute mean and variance of the discrete uniform distribution.
##
## @subheading Arguments
##
## @itemize @bullet
## @item
## @var{n} is the parameter of the discrete uniform distribution. The elements
## of @var{n} must be positive natural numbers
## @end itemize
##
## @subheading Return values
##
## @itemize @bullet
## @item
## @var{m} is the mean of the discrete uniform distribution
##
## @item
## @var{v} is the variance of the discrete uniform distribution
## @end itemize
##
## @subheading Example
##
## @example
## @group
## n = 1:6;
## [m, v] = unidstat (n)
## @end group
## @end example
##
## @subheading References
##
## @enumerate
## @item
## Wendy L. Martinez and Angel R. Martinez. @cite{Computational Statistics
## Handbook with MATLAB}. Appendix E, pages 547-557, Chapman & Hall/CRC,
## 2001.
##
## @item
## Athanasios Papoulis. @cite{Probability, Random Variables, and Stochastic
## Processes}. McGraw-Hill, New York, second edition, 1984.
## @end enumerate
## @end deftypefn

function [m, v] = unidstat (n)

  # Check arguments
  if (nargin != 1)
    print_usage ();
  endif

  if (! isempty (n) && ! ismatrix (n))
    error ("unidstat: n must be a numeric matrix");
  endif

  # Calculate moments
  m = (n + 1) ./ 2;
  v = ((n .^ 2) - 1) ./ 12;

  # Continue argument check
  k = find (! (n > 0) | ! (n < Inf) | ! (n == round (n)));
  if (any (k))
    m(k) = NaN;
    v(k) = NaN;
  endif

endfunction

%!test
%! n = 1:6;
%! [m, v] = unidstat (n);
%! expected_m = [1.0000, 1.5000, 2.0000, 2.5000, 3.0000, 3.5000];
%! expected_v = [0.0000, 0.2500, 0.6667, 1.2500, 2.0000, 2.9167];
%! assert (m, expected_m, 0.001);
%! assert (v, expected_v, 0.001);
