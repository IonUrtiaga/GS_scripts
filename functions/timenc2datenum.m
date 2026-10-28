function time=timenc2datenum(path_nc,time_name)
% Author: Ion Urtiaga-Chasco (2026), ion.urtiaga@ulpgc.es
%Converts time from a net cdf to datenum based on its atributes (ref date, calen
%type,daily/hourly,...)
%% time format coversion
time=ncread(path_nc,time_name);
calen = ncreadatt(path_nc, time_name, 'calendar');
time_ref_attr = ncreadatt(path_nc, time_name, 'units');
parts = split(time_ref_attr, 'since');
time_ref = datenum(strtrim(parts{2}), 'yyyy-mm-dd');
%hourly
if contains(time_ref_attr, 'hours')
    time=time./24;
end
%seconds
if contains(time_ref_attr, 'seconds')
    time=time./24./3600;
end
if any(strcmp(calen,{'365_day','noleap'}))
    time=daynoleap2datenum(time,year(time_ref));
    if day(time_ref)~=1%if it starts at midmonth
        time=time+1-15;
    end
elseif any(strcmp(calen,{'360_day','noleap'}))
    time=daynoleap2datenum(time.*365/360,year(time_ref));
    if day(time_ref)~=1%if it starts at midmonth
        time=time+15;
    end
elseif any(strcmp(calen,{'gregorian','proleptic_gregorian','standard','julian'}))
    time= time + time_ref;
else
    disp(['Diferent calendar:' calen])
end