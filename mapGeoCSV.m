function mapGeoCSV(procdir)
% MAPGEOCSV(procdir)
%
% Generates map of whole-array MERMAID drifts.
% Requires my OMNIA for subfuncs.
%
% Input:
% procdir      Processed directory (def: $MERMAID/processed3.10/)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 31-Jan-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Default processed dir path.
defval('procdir', fullfile(getenv('MERMAID'), 'processed3.10'))

% Nab all GeoCSV files.
f = globglob(procdir, '**/*geo_DET_REQ.csv');

% Plot [0:360] base map.
figure
fullscreen
plotcont
axis tight
box on
hold on
xlabel('longitude (deg)')
ylabel('latitude (deg)')

% Scatter all floats' drift.
for i = 1:length(f)
    G = readGeoCSV(f{i});
    if isempty(G.Station)
        continue

    end
    kstnm{i} = G.Station{1};
    sc(i) = scatter(longitude360(G.Longitude), G.Latitude);

end
legend(sc, kstnm, 'Location', 'EastOutside')
latimes2
