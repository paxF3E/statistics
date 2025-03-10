## Copyright (C) 1995-2017 Kurt Hornik
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
## @deftypefn  {statistics} {@var{y} =} probit (@var{p})
##
## Probit transformation
##
## Return the probit (the quantile of the standard normal distribution) for
## each element of @var{p}.
##
## @seealso{logit}
## @end deftypefn

function y = probit (p)


  if (nargin != 1)
    print_usage ();
  endif

  y = stdnormal_inv (p);

endfunction


%!assert (probit ([-1, 0, 0.5, 1, 2]), [NaN, -Inf, 0, Inf, NaN])

## Test input validation
%!error probit ()
%!error probit (1, 2)
