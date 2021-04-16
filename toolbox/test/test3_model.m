% Copyright (C) 2020 Enrico Bertolazzi
%
%
% base class to solve problems of the form:
%
%       minimize    F(X)
%    LB <= X <= UB
%
classdef test3_model < handle

  %% MATLAB class wrapper for the underlying C++ class
  properties (SetAccess = protected, Hidden = true)
    npts;
    x_data;
    y_data;
    population;
    ab;
    min_dx;
  end

  methods
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function self = test3_model( ab, n, x, y, min_dx )
      self.setup( ab, n, x, y, min_dx );
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function setup( self, ab, n, x, y, min_dx )
      self.ab     = ab;
      self.npts   = n;
      self.x_data = x;
      self.y_data = y;
      self.min_dx = min_dx;
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function info( self )
    end
    %
    % S' = -Rt/(N*Tau) * S * I
    % I' = Rt/(N*Tau) * S * I - I / Tau
    % R' = I / Tau
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function [x,y] = get_pars( self, X )
      npts = self.npts;
      x    = X(1:npts);
      y    = X(npts+1:2*npts);
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function res = target( self, X )
      npts = self.npts;
      ab   = self.ab;
      x    = X(1:npts);
      y    = X(npts+1:2*npts);
      res  = 0;
      res1 = 0;
      for k=2:npts
        xa   = x(k-1); xb = x(k);
        ya   = y(k-1); yb = y(k);
        idx  = find( self.x_data >= xa & self.x_data <= xb );
        yy   = ya + ((self.x_data(idx)-xa)/(xb-xa)) .* (yb-ya);
        err  = max( abs(self.y_data(idx)-yy) );
        res  = max([err,res]);
        err  = sum( abs(self.y_data(idx)-yy) );
        res1 = res1 + err;
      end
      res = res + 1000*abs(x(1)-ab(1)) + 1000*abs(x(end)-ab(2));
      res = res - 1000*sum(min(0,diff(x)-self.min_dx));
      res = res + 1e-6*res1;
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function target_plot( self, X, iter )
      clf;
      npts = self.npts;
      x    = X(1:npts);
      y    = X(npts+1:2*npts);
      res  = 0;
      ss   = 0:0.001:1;
      plot( x, y, '-o', 'LineWidth', 3, 'Color', 'black' );
      hold on;
      plot( self.x_data, self.y_data, '-o', 'Color', 'blue' );
      title(sprintf('iter %d',iter));
    end
  end
end
