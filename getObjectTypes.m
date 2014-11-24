% Sign up Sign in
% Explore
% Features
% Enterprise
% Blog
% 
% This repository
% Star 48 Fork 44 PUBLIC openmicroscopy/openmicroscopy
%  tag: v.4.4.8  openmicroscopy / components / tools / OmeroM / src / getObjectTypes.m 
%  sbesson 4 months ago Add function to list OMERO annotation types
% 1 contributor
%  file 27 lines (25 sloc) 1.232 kb EditRawBlameHistory Delete
% 1
% 2
% 3
% 4
% 5
% 6
% 7
% 8
% 9
% 10
% 11
% 12
% 13
% 14
% 15
% 16
% 17
% 18
% 19
% 20
% 21
% 22
% 23
% 24
% 25
% 26
% 27
function types = getObjectTypes()
% GETOBJECTTYPES Return a dictionary of OMERO object types
%
%   types = getObjectTypes() returns a dictionary of OMERO object types.
%
% See also: GETOBJECTS, GETANNOTATIONTYPES

% Copyright (C) 2013 University of Dundee & Open Microscopy Environment.
% All rights reserved.
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

names = {'project', 'dataset', 'image', 'screen', 'plate', 'plateacquisition'};
classnames = {'Project', 'Dataset', 'Image', 'Screen', 'Plate', 'PlateAcquisition'};
types = createObjectDictionary(names, classnames);
%Status API Training Shop Blog About © 2013 GitHub, Inc. Terms Privacy Security Contact 