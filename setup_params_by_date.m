% set up processing parameters depending on survey date. These need to be
% set manually after each survey.
%
% - filename: paths and name of rsk file
% - gps_path: path to gps file
% - tau: thermistor time response, typically either 1s or 0.1s depending on the instrument
% - kvalue: k-value multiplier to correct for nose guard effect on conductivity (1 for EcoCTD since it was calibrated with the nose cone)
% - useO2: 1 if we had O2 sensor, 0 otherwise
% - usechl: 1 if we had fluorometer, 0 otherwise
% - userhod: 1 if we had rhodamine sensor, 0 otherwise
% - tmpstr: name of temperature channel in rsk file. For EcoCTD, it's 'Temperature1'; for other instruments, it's typically just 'Temperature'. Check this in the rsk file.
% - apr2023: turn on for april 2023a survey only. This triggers using an additional function for stitching two gps files together
% - apr2022: turn on for april 2022 survey only. This triggers using an additional function for stitching two gps files together
% - tr_inds: a struct with the indices of each transect ("north","mid","south","long", or "narrows")
% - TC_inds: indices of the raw time series (from .rsk) corresponding to the Tufts Cove sub-survey. Usually it's easiest to extract this from the pressure time series, e.g. plot rsk.data.values(:,3)
% - badS_inds: bad salinity indices, due to sediment clogged in the sensor, or sensor malfunction. These indices correspond to profiles. NaN if all indices are fine.
%
% RY may 2023 originally; lots of modifications since then

function [filename,gps_path,tau,kvalue,useO2,usechl,userhod,tmpstr,apr2023,apr2022,...
          tr_inds,TC_inds,badS_inds] = setup_params_by_date(surveydate)

if strcmp(surveydate,'2021-12')
    %     filename = % need to sort this out (two files together)
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2021_12/GPS_track.gpx'; % won't work, don't have GPS data yet
    tau = 1;
    kvalue = 1;  % need to change
    useO2 = 0;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = NaN;
    tr_inds.mid = NaN;
    tr_inds.south = NaN;
    tr_inds.long = NaN;
    tr_inds.narrows = NaN;
    TC_inds = [NaN NaN];
    badS_inds = NaN;

elseif strcmp(surveydate,'2022-02')
    %     filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2022_02/Level0/066089_20220222_1638.rsk';
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2022_02/Level0/066089_20220222_1323.rsk'; % also need this path! stitch together .rsk files somehow.
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2022_02/GPS/GPS_track.gpx';
    tau = 0.1;
    kvalue = 1;  % need to change
    useO2 = 0;
    usechl = 1;
    userhod = 0;
    tmpstr = 'Temperature';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = 92:100;
    tr_inds.mid = 111:121;
    tr_inds.south = 122:136;
    tr_inds.long = 4:52;
    tr_inds.narrows = NaN;
    TC_inds = [NaN NaN];
    badS_inds = NaN;

elseif strcmp(surveydate,'2022-04')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2022_04/LEVEL0/066089_20220411_2052.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2022_04/BB_survey_Apr2022.gpx';
    tau = 0.1;
    kvalue = 1;  % need to change
    useO2 = 0;
    usechl = 1;
    userhod = 0;
    tmpstr = 'Temperature';
    apr2023 = 0;
    apr2022 = 1;
    tr_inds.north = 138:150;
    tr_inds.mid = NaN;
    tr_inds.south = 151:164;
    tr_inds.long = 4:137;
    tr_inds.narrows = NaN;
    TC_inds = [137604 177181];
    badS_inds = NaN;

elseif strcmp(surveydate,'2022-05')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2022_05/LEVEL0/066089_20220519_0918.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2022_05/GPS_track.gpx';
    tau = 0.1;
    kvalue = 1;  % need to change
    useO2 = 0;
    usechl = 1;
    userhod = 0;
    tmpstr = 'Temperature';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = NaN;
    tr_inds.mid = NaN;
    tr_inds.south = NaN;
    tr_inds.long = 1:31;
    tr_inds.narrows = NaN;
    TC_inds = [17324 46812];
    badS_inds = NaN;

elseif strcmp(surveydate,'2022-06')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2022_06/LEVEL0/060669_20220615_1245.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2022_06/GPS_track.gpx';
    tau = 1;
    kvalue = 1;  % need to change
    useO2 = 0;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = NaN;
    tr_inds.mid = NaN;
    tr_inds.south = NaN;
    tr_inds.long = 1:72;
    tr_inds.narrows = NaN;
    TC_inds = [272200 321459];
    badS_inds = NaN;


elseif strcmp(surveydate,'2022-08a')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2022_08a/LEVEL0/060672_20220805_1600.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2022_08a/gpstrack.gpx';
    tau = 0.1;
    kvalue = 1;  % need to change
    useO2 = 0;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = NaN;
    tr_inds.mid = NaN;
    tr_inds.south = NaN;
    tr_inds.long = 1:104;
    tr_inds.narrows = NaN;
    TC_inds = [159915 168828];
    badS_inds = 1:104;


elseif strcmp(surveydate,'2022-08b')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2022_08b/LEVEL0/060672_20220823_1045.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2022_08b/gps_track.gpx';
    tau = 0.1;
    kvalue = 1;  % need to change
    useO2 = 0;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = NaN;
    tr_inds.mid = NaN;
    tr_inds.south = NaN;
    tr_inds.long = 1:76;
    tr_inds.narrows = 77:84;
    TC_inds = [84194 102918];
    badS_inds = 1:84;


elseif strcmp(surveydate,'2022-10')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2022_10/Level0/060672_20221107_1510.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2022_10/gps_track.gpx';
    tau = 0.1;
    kvalue = 1;  % need to change
    useO2 = 0;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = NaN;
    tr_inds.mid = NaN;
    tr_inds.south = NaN;
    tr_inds.long = 1:142;
    tr_inds.narrows = NaN;
    TC_inds = [326713 342851];
    badS_inds = 1:142;


elseif strcmp(surveydate,'2023-01')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_01/Level0/211745_20230110_1424.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_01/GPS/gps_track.gpx';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature1';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = NaN;
    tr_inds.mid = 1:13;
    tr_inds.south = NaN;
    tr_inds.long = 14:113;
    tr_inds.narrows = NaN;
    TC_inds = [36279 46132];
    badS_inds = NaN;


elseif strcmp(surveydate,'2023-02')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_02/Level0/211745_20230301_2201.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_02/GPS/gps_track.gpx';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature1';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = 105:116;
    tr_inds.mid = NaN;
    tr_inds.south = 117:128;
    tr_inds.long = 1:97;
    tr_inds.narrows = 129:131;
    TC_inds = [259693 267255];
    badS_inds = 20:49;



elseif strcmp(surveydate,'2023-03')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_03/Level0/211745_20230331_1526.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_03/GPS/gps_track.gpx';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature1';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = 1:6;
    tr_inds.mid = 7:21;
    tr_inds.south = 39:56;
    tr_inds.long = 57:172;
    tr_inds.narrows = NaN;
    TC_inds = [NaN NaN];
    badS_inds = [4 47 48 81];


elseif strcmp(surveydate,'2023-04a')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_04/Level0/211745_20230425_1056.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_04/GPS/RY_gps.gpx';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature1';
    apr2023 = 1;
    apr2022 = 0;
    tr_inds.north = 1:11;
    tr_inds.mid = 12:23;
    tr_inds.south = 24:39;
    tr_inds.long = 43:201;
    tr_inds.narrows = NaN;
    TC_inds = [99650 105944];
    badS_inds = [31 43 73 88 157];


elseif strcmp(surveydate,'2023-04b')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_04_exttransect/Level0/211745_20230427_1233.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_04_exttransect/GPS/RY_gps.gpx';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature1';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = NaN;
    tr_inds.mid = NaN;
    tr_inds.south = NaN;
    tr_inds.long = 1:189;
    tr_inds.narrows = NaN;
    TC_inds = [NaN NaN];
    badS_inds = [91:94 96:102 104:105 109 111:113 131:136 140:141 155];

elseif strcmp(surveydate,'2023-05')
    filename = 'example_data/211745_20230516_1601.rsk';
    gps_path = 'example_data/EFE680A8-CC8D-4C15-9979-83F65FB6BF8A_20230516_0902.gpx';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature1';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = 1:15;
    tr_inds.mid = 16:29;
    tr_inds.south = 30:41;
    tr_inds.long = 55:185;
    tr_inds.narrows = NaN;
    TC_inds = [108944 117656];
    badS_inds = [38 143 154:155 159:165 169:170];

elseif strcmp(surveydate,'2023-06')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_06/Level0/211745_20230622_1014.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_06/GPS/AC6EBAF6-5670-40CE-AACA-9217B3206BE5_20230622_0844.gpx';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature1';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = 112:125;
    tr_inds.mid = 99:111;
    tr_inds.south = 126:142;
    tr_inds.long = [flip(143:201) 1:98]; % note transect is discontinuous; when plotting, should specify break getween profiles 1 and 143 (that is, put vertical line at tr_inds.long(99))
    tr_inds.narrows = NaN;
    TC_inds = [NaN NaN];
    badS_inds = [144:163 179];

elseif strcmp(surveydate,'2023-07')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_07/Level0/211745_20230725_1047.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_07/GPS/AC6EBAF6-5670-40CE-AACA-9217B3206BE5_20230725_0851.gpx';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature1';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = 1:14;
    tr_inds.mid = 15:26;
    tr_inds.south = 27:42;
    tr_inds.long = 45:192; 
    tr_inds.narrows = NaN;
    TC_inds = [229379 236362];
    badS_inds = [9 27 37:42 86 143 179];


elseif strcmp(surveydate,'2023-08_dyeday-1')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/dye_release_code/day-1_aug/211745_20230808_1018.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/dye_release_code/day-1_aug/EFE680A8-CC8D-4C15-9979-83F65FB6BF8A_20230808_0909.gpx';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 1;
    tmpstr = 'Temperature1';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = 1:25; % actually, the transect from McNabs to the western shoreline
    tr_inds.mid = 26:43; % actually the transect from Point Pleasant to McNabs
    tr_inds.south = 44:50; % actually the transect from the eastern side of McNabs to the shoreline
    tr_inds.long = 51:180; % note transect is discontinuous; when plotting, should specify break getween profiles 1 and 143 (that is, put vertical line at tr_inds.long(99))
    tr_inds.narrows = 181:208; % actually a bunch of shallow profiles in the narrows near Tufts Cove
    TC_inds = [NaN NaN];
    badS_inds = [26:28 73:74];

elseif strcmp(surveydate,'2023-08_dyeday0')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/dye_release_code/day0_aug/211745_20230810_1820.rsk';
    % filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/dye_release_code/day-1/211745_20230808_1018.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/dye_release_code/day0_aug/Eastcom_GPStrack_Aug10_DA.gpx';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 1;
    tmpstr = 'Temperature1';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = NaN; 
    tr_inds.mid = NaN; 
    tr_inds.south = NaN; 
    tr_inds.long = 1:531; 
    tr_inds.narrows = NaN; 
    TC_inds = [NaN NaN];
    badS_inds = 260;

elseif strcmp(surveydate,'2023-08')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_08/Level0/211745_20230831_1549.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_08/GPS/13954C6B-FCF8-472E-895F-64408048E113_20230831_0859';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature1';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = 39:54; 
    tr_inds.mid = 23:38; 
    tr_inds.south = 6:22; 
    tr_inds.long = 55:187; 
    tr_inds.narrows = NaN; 
    TC_inds = [5983 18989];
    badS_inds = [22 92];

    elseif strcmp(surveydate,'2023-09_dyeday0')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/dye_release_code/day0_sep/211745_20230912_1823.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/dye_release_code/day0_sep/GPS_Track_DA_20230912_0921';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 1;
    tmpstr = 'Temperature1';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = NaN;
    tr_inds.mid = NaN; 
    tr_inds.south = NaN; 
    tr_inds.long = 1:426; % just ALL the inds; but need to classify it as a transect in order for make_maps.m to work ; 
    tr_inds.narrows = NaN; 
    TC_inds = [NaN NaN];
    badS_inds = NaN;

    elseif strcmp(surveydate,'2023-09')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_09/Level0/211745_20230925_1617.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_09/GPS/new-track-2023-09-25-091332';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature1';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = 30:45; 
    tr_inds.mid = 20:29; 
    tr_inds.south = 3:19; 
    tr_inds.long = 46:194; 
    tr_inds.narrows = NaN; 
    TC_inds = [31714 40745];
    badS_inds = NaN;

elseif strcmp(surveydate,'2023-10_dyeday0')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/dye_release_code/day0_oct/Oct-3-2023.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/dye_release_code/day0_oct/GPS_track_DA_20231003_0900.gpx';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 1;
    tmpstr = 'Temperature1';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = NaN;
    tr_inds.mid = NaN; 
    tr_inds.south = NaN; 
    tr_inds.long = 1:426; % just ALL the inds; but need to classify it as a transect in order for make_maps.m to work ; 
    tr_inds.narrows = NaN; 
    TC_inds = [NaN NaN];
    badS_inds = 15:193;

elseif strcmp(surveydate,'2023-10')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_10/Level0/211745_20231023_1056.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_10/GPS/13954C6B-FCF8-472E-895F-64408048E113_20231023_0903.gpx';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature1';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = NaN;
    tr_inds.mid = NaN; 
    tr_inds.south = NaN; 
    tr_inds.long = 1:78; 
    tr_inds.narrows = NaN; 
    TC_inds = [NaN NaN];
    badS_inds = [4:22 24:25 27:33 35:36 38 48 52:53 56 60:61 64:66 70:76];

elseif strcmp(surveydate,'2023-11early')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_11early/Level0/211745_20231103_1346.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_11early/GPS/track-2023-11-03-112116.gpx';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature1';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = NaN;
    tr_inds.mid = NaN;
    tr_inds.south = NaN;
    tr_inds.long = 1:156;
    tr_inds.narrows = NaN;
    TC_inds = [NaN NaN];
    badS_inds = NaN;

elseif strcmp(surveydate,'2023-11later')
    filename = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_11later/Level0/211745_20231124_1224.rsk';
    gps_path = '/Users/rubyyee/Documents/MSc/BB_circulation/basin_survey/2023_11later/GPS/13954C6B-FCF8-472E-895F-64408048E113_20231124_0848.gpx';
    tau = 0.1;
    kvalue = 1;
    useO2 = 1;
    usechl = 0;
    userhod = 0;
    tmpstr = 'Temperature1';
    apr2023 = 0;
    apr2022 = 0;
    tr_inds.north = 155:169;
    tr_inds.mid = 170:184;
    tr_inds.south = 185:203;
    tr_inds.long = 1:153;
    tr_inds.narrows = NaN;
    TC_inds = [NaN NaN];
    badS_inds = 78;


end


end
