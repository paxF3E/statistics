## Copyright (C) 2014 Nir Krakauer
##
## This file is part of the statistics package for GNU Octave.
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {statistics} {@var{s} = get} (@var{C}, @var{f})
##
## Get a field, @var{f}, from a @samp{cvpartition} object, @var{C}.
##
## @seealso{@@cvpartition/cvpartition}
## @end deftypefn

function s = get (c, f)
  if (nargin == 1)
    s = c;
  elseif (nargin == 2)
    if (ischar (f))
      switch (f)
        case {"classes", "inds", "n_classes", "NumObservations", "NumTestSets", "TestSize", "TrainSize", "Type"}
          s = eval(["struct(c)." f]);
        otherwise
          error ("get: invalid property %s", f);
      endswitch
    else
      error ("get: expecting the property to be a string");
    endif
  else
    print_usage ();
  endif
endfunction
