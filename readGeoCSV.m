function [G, hdr] = readGeoCSV(filename, dtime_fmt, dtime_tzone)
% [G, hdr] = READGEOCSV(filename, dtime_fmt, dtime_tzone)
%
% Input:
% filename             GeoCSV file name
% dtime_fmt            Datetime format (def: 'uuuu-MM-dd''T''HH:mm:ss''Z''')
% dtime_tzone          Datetime timezone (def: 'UTC')
%
% Output:
% G                    Struct with fields dynamically generated from the MethodIdentifiers
% hdr                  Cell array of header strings (comment and metadata lines)
%
% Ex:
%    G = READGEOCSV('P0006.GeoCSV')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 05-Apr-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default datetime specifications.
if ~exist('dtime_fmt', 'var') || isempty(dtime_fmt)
    % IS0 8601 format to seconds precision.
    dtime_fmt = 'uuuu-MM-dd''T''HH:mm:ss''Z''';

end
if ~exist('dtime_tzone', 'var') || isempty(dtime_tzone)
    % IS0 8601 format to seconds precision.
    dtime_tzone = 'UTC';

end

% Read GeoCSV line at a time.
fid = fopen(filename, 'r');
if fid == -1
    error('Cannot read %s. Check path and permissions.', filename)

end

%% ___________________________________________________________________________ %%
%% Read and parse header (COMMENT and METADATA lines)
%% ___________________________________________________________________________ %%
i = 0;
hdr = {};
while true
    % Read a single line of the file.
    l = fgetl(fid);
    i = i + 1;

    % Strip off any quotes that protect non-delimiting delimiters
    % (e.g., "#delimiter: ','").
    l = strrep(l, '"', '');
    l = strrep(l, '''', '');

    % COMMENT lines come before METADATA lines.
    if startsWith(l, '#')
        hdr = [hdr ;  l];
        if startsWith(l, '#delimiter:')
            delimiter = secondSplit(l);

        end
        if startsWith(l, '#lineterminator:')
            lineterminator = secondSplit(l);

        end

    % METADATA lines (the GeoCSV format specifies three) come before DATA lines.
    elseif startsWith(l, 'FieldUnit')

        % Current line: FieldUnit
        funit = strsplit(l, delimiter);

        % Next line: FieldType
        l = fgetl(fid);
        hdr = [hdr ; l];
        i = i + 1;
        ftype = strsplit(l, delimiter);


        % Next line: MethodIdentifier
        l = fgetl(fid);
        hdr = [hdr ; l];
        i = i + 1;
        methid = strsplit(l, delimiter);

        % Next line: DATA (break)
        break

    else
        error('Unrecognized header format: METADATA lines must follow COMMENT lines (see GeoCSV specification)')

    end
end
%% ___________________________________________________________________________ %%

% Determine number of columns to parse, and use that to specify `textscan` format.
if length(funit) ~= length(ftype) || length(ftype) ~= length(methid)
    error('Number of metadata columns differs')


end
num_col = length(funit);
col_fmt = [repmat('%s', [1 num_col]) lineterminator];

%% ___________________________________________________________________________ %%
%% Read and parse DATA lines
%% ___________________________________________________________________________ %%

% Read the remaining DATA lines (the pointer is already in the correct location).
C = textscan(fid, col_fmt, 'Delimiter', delimiter);

% Close the file after finishing the read.
fclose(fid);

% Organize output structure with fieldnames dynamically generated from the
% MethodIdentifiers specified in the header.
G.(methid{1}) = C{1};
for j = 2:num_col
    switch lower(ftype{j})
      case 'datetime'
        G.(methid{j}) = datetime(C{j}, 'Format', dtime_fmt, 'TimeZone', dtime_tzone);

      case 'string'
        % String is a char array.
        G.(methid{j}) = C{j};

      case 'float'
        % Float is cast as double, but likely printed as single.
        G.(methid{j}) = str2double(C{j});

      otherwise
        error('Unrecognized field type: %s', field_type)

    end
    G.([methid{j} 'Unit']) = funit{j};

end
%% ___________________________________________________________________________ %%

%% ___________________________________________________________________________ %%
function s2 = secondSplit(s, d)

% Split string "s" on delimiter ":" (GeoCSV specification) and return second
% substring after split.
s = strsplit(s, ':');
s2 = strtrim(s{2});
