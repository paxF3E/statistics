## Copyright (C) 2022 Andreas Bertsatos <abertsatos@biol.uoa.gr>
## Copyright (C) 2022 Kai Torben Ohlhus <k.ohlhus@gmail.com>
## Copyright (C) 2023 Nicholas Jankowski <jankowski.nicholas@gmail.com>
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
## @deftypefn  {statistics} {@var{m} =} mean (@var{x})
## @deftypefnx {statistics} {@var{m} =} mean (@var{x}, "all")
## @deftypefnx {statistics} {@var{m} =} mean (@var{x}, @var{dim})
## @deftypefnx {statistics} {@var{m} =} mean (@var{x}, @var{vecdim})
## @deftypefnx {statistics} {@var{m} =} mean (@dots{}, @var{outtype})
## @deftypefnx {statistics} {@var{m} =} mean (@dots{}, @var{nanflag})
##
## Compute the mean of the elements of @var{x}.
##
## @itemize
## @item
## If @var{x} is a vector, then @code{mean(@var{x})} returns the
## mean of the elements in @var{x} defined as
## @tex
## $$ {\rm mean}(x) = \bar{x} = {1\over N} \sum_{i=1}^N x_i $$
##
## @end tex
## @ifnottex
##
## @example
## mean (@var{x}) = SUM_i @var{x}(i) / N
## @end example
##
## @end ifnottex
## @noindent
## where @math{N} is the length of the @var{x} vector.
##
## @item
## If @var{x} is a matrix, then @code{mean(@var{x})} returns a row vector
## with the mean of each columns in @var{x}.
##
## @item
## If @var{x} is a multidimensional array, then @code{mean(@var{x})}
## operates along the first nonsingleton dimension of @var{x}.
## @end itemize
##
## @code{mean (@var{x}, @var{dim})} returns the mean along the operating
## dimension @var{dim} of @var{x}.  For @var{dim} greater than
## @code{ndims (@var{x})}, then @var{m} = @var{x}.
##
## @code{mean (@var{x}, @var{vecdim})} returns the mean over the
## dimensions specified in the vector @var{vecdim}.  For example, if @var{x}
## is a 2-by-3-by-4 array, then @code{mean (@var{x}, [1 2])} returns a
## 1-by-1-by-4 array.  Each element of the output array is the mean of the
## elements on the corresponding page of @var{x}.  If @var{vecdim} indexes all
## dimensions of @var{x}, then it is equivalent to @code{mean (@var{x}, "all")}.
## Any dimension in @var{vecdim} greater than @code{ndims (@var{x})} is ignored.
##
## @code{mean (@var{x}, "all")} returns the mean of all the elements in @var{x}.
## The optional flag "all" cannot be used together with @var{dim} or
## @var{vecdim} input arguments.
##
## @code{mean (@dots{}, @var{outtype})} returns the mean with a specified data
## type, using any of the input arguments in the previous syntaxes.
## @var{outtype} can take the following values:
## @itemize
## @item "default"
## Output is of type double, unless the input is single in which case the output
## is of type single.
##
## @item "double"
## Output is of type double.
##
## @item "native".
## Output is of the same type as the input (@code{class (@var{x})}), unless the
## input is logical in which case the output is of type double or a character
## array in which case an error is produced.
## @end itemize
##
## @code{mean (@dots{}, @var{nanflag})} specifies whether to exclude NaN values
## from the calculation, using any of the input argument combinations in
## previous syntaxes.  By default, NaN values are included in the calculation
## (@var{nanflag} has the value "includenan").  To exclude NaN values, set the
## value of @var{nanflag} to "omitnan".
##
## @seealso{median, mad, mode}
## @end deftypefn

function m = mean (x, varargin)

  if (nargin < 1 || nargin > 4)
    print_usage ();
  endif

  ## Set initial conditions
  all_flag = false;
  omitnan = false;
  out_flag = false;

  nvarg = numel (varargin);
  varg_chars = cellfun ("ischar", varargin);
  outtype = "default";
  szx = size (x);
  ndx = ndims (x);

  if (nvarg > 1 && ! varg_chars(2:end))
    ## Only first varargin can be numeric
    print_usage ();
  endif

  ## Process any other char arguments.
  if (any (varg_chars))
    for argin = varargin(varg_chars)
      switch (lower (argin{:}))
        case "all"
          all_flag = true;

        case "omitnan"
          omitnan = true;

        case "includenan"
          omitnan = false;

        case "default"
          if (out_flag)
            error ("mean: only one OUTTYPE can be specified.")
          endif
          if (isa (x, "single"))
            outtype = "single";
          else
            outtype = "double";
          endif
          out_flag = true;

        case "native"
          outtype = class (x);
          if (out_flag)
            error ("mean: only one OUTTYPE can be specified.")
          elseif (strcmp (outtype, "logical"))
            outtype = "double";
          elseif (strcmp (outtype, "char"))
            error ("mean: OUTTYPE 'native' cannot be used with char type inputs.");
          endif
          out_flag = true;

        case "double"
          if (out_flag)
            error ("mean: only one OUTTYPE can be specified.")
          endif
          outtype = "double";
          out_flag = true;

        otherwise
          print_usage ();
      endswitch
    endfor
    varargin(varg_chars) = [];
    nvarg = numel (varargin);
  endif

  if (strcmp (outtype, "default"))
    if (isa (x, "single"))
      outtype = "single";
    else
      outtype = "double";
    endif
  endif

  if ((nvarg > 1) || ((nvarg == 1) && ! (isnumeric (varargin{1}))))
    ## After trimming char inputs can only be one varargin left, must be numeric
    print_usage ();
  endif

  if (! (isnumeric (x) || islogical (x) || ischar (x)))
    error ("mean: X must be either a numeric, boolean, or character array.");
  endif

  ## Process special cases for input/output sizes
  if (nvarg == 0)
    ## Single numeric input argument, no dimensions given.

    if (all_flag)
      x = x(:);

      if (omitnan)
        x = x(! isnan (x));
      endif

      if (any (isa (x, {"int64", "uint64"})))
        m = int64_mean (x, 1, numel (x), outtype);
      else
        m = sum (x, "double") ./ numel (x);
      endif

    else
      ## Find the first non-singleton dimension.
      (dim = find (szx != 1, 1)) || (dim = 1);
      n = szx(dim);
      if (omitnan)
        idx = isnan (x);
        n = sum (! idx, dim);
        x(idx) = 0;
      endif

      if (any (isa (x, {"int64", "uint64"})))
        m = int64_mean (x, dim, n, outtype);
      else
        m = sum (x, dim, "double") ./ n;
      endif

    endif

  else

    ## Two numeric input arguments, dimensions given.  Note scalar is vector!
    vecdim = varargin{1};
    if (isempty (vecdim) || ! (isvector (vecdim) && all (vecdim > 0)
        && all (rem (vecdim, 1)==0)))
      error ("mean: DIM must be a positive integer scalar or vector.");
    endif

    if (ndx == 2 && isempty (x) && szx == [0,0])
      ## FIXME: This special case handling could be removed once sum
      ##        compatibly handles all sizes of empty inputs.
      sz_out = szx;
      sz_out (vecdim(vecdim <= ndx)) = 1;
      m = NaN (sz_out);
    else

      if (isscalar (vecdim))
        if (vecdim > ndx)
          m = x;
        else
          n = szx(vecdim);
          if (omitnan)
            nanx = isnan (x);
            n = sum (! nanx, vecdim);
            x(nanx) = 0;
          endif

          if (any (isa (x, {"int64", "uint64"})))
            m = int64_mean (x, vecdim, n, outtype);
          else
            m = sum (x, vecdim, "double") ./ n;
          endif

        endif

      else
        vecdim = sort (vecdim);
        if (! all (diff (vecdim)))
           error ("mean: VECDIM must contain non-repeating positive integers.");
        endif
        ## Ignore dimensions in VECDIM larger than actual array
        vecdim(find (vecdim > ndims (x))) = [];

        if (isempty (vecdim))
          m = x;
        else

          ## Calculate permutation vector
          remdims = 1 : ndx;      # All dimensions
          remdims(vecdim) = [];   # Delete dimensions specified by vecdim
          nremd = numel (remdims);

          ## If all dimensions are given, it is equivalent to 'all' flag
          if (nremd == 0)
            x = x(:);
            if (omitnan)
              x = x(! isnan (x));
            endif

            if (any (isa (x, {"int64", "uint64"})))
              m = int64_mean (x, 1, numel (x), outtype);
            else
              m = sum (x, "double") ./ numel (x);
            endif

          else
            ## Permute to push vecdims to back
            perm = [remdims, vecdim];
            x = permute (x, perm);

            ## Reshape to squash all vecdims in final dimension
            sznew = [szx(remdims), prod(szx(vecdim))];
            x = reshape (x, sznew);

            ## Calculate mean on final dimension
            dim = nremd + 1;
            if (omitnan)
              nanx = isnan (x);
              x(nanx) = 0;
              n = sum (! nanx, dim);
            else
              n = sznew(dim);
            endif

            if (any (isa (x, {"int64", "uint64"})))
              m = int64_mean (x, dim, n, outtype);
            else
              m = sum (x, dim, "double") ./ n;
            endif

            ## Inverse permute back to correct dimensions
            m = ipermute (m, perm);
          endif
        endif
      endif
    endif
  endif

  ## Convert output if necessary
  if (! strcmp (class (m), outtype))
    if (! islogical (x))
      m = feval (outtype, m);
    endif
  endif

endfunction

function m = int64_mean (x, dim, n, outtype)
    ## Avoid int overflow in large ints.  Smaller ints processed as double
    ## avoids overflow. Large int64 values as double can have floating pt error.
    ## Use integer math and remainder correction to avoid this.
    if (any (abs (x(:)) >= flintmax / n))
      rmdr = double (rem (x, n)) / n;
      rmdr_hilo = logical (int8 (rmdr)); # Integer rounding direction indicator

      ## Native int summation to prevent double precision error,
      ## then add back in lost round-up/down remainders.

      m = sum (x/n, dim, "native");

      ## rmdr.*!rmdr_hilo = remainders that were rounded down in abs val
      ## signs retained, can be summed and added back.

      ## rmdr.*rmdr_hilo = remainders that were rounded up in abs val.
      ## need to add back difference between 1 and rmdr, retaining sign.

      rmdr = sum (rmdr .* !rmdr_hilo, dim) - ...
                sum ((1 - abs (rmdr)) .* rmdr_hilo .* sign(rmdr), dim);

      if (any (abs (m(:)) >= flintmax))

        if (any (strcmp (outtype, {"int64", "uint64"})))
          m += rmdr;
        else
          m = double (m) + rmdr;
        endif

      else
        m = double(m) + rmdr;
        switch (outtype)
          case "int64"
            m = int64 (m);
          case "uint64"
            m = uint64 (m);
        endswitch
      endif
    else
      m = double (sum (x, dim, "native")) ./ n;
    endif

endfunction

%!test
%! x = -10:10;
%! y = x';
%! z = [y, y+10];
%! assert (mean (x), 0);
%! assert (mean (y), 0);
%! assert (mean (z), [0, 10]);

%!assert (mean (magic (3), 1), [5, 5, 5])
%!assert (mean (magic (3), 2), [5; 5; 5])
%!assert (mean (logical ([1 0 1 1])), 0.75)
%!assert (mean (single ([1 0 1 1])), single (0.75))
%!assert (mean ([1 2], 3), [1 2])

## Test outtype option
%!test
%! in = [1 2 3];
%! out = 2;
%! assert (mean (in, "default"), mean (in));
%! assert (mean (in, "default"), out);
%! assert (mean (in, "double"), out);
%! assert (mean (in, "native"), out);

%!test
%! in = single ([1 2 3]);
%! out = 2;
%! assert (mean (in, "default"), mean (in));
%! assert (mean (in, "default"), single (out));
%! assert (mean (in, "double"), out);
%! assert (mean (in, "native"), single (out));

%!test
%! in = logical ([1 0 1]);
%! out = 2/3;
%! assert (mean (in, "default"), mean (in), eps);
%! assert (mean (in, "default"), out, eps);
%! assert (mean (in, "double"), out, eps);
%! assert (mean (in, "native"), out, eps);

%!test
%! in = char ("ab");
%! out = 97.5;
%! assert (mean (in, "default"), mean (in), eps);
%! assert (mean (in, "default"), out, eps);
%! assert (mean (in, "double"), out, eps);

%!test
%! in = uint8 ([1 2 3]);
%! out = 2;
%! assert (mean (in, "default"), mean (in));
%! assert (mean (in, "default"), out);
%! assert (mean (in, "double"), out);
%! assert (mean (in, "native"), uint8 (out));

%!test
%! in = uint8 ([0 1 2 3]);
%! out = 1.5;
%! out_u8 = 2;
%! assert (mean (in, "default"), mean (in), eps);
%! assert (mean (in, "default"), out, eps);
%! assert (mean (in, "double"), out, eps);
%! assert (mean (in, "native"), uint8 (out_u8));
%! assert (class (mean (in, "native")), "uint8");

%!test # internal sum exceeding intmax
%! in = uint8 ([3 141 141 255]);
%! out = 135;
%! assert (mean (in, "default"), mean (in));
%! assert (mean (in, "default"), out);
%! assert (mean (in, "double"), out);
%! assert (mean (in, "native"), uint8 (out));
%! assert (class (mean (in, "native")), "uint8");

%!test # fractional answer with internal sum exceeding intmax
%! in = uint8 ([1 141 141 255]);
%! out = 134.5;
%! out_u8 = 135;
%! assert (mean (in, "default"), mean (in));
%! assert (mean (in, "default"), out);
%! assert (mean (in, "double"), out);
%! assert (mean (in, "native"), uint8 (out_u8));
%! assert (class (mean (in, "native")), "uint8");

%!test <54567> # large int64 sum exceeding intmax and double precision limit
%! in_same = uint64 ([intmax("uint64") intmax("uint64")-2]);
%! out_same = intmax ("uint64")-1;
%! in_opp = int64 ([intmin("int64"), intmax("int64")-1]);
%! out_opp = -1;
%! in_neg = int64 ([intmin("int64") intmin("int64")+2]);
%! out_neg = intmin ("int64")+1;
%!
%! ## both positive
%! assert (mean (in_same, "default"), mean (in_same));
%! assert (mean (in_same, "default"), double (out_same));
%! assert (mean (in_same, "double"), double (out_same));
%! assert (mean (in_same, "native"), uint64 (out_same));
%! assert (class (mean (in_same, "native")), "uint64");
%!
%! ## opposite signs
%! assert (mean (in_opp, "default"), mean (in_opp));
%! assert (mean (in_opp, "default"), double (out_opp));
%! assert (mean (in_opp, "double"), double (out_opp));
%! assert (mean (in_opp, "native"), int64 (out_opp));
%! assert (class (mean (in_opp, "native")), "int64");
%!
%! ## both negative
%! assert (mean (in_neg, "default"), mean (in_neg));
%! assert (mean (in_neg, "default"), double(out_neg));
%! assert (mean (in_neg, "double"), double(out_neg));
%! assert (mean (in_neg, "native"), int64(out_neg));
%! assert (class (mean (in_neg, "native")), "int64");

## Additional tests int64 and double precision limits
%!test <54567>
%! in = [(intmin('int64')+5), (intmax('int64'))-5];
%! assert (mean (in, "native"), int64(-1));
%! assert (class (mean (in, "native")), "int64");
%! assert (mean (double(in)), double(0) );
%! assert (mean (in), double(-0.5) );
%! assert (mean (in, "default"), double(-0.5) );
%! assert (mean (in, "double"), double(-0.5) );
%! assert (mean (in, "all", "native"), int64(-1));
%! assert (mean (in, 2, "native"), int64(-1));
%! assert (mean (in, [1 2], "native"), int64(-1));
%! assert (mean (in, [2 3], "native"), int64(-1));
%! assert (mean ([intmin("int64"), in, intmax("int64")]), double(-0.5))
%! assert (mean ([in; int64([1 3])], 2, "native"), int64([-1; 2]));

## Test input and optional arguments "all", DIM, "omitnan".
%!test
%! x = [-10:10];
%! y = [x;x+5;x-5];
%! assert (mean (x), 0);
%! assert (mean (y, 2), [0, 5, -5]');
%! assert (mean (y, "all"), 0);
%! y(2,4) = NaN;
%! assert (mean (y', "omitnan"), [0 5.35 -5]);
%! z = y + 20;
%! assert (mean (z, "all"), NaN);
%! assert (mean (z, "all", "includenan"), NaN);
%! assert (mean (z, "all", "omitnan"), 20.03225806451613, 4e-14);
%! m = [20 NaN 15];
%! assert (mean (z'), m);
%! assert (mean (z', "includenan"), m);
%! m = [20 25.35 15];
%! assert (mean (z', "omitnan"), m);
%! assert (mean (z, 2, "omitnan"), m');
%! assert (mean (z, 2, "native", "omitnan"), m');
%! assert (mean (z, 2, "omitnan", "native"), m');

## Test boolean input
%!test
%! assert (mean (true, "all"), 1);
%! assert (mean (false), 0);
%! assert (mean ([true false true]), 2/3, 4e-14);
%! assert (mean ([true false true], 1), [1 0 1]);
%! assert (mean ([true false NaN], 1), [1 0 NaN]);
%! assert (mean ([true false NaN], 2), NaN);
%! assert (mean ([true false NaN], 2, "omitnan"), 0.5);
%! assert (mean ([true false NaN], 2, "omitnan", "native"), 0.5);

## Test char inputs
%!assert (mean ("abc"), double (98))
%!assert (mean ("ab"), double (97.5), eps)
%!assert (mean ("abc", "double"), double (98))
%!assert (mean ("abc", "default"), double (98))

## Test NaN inputs
%!test
%! x = magic (4);
%! x([2, 9:12]) = NaN;
%! assert (mean (x), [NaN 8.5, NaN, 8.5], eps);
%! assert (mean (x,1), [NaN 8.5, NaN, 8.5], eps);
%! assert (mean (x,2), NaN(4,1), eps);
%! assert (mean (x,3), x, eps);
%! assert (mean (x, 'omitnan'), [29/3, 8.5, NaN, 8.5], eps);
%! assert (mean (x, 1, 'omitnan'), [29/3, 8.5, NaN, 8.5], eps);
%! assert (mean (x, 2, 'omitnan'), [31/3; 9.5; 28/3; 19/3], eps);
%! assert (mean (x, 3, 'omitnan'), x, eps);

## Test empty inputs
%!assert (mean ([]), NaN(1,1))
%!assert (mean (single([])), NaN(1,1,"single"))
%!assert (mean ([], 1), NaN(1,0))
%!assert (mean ([], 2), NaN(0,1))
%!assert (mean ([], 3), NaN(0,0))
%!assert (mean (ones(1,0)), NaN(1,1))
%!assert (mean (ones(1,0), 1), NaN(1,0))
%!assert (mean (ones(1,0), 2), NaN(1,1))
%!assert (mean (ones(1,0), 3), NaN(1,0))
%!assert (mean (ones(0,1)), NaN(1,1))
%!assert (mean (ones(0,1), 1), NaN(1,1))
%!assert (mean (ones(0,1), 2), NaN(0,1))
%!assert (mean (ones(0,1), 3), NaN(0,1))
%!assert (mean (ones(0,1,0)), NaN(1,1,0))
%!assert (mean (ones(0,1,0), 1), NaN(1,1,0))
%!assert (mean (ones(0,1,0), 2), NaN(0,1,0))
%!assert (mean (ones(0,1,0), 3), NaN(0,1,1))
%!assert (mean (ones(0,0,1,0)), NaN(1,0,1,0))
%!assert (mean (ones(0,0,1,0), 1), NaN(1,0,1,0))
%!assert (mean (ones(0,0,1,0), 2), NaN(0,1,1,0))
%!assert (mean (ones(0,0,1,0), 3), NaN(0,0,1,0))

## Test dimension indexing with vecdim in N-dimensional arrays
%!test
%! x = repmat ([1:20;6:25], [5 2 6 3]);
%! assert (size (mean (x, [3 2])), [10 1 1 3]);
%! assert (size (mean (x, [1 2])), [1 1 6 3]);
%! assert (size (mean (x, [1 2 4])), [1 1 6]);
%! assert (size (mean (x, [1 4 3])), [1 40]);
%! assert (size (mean (x, [1 2 3 4])), [1 1]);

## Test exceeding dimensions
%!assert (mean (ones (2,2), 3), ones (2,2))
%!assert (mean (ones (2,2,2), 99), ones (2,2,2))
%!assert (mean (magic (3), 3), magic (3))
%!assert (mean (magic (3), [1 3]), [5, 5, 5])
%!assert (mean (magic (3), [1 99]), [5, 5, 5])

## Test results with vecdim in N-dimensional arrays and "omitnan"
%!test
%! x = repmat ([1:20;6:25], [5 2 6 3]);
%! m = repmat ([10.5;15.5], [5 1 1 3]);
%! assert (mean (x, [3 2]), m, 4e-14);
%! x(2,5,6,3) = NaN;
%! m(2,1,1,3) = NaN;
%! assert (mean (x, [3 2]), m, 4e-14);
%! m(2,1,1,3) = 15.52301255230125;
%! assert (mean (x, [3 2], "omitnan"), m, 4e-14);

## Test input case insensitivity
%!assert (mean ([1 2 3], "aLL"), 2)
%!assert (mean ([1 2 3], "OmitNan"), 2)
%!assert (mean ([1 2 3], "DOUBle"), 2)

## Test limits of single precision summation limits on each code path
%!assert <*63848> (mean (ones (80e6, 1, "single")), 1, eps)
%!assert <*63848> (mean (ones (80e6, 1, "single"), "all"), 1, eps)
%!assert <*63848> (mean (ones (80e6, 1, "single"), 1), 1, eps)
%!assert <*63848> (mean (ones (80e6, 1, "single"), [1 2]), 1, eps)
%!assert <*63848> (mean (ones (80e6, 1, "single"), [1 3]), 1, eps)

## Test limits of double precision summation
%!assert <63848> (mean ([flintmax("double"), ones(1, 2^8-1, "double")]), ...
%!                               35184372088833-1/(2^8), eps(35184372088833))

## Test input validation
%!error <Invalid call to mean.  Correct usage is> mean ()
%!error <Invalid call to mean.  Correct usage is> mean (1, 2, 3)
%!error <Invalid call to mean.  Correct usage is> mean (1, 2, 3, 4)
%!error <Invalid call to mean.  Correct usage is> mean (1, "all", 3)
%!error <Invalid call to mean.  Correct usage is> mean (1, "b")
%!error <Invalid call to mean.  Correct usage is> mean (1, 1, "foo")
%!error <OUTTYPE 'native' cannot be used with char> mean ("abc", "native")
%!error <X must be either a numeric, boolean, or character> mean ({1:5})
%!error <DIM must be a positive integer> mean (1, ones (2,2))
%!error <DIM must be a positive integer> mean (1, 1.5)
%!error <DIM must be a positive integer> mean (1, 0)
%!error <DIM must be a positive integer> mean (1, [])
%!error <DIM must be a positive integer> mean (1, -1)
%!error <DIM must be a positive integer> mean (1, -1.5)
%!error <DIM must be a positive integer> mean (1, NaN)
%!error <DIM must be a positive integer> mean (1, Inf)
%!error <DIM must be a positive integer> mean (repmat ([1:20;6:25], [5 2]), -1)
%!error <DIM must be a positive integer> mean (repmat ([1:5;5:9], [5 2]), [1 -1])
%!error <DIM must be a positive integer> mean (1, ones(1,0))
%!error <VECDIM must contain non-repeating> mean (1, [2 2])
