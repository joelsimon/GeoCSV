function mapGeoCSV(procdir)
% MAPGEOCSV(procdir)
%
% Generates map of whole-array MERMAID drifts.
% Requires https://github.com/joelsimon/omnia for subfuncs.
% Requires complete processed directory [example not self contained]
%
% Input:
% procdir      Processed directory (def: $MERMAID/processed/)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 26-Feb-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% % Default processed dir path.
% defval('procdir', fullfile(getenv('MERMAID'), 'processed'))

% (or glob everthing from *automaid-v4/ run)
f = globglob('~/mermaid', 'processed_everyone', '**/*geo_DET_REQ.csv');

% Plot [0:360] base map.
figure
fullscreen
plotcont
axis tight
box on
xlabel('longitude (deg)')
ylabel('latitude (deg)')

% Scatter all floats' drift.
hold on
idx = 0;
for i = 1:length(f)
    G = readGeoCSV(f{i});
    if isempty(G.Station)
        continue

    end
    idx = idx + 1;
    kstnm{idx} = G.Station{1};
    sc(idx) = scatter(longitude360(G.Longitude), G.Latitude);

end
hold off
lg = legend(sc, kstnm);
axesfs([], 18, 18)
latimes2
