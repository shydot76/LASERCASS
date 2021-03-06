%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (C) 2008 - 2011 
% 
% Sergio Ricci (sergio.ricci@polimi.it)
%
% Politecnico di Milano, Dipartimento di Ingegneria Aerospaziale
% Via La Masa 34, 20156 Milano - ITALY
% 
% This file is part of NeoCASS Software (www.neocass.org)
%
% NeoCASS is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public
% License as published by the Free Software Foundation;
% either version 2, or (at your option) any later version.
%
% NeoCASS is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied
% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
% PURPOSE.  See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public
% License along with NeoCASS; see the file GNU GENERAL 
% PUBLIC LICENSE.TXT.  If not, write to the Free Software 
% Foundation, 59 Temple Place -Suite 330, Boston, MA
% 02111-1307, USA.
%

%
%*******************************************************************************
%  SimSAC Project
%
%  NeoCASS
%  Next generation Conceptual Aero Structural Sizing  
%
%                      Sergio Ricci         <ricci@aero.polimi.it>
%                      Luca Cavagna         <cavagna@aero.polimi.it>
%                      Luca Riccobene       <riccobene@aero.polimi.it>
%
%  Department of Aerospace Engineering - Politecnico di Milano (DIAPM)
%  Warning: This code is released only to be used by SimSAC partners.
%  Any usage without an explicit authorization may be persecuted.
%
%*******************************************************************************
%
% MODIFICATIONS:
%     DATE        VERS    PROGRAMMER       DESCRIPTION
%     251111      1.0     L. Cavagna       Creation
%                         
%*******************************************************************************
%
% function guess
%
%   DESCRIPTION: Run GUESS Module from structural sizing to stick model creation
%
%         INPUT: NAME           TYPE       DESCRIPTION
%                C              real       wing box chord
%                H              real       wing box height
%                n_str          int        number of stringers
%                rib_pitch      real       rib pitch
%                E              real       Young modulus
%                Tx             real       horizontal force
%                Ty             real       vertical force
%                Mx             real       bending moment
%                Mz             real       torsional moment
%                CEVAL          array      index of constraints to be used
%                X0             array 3x1  initial solution for the optimization
%
%
%        OUTPUT: NAME           TYPE       DESCRIPTION
%                SOL            array 3x1  solution
%                flag           integer    exit flag
%                fun            real       OBJ value
%                CUNS           array      constraints not satisfied
%
%    REFERENCES:
%
%*******************************************************************************

function [SOL, flag, fun, CUNS] = optim_strut_8(R, L, E, smax,...
                                                       N, Tx, Ty, Mx, Mz, CEVAL, X0)

% INPUT
PRINT = 0;
%-------------------------------------------------------------------------------
% Young modulus
data.param.E = E;
% max tensile stress
data.param.smax = smax;
%-------------------------------------------------------------------------------
% LOADS
data.load.N = N;
data.load.Tx = Tx;
data.load.Ty = Ty;
data.load.Mx = Mx;
data.load.Mz = Mz;
%-------------------------------------------------------------------------------
% GEOMETRY
data.geo.R = R;
data.geo.L = L;
%-------------------------------------------------------------------------------
% INTERNAL PARAMETERS for Z-stringer
%
CUNS = [];
data.param.Cindex = CEVAL;
%
% VARIABLES
% ts
%
% LIMITS

  XL = 0.001;
  XU = R;
  TolCon = 0.00005;
% OPTIONS =optimset('Algorithm','interior-point','MaxFunEvals',25000,'TolCon', 0.005, 'LargeScale', 'off', 'Display', 'off','tolfun',1e-4);
  OPTIONS =optimset('Algorithm','sqp','GradObj', 'on','Display', 'off','MaxFunEvals',500000,'TolCon', TolCon, 'LargeScale', 'off', 'tolfun',1e-9);
  warning off
  try
    [SOL, fun, flag, output] = fmincon(@(X)strut_mass_8(X,data), X0, ...
                               [],[],[],[], ... 
                               XL, XU, @(X)cstr_strut_8(X,data), OPTIONS);
  %
    if (flag<0)
      if PRINT
        fprintf('\n\t\tVariable n. 1: %g.', SOL);
      end
      [CIN, CEQ] = cstr_strut_8(SOL, data);
      if PRINT
        for (k=1:length(CIN))
          fprintf('\n\t\tConstraint n. %d: %g.', k, CIN(k));
        end
      end
      cindex = find(CIN>TolCon);
      if (~isempty(cindex))
        if (isempty(CEVAL))
          CEVAL = [1:length(CIN)];
        end
        CUNS = CEVAL(cindex);
      else
        CUNS = [];
      end
    end
  catch
    flag = -1;
    fun = Inf;
    CUNS = [];
    SOL = X0;
  end
  warning on