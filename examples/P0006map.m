function P0006map
% P0006map
%
% Generate scatter plot of MERMAID P0006 lat/lon.
% Requires subfuncs in https://github.com/joelsimon/omnia.
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 05-Nov-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

clc
close all

addpath('..')
G = readGeoCSV('P0006_geo.csv');

figure
fullscreen
plotcont
hold on
xlabel('longitude (deg)')
ylabel('latitude (deg)')
sc = scatter(longitude360(G.Longitude), G.Latitude);
lg = legend(sc, 'P0006');
axesfs([], 18, 18)
axis tight
box on
latimes2
