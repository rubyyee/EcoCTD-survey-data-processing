% example for how to call the functions that load and process data for each
% survey.
%
% Change 'surveyyr' and 'surveymo' to specify the survey. These names
% correspond to the names used in setup_params_by_date
%
% RY Dec 2023

clear

surveyyr = '2023';
surveymo = '05';
surveydate = [surveyyr '-' surveymo];

% load the necessary parameters, specific each survey
[filename,gps_path,tau,kvalue,useO2,usechl,userhod,tmpstr,apr2023,apr2022,...
   tr_inds,TC_inds,badS_inds] = setup_params_by_date(surveydate);

% run read_and_process_rsk to do all of the processing from the original
% rsk file. Outputs gridded, plot-able data
[Tgrid,SPgrid,Pgrid,O2grid,chlgrid,rhodgrid,longrid,latgrid,dpdtgrid,T,SP,...
    P,O2,chl,rhod,lon,lat,dpdt,time] = read_and_process_rsk(filename,gps_path,tau,kvalue,apr2023,apr2022,...
    useO2,usechl,userhod,tmpstr,badS_inds);