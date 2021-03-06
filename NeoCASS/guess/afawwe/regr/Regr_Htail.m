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
%                      Sergio Ricci             <ricci@aero.polimi.it>
%                      Luca Cavagna             <cavagna@aero.polimi.it>
%                      Alessandro De Gaspari    <degaspari@aero.polimi.it>
%                      Luca Riccobene           <riccobene@aero.polimi.it>
%
%  Department of Aerospace Engineering - Politecnico di Milano (DIAPM)
%  Warning: This code is released only to be used by SimSAC partners.
%  Any usage without an explicit authorization may be persecuted.
%
%*******************************************************************************
%
%   Author: <andreadr@kth.se>
%
% Regression analysis modulus applied to horizontal tail.
% 
% Called by:    AFaWWE.m
% 
%
% MODIFICATIONS:
%     DATE        VERS    PROGRAMMER       DESCRIPTION
%     080722      1.0     A. Da Ronch      Creation
%*******************************************************************************
function [str] = Regr_Htail(fid, pdcylin, aircraft, geo, loads, str)

%--------------------------------------------------------------------------------------------------
% Initialize structure:
%--------------------------------------------------------------------------------------------------
str.htail.WSBOX = [];       % Structural weight for structural htail box       [kg], vector
str.htail.WPBOX = [];       % Primary structure for structural htail box       [kg], vector
str.htail.WTBOX = [];       % Total weight for structural htail box            [kg], vector
str.htail.WSC   = [];       % Structural weight for carrythrough structure     [kg], vector
str.htail.WPC   = [];       % Primary structure for carrythrough structure     [kg], vector
str.htail.WTC   = [];       % Total weight for carrythrough structure          [kg], vector
kg2lbs = 2.2046226218487757;
%--------------------------------------------------------------------------------------------------
% TOTAL HT WEIGHT
%--------------------------------------------------------------------------------------------------
if (pdcylin.smartcad.ht_regr)

  fprintf(fid, 'active option: ');

  switch pdcylin.fact.analh

      case 'linear'

          str.htail.WSBOX = 0.9843 .*(str.htail.WBOX);
          str.htail.WPBOX = 1.3442 .*(str.htail.WBOX);
          str.htail.WTBOX = 1.7372 .*(str.htail.WBOX);
  %        str.htail.WSC   = 0.9843 .*(str.htail.WC);
  %        str.htail.WPC   = 1.3442 .*(str.htail.WC);
  %        str.htail.WTC   = 1.7372 .*(str.htail.WC);
          str.htail.WSC   = 0.9843 .*(str.htail.WC);
          str.htail.WPC   = 1.3442 .*(str.htail.WC);
          str.htail.WTC   = str.htail.WPC;

          fprintf(fid, 'linear');

      otherwise

          str.htail.WSBOX = (1.3342/kg2lbs) .*(str.htail.WBOX*kg2lbs).^0.9701;
          str.htail.WPBOX = (2.1926/kg2lbs) .*(str.htail.WBOX*kg2lbs).^0.9534;
          str.htail.WTBOX = (3.7464/kg2lbs) .*(str.htail.WBOX*kg2lbs).^0.9268;
  %        str.htail.WSC   = 1.3342 .*(str.htail.WC)   .^0.9701;
  %        str.htail.WPC   = 2.1926 .*(str.htail.WC)   .^0.9534;
  %        str.htail.WTC   = 3.7464 .*(str.htail.WC)   .^0.9268;    
          str.htail.WSC   = (1.3342/kg2lbs) .*(str.htail.WC*kg2lbs).^0.9701;
          str.htail.WPC   = (2.1926/kg2lbs) .*(str.htail.WC*kg2lbs).^0.9534;
          str.htail.WTC   = str.htail.WPC;    

          fprintf(fid, 'quadratic');

  end
else
  str.htail.WTBOX = str.htail.WBOX;
  str.htail.WTC = str.htail.WC;
end

% Save in the total mass and compute CG along x-axis
wh = 2*sum(str.htail.WTBOX) + str.htail.WTC;
str.htail.CG = (sum(meancouple(geo.htail.x).*str.htail.WTBOX) + geo.htail.x(1)*str.htail.WTC*0.5)/(sum(str.htail.WTBOX) + str.htail.WTC*0.5);
str.M = str.M + wh;
fprintf(fid, '\n\tTotal weight: %7.0f Kg.', wh);
