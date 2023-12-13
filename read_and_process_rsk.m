% reads in an .rsk file, does some processing, and outputs:
%   - Pgrid: regularly spaced pressure grid, defined in this function, with dimensions Zx1
%   - Tgrid: temperature profiles, gridded to Pgrid, with dimensions ZxN (where N is the number of profiles)
%   - SPgrid: practical salinity profiles, gridded to Pgrid, with dimensions ZxN
%   - O2grid: oxygen saturation percentage profiles, gridded to Pgrid, with dimensions ZxN
%   - rhodgrid: rhodamine concentration profiles in ppb, gridded to Pgrid, with dimensions ZxN
%   - longrid: longitude, with dimensions ZxN
%   - latgrid: latitude, with dimensions ZxN
%   - dpdtgrid: dp/dt, with dimensions ZxN
%   - P: ungridded pressure profiles with dimensions ZZxN
%   - T: ungridded temperature profiles with dimensions ZZxN
%   - SP: ungridded practical salinity profiles with dimensions ZZxN
%   - O2: ungridded oxygen saturation percentage profiles with dimensions ZZxN
%   - rhod: ungridded rhodamine concentration profiles in ppb with dimensions ZZxN
%   - lon: longitude, with dimensions ZZxN
%   - lat: latitude, with dimensions ZZxN
%   - dpdt: dp/dt, with dimensions ZZxN
%   - time (in serial date format) in UTC, with dimensions ZZxN
%
% inputs are all set in setup_params_by_date.m
%
% originally RY May 2023;
% RY modified bad salinity segment detection/rejection Dec 2023

function [Tgrid,SPgrid,Pgrid,O2grid,chlgrid,rhodgrid,longrid,latgrid,...
    dpdtgrid,T,SP,P,O2,chl,rhod,lon,lat,dpdt,time] = ...
    read_and_process_rsk(filename,gps_path,tau,kvalue,apr2023,apr2022,...
    useO2,usechl,userhod,tmpstr,badS_inds)


% LOAD THE RSK FILE
rsk = RSKopen(filename);
rsk = RSKreaddata(rsk);



% REMOVE ZERO HOLDS
if useO2
    rsk = RSKcorrecthold(rsk,'channel',{tmpstr,'Conductivity','Pressure','Dissolved O2'});
elseif usechl
    rsk = RSKcorrecthold(rsk,'channel',{tmpstr,'Conductivity','Pressure','Chlorophyll a'});
else
    rsk = RSKcorrecthold(rsk,'channel',{tmpstr,'Conductivity','Pressure'});
end



% APPLY CT LAG
if tau == 0.1
    lag = -0.045; % EcoCTD
elseif tau == 1
    lag = -0.35;
end

Tcol = getchannelindex(rsk,tmpstr);
rsk.data.values(:,Tcol) = interp1(rsk.data.tstamp,rsk.data.values(:,Tcol),rsk.data.tstamp-lag/86400);
rsk = RSKappendtolog(rsk,['Corrected for C-T lag using \tau = ',num2str(lag),' s']);
clear lag Tcol



% ADD SEA PRESSURE VARIABLE (by estimating atmospheric pressure)
allP = rsk.data.values(:,3);
[N,EDGES] = histcounts(allP,9:0.01:10.3);
mid_edge = (EDGES(2:end) + EDGES(1:end-1))/2;
Patm = mid_edge(find(N == max(N)));

rsk = RSKderiveseapressure(rsk,'patm',Patm);



% LOAD THE GPS DATA
if apr2022
    [GPS] = GPX_stitch_together;
else

    rawGPS = gpxread(gps_path);

    for ii = 1:length(rawGPS.Longitude)
        blop = [rawGPS.Time{ii}(1:10),' ',rawGPS.Time{ii}(12:19)];
        GPS.time(ii) = datenum(blop);
    end; clear ii


    GPS.lon = rawGPS.Longitude;
    GPS.lat = rawGPS.Latitude;

    if apr2023
        [GPS] = gps_apr2023a(GPS); % correct GPS issues using two different files

    end
end

% remove non-unique values from GPS.time (not sure why this happens
% sometimes)
rep = find(diff(GPS.time)==0);

GPS.time(rep) = [];
GPS.lon(rep) = [];
GPS.lat(rep) = [];

% Map GPS coordinates to profiles
time = rsk.data.tstamp;

lon = interp1(GPS.time,GPS.lon,time);
lat = interp1(GPS.time,GPS.lat,time);
data.values= lon;
rsk = RSKaddchannel(rsk,'data',data,'channel','Longitude','unit','degrees');
data.values= lat;
rsk = RSKaddchannel(rsk,'data',data,'channel','Latitude','unit','degrees');

clear lon lat



% COMPUTE DP/DT
dpdt = cat(1,NaN,(rsk.data.values(3:end,3)-rsk.data.values(1:end-2,3))./...
    (rsk.data.tstamp(3:end)-rsk.data.tstamp(1:end-2))/86400,NaN);
data.values= dpdt;
rsk = RSKaddchannel(rsk,'data',data,'channel','fall-rate','unit','dbar/s');

clearvars -except rsk dpdt_smooth tau kvalue useO2 usechl userhod tmpstr jul2023 aug2023_dyerelease aug2023 oct2023_dyerelease badS_inds

rsk = RSKfindprofiles(rsk,'pressureThreshold',7);

idxC = getchannelindex(rsk,'Conductivity');
idxT = getchannelindex(rsk,tmpstr);
idxP = getchannelindex(rsk,'Pressure');
idxPS = getchannelindex(rsk,'Sea Pressure');
idxlon = getchannelindex(rsk,'Longitude');
idxlat = getchannelindex(rsk,'Latitude');
idxfall = getchannelindex(rsk,'fall-rate');



% EXTRACT O2, CHLOROPHYLL, AND/OR RHODAMINE
% always O2 OR chlorophyll
if useO2
    idxO2 = getchannelindex(rsk,'Dissolved O2');
elseif usechl
    idxCh = getchannelindex(rsk,'Chlorophyll a');
end

% sometimes rhodamine
if userhod
    idxrhod = getchannelindex(rsk,'Rhodamine');
end



% EXTRACT DOWNCASTS
blop = 0;
for ii = 1:length(rsk.profiles.downcast.tstart)
    ind = find(rsk.data.tstamp>=rsk.profiles.downcast.tstart(ii) & rsk.data.tstamp<=rsk.profiles.downcast.tend(ii));
    blop = max(blop,length(find(rsk.data.values(ind,4)>=0.5)));
end

% Create empty matrix
T = NaN*ones(blop,ii);
C = NaN*ones(blop,ii);
Pabs = NaN*ones(blop,ii);
P = NaN*ones(blop,ii);
Pnum = NaN*ones(blop,ii);
time = NaN*ones(blop,ii);
lon = NaN*ones(blop,ii);
lat = NaN*ones(blop,ii);
dpdt = NaN*ones(blop,ii);

if useO2
    O2 = NaN*ones(blop,ii);
elseif usechl
    chl = NaN*ones(blop,ii);
end

if userhod
    rhod = NaN*ones(blop,ii);
end

for ii = 1:length(rsk.profiles.downcast.tstart)
    ind = find(rsk.data.tstamp>=rsk.profiles.downcast.tstart(ii) & rsk.data.tstamp<=rsk.profiles.downcast.tend(ii) & rsk.data.values(:,idxPS)>=1.4);

    T(1:length(ind),ii) = rsk.data.values(ind,idxT);
    C(1:length(ind),ii) = rsk.data.values(ind,idxC)*kvalue; % nose guard correction
    Pabs(1:length(ind),ii) = rsk.data.values(ind,idxP);
    P(1:length(ind),ii) = rsk.data.values(ind,idxPS);
    Pnum(1:length(ind),ii) = ii;
    time(1:length(ind),ii) = rsk.data.tstamp(ind);
    lon(1:length(ind),ii) = rsk.data.values(ind(1),idxlon);
    lat(1:length(ind),ii) = rsk.data.values(ind(1),idxlat);
    dpdt(1:length(ind),ii) = rsk.data.values(ind,idxfall);
    if useO2
        O2(1:length(ind),ii) = rsk.data.values(ind,idxO2);
    elseif usechl
        chl(1:length(ind),ii) = rsk.data.values(ind,idxCh);
    end

    if userhod
        rhod(1:length(ind),ii) = rsk.data.values(ind,idxrhod);
    end


end; clear ii



% GET SALINITY FROM CONDUCTIVITY
% sample frequency and smoothing window:
smp_period = rsk.continuous.samplingPeriod; % [ms]
smp_rate = round(1/smp_period*1000); % [hz]
smth_window = 5*tau*smp_rate;

SP = NaN*C;

for jj = 1:width(C)
    Cjj = C(:,jj);
    SP(:,jj) = gsw_SP_from_C(conv2(C(:,jj),ones(smth_window,1)/smth_window,'same'),T(:,jj),P(:,jj)); % multiply by k factor (correct salinity measurement for nose guard)
end



% REMOVE BOTTOM COLLITION SEGMENTS
% (find them based on sudden salinity decrease at end of cast)
for ii = 1:width(SP)

    SPii = SP(:,ii);
    Pii = P(:,ii);
    Pmax = max(Pii);
    [~,ind0] = min(abs(Pii-(Pmax-3))); % index 3dbar above highest recorded pressure
    [~,ind1] = min(abs(Pii-Pmax)); % index at highest recorded pressure

    SPdiff = diff(SPii);

    if ind1 > length(SPdiff)
        ind1 = ind1 - 1; % SPdiff is one index shorter than SPii
    end

    for jj = ind0:ind1
        if SPdiff(jj) <= -0.1 % if salinity decreases by 0.1 psu or more between measurements, remove everything from that this index and below (determined empirically to be best filter criteria)
            SPii(jj:end) = NaN;
        end
    end
    SP(:,ii) = SPii;
end



% REMOVE BAD SALINITY SEGMENTS (due to sediment clogging or sensor malfunction)
if sum(isnan(badS_inds)) == 0
    SP(:,badS_inds) = NaN;
end



% GRID T, SP, (O2, chl) BY BIN AVERAGING
Pgrid = 1.5:0.25:75; % don't use near surface (<1.5dbar)
[Tgrid] = bin_grid(Pgrid,P,T);
[SPgrid] = bin_grid(Pgrid,P,SP);
[dpdtgrid] = bin_grid(Pgrid,P,dpdt);
[longrid] = bin_grid(Pgrid,P,lon);
[latgrid] = bin_grid(Pgrid,P,lat);

if useO2
    [O2grid] = bin_grid(Pgrid,P,O2);
elseif usechl
    [chlgrid] = bin_grid(Pgrid,P,chl);
end

if userhod
    [rhodgrid] = bin_grid(Pgrid,P,rhod);
end

% in the cases where there is no O2 or chl or rhod measured:
if ~useO2
    O2grid = NaN;
    O2 = NaN;
end

if ~usechl
    chlgrid = NaN;
    chl = NaN;
end

if ~userhod
    rhodgrid = NaN;
    rhod = NaN;
end



% FILL T AND S NANS FROM ZERO HOLD CORRECTION
for ii = 1:width(Tgrid)
    Tprof = Tgrid(:,ii);
    Sprof = SPgrid(:,ii);

    % make sure there are real values on either side (not just nan because
    % end of profile). Sometimes there are two NaNs in a row, so need the
    % or statements to catch these.
    for jj = 1:length(Tprof)

        fillinds = [];
        Tfillvals = [];
        Sfillvals = [];

        nani = isnan(Tprof); % nans will be same for S profile

        if jj == 1
            if nani(jj) == 1 && nani(jj+1) == 0 % in the case that first index is nan
                fillinds = [fillinds jj];
                Tfillvals = [Tfillvals Tprof(jj+1)];
                Sfillvals = [Sfillvals Sprof(jj+1)];
            end

            for kk = 1:length(fillinds)
                Tprof(fillinds(kk)) = Tfillvals(kk);
                Sprof(fillinds(kk)) = Sfillvals(kk);
            end

            Tgrid(:,ii) = Tprof;
            SPgrid(:,ii) = Sprof;

        elseif nani(jj) == 1 && prod(nani(jj+1:end)) == 0

            % find out how many nans there are in a row
            count = 0;
            for kk = jj+1:length(nani)
                if nani(kk) == 1
                    count = count + 1;
                else
                    break
                end
            end

            Tfillvals = ((Tprof(jj-1) + Tprof(jj+count+1))/2)*ones(1,count+1);
            Sfillvals = ((Sprof(jj-1) + Sprof(jj+count+1))/2)*ones(1,count+1);

            fillinds = jj:jj+count;

            for kk = 1:length(fillinds)
                Tprof(fillinds(kk)) = Tfillvals(kk);
                Sprof(fillinds(kk)) = Sfillvals(kk);
            end

            Tgrid(:,ii) = Tprof;
            SPgrid(:,ii) = Sprof;

        end
    end
end



