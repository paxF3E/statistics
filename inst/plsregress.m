## Copyright (C) 2012-2019 Fernando Damian Nieuwveldt <fdnieuwveldt@gmail.com>
##
## This file is part of the statistics package for GNU Octave.
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 3
## of the License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {statistics} {[@var{xload}, @var{yload}, @var{xscore}, @var{yscore}, @var{coef}, @var{fitted}] =} plsregress(@var{X}, @var{Y}, @var{NCOMP})
##
## Calculate partial least squares regression using SIMPLS algorithm.
##
## @itemize @bullet
## @item
## @var{X}: Matrix of observations
## @item
## @var{Y}: Is a vector or matrix of responses
## @item
## @var{NCOMP}: number of components used for modelling
## @item
## @var{X} and @var{Y} will be mean centered to improve accuracy
## @end itemize
##
## @subheading References
##
## @enumerate
## @item
## SIMPLS: An alternative approach to partial least squares regression.
## Chemometrics and Intelligent Laboratory Systems (1993)
##
## @end enumerate
## @end deftypefn

function [xload, yload, xscore, yscore, coef, fitted] = plsregress (X, Y, NCOMP)

  if nargout != 6
    print_usage();
  end

  nobs  = rows (X);    # Number of observations
  npred = columns (X); # Number of predictor variables
  nresp = columns (Y); # Number of responses

  if (! isnumeric (X) || ! isnumeric (Y))
    error (strcat (["plsregress: data matrix X and reponse matrix Y must"], ...
                   [" be real matrices."]));
  elseif (nobs != rows (Y))
    error (strcat (["plsregress: number of observations for Data matrix X"], ...
                   [" and Response Matrix Y must be equal."]));
  elseif(! isscalar (NCOMP))
    error ("plsregress: third argument must be a scalar");
  end

  ## Mean centering Data matrix
  Xmeans = mean (X);
  X = bsxfun (@minus, X, Xmeans);

  ## Mean centering responses
  Ymeans = mean (Y);
  Y = bsxfun (@minus, Y, Ymeans);

  S = X'*Y;

  R = P = V = zeros (npred, NCOMP);
  T = U = zeros (nobs, NCOMP);
  Q = zeros (nresp, NCOMP);

  for a = 1:NCOMP
    [eigvec, eigval] = eig (S'*S);        # Y factor weights
    domindex = find (diag (eigval) == max (diag (eigval)));# get max eigenvector
    q  = eigvec(:,domindex);

    r  = S * q;                           # X block factor weights
    t  = X * r;                           # X block factor scores
    t  = t - mean (t);

    nt = sqrt (t' * t);                   # compute norm
    t  = t / nt;
    r  = r / nt;                          # normalize

    p  = X' * t;                          # X block factor loadings
    q  = Y' * t;                          # Y block factor loadings
    u  = Y * q;                           # Y block factor scores
    v  = p;

    ## Ensure orthogonality
    if (a > 1)
      v = v - V * (V' * p);
      u = u - T * (T' * u);
    endif

    v = v/sqrt(v'*v); # normalize orthogonal loadings
    S = S - v*(v'*S); # deflate S wrt loadings

    ## Store data
    R(:,a) = r;
    T(:,a) = t;
    P(:,a) = p;
    Q(:,a) = q;
    U(:,a) = u;
    V(:,a) = v;
  endfor

  ## Regression coefficients
  B = R*Q';

  fitted = bsxfun (@plus, T*Q', Ymeans);  # Add mean

  ## Return
  coef = B;
  xscore      = T;
  xload    = P;
  yscore      = U;
  yload    = Q;
  projection   = R;

endfunction
