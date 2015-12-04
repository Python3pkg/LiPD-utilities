function L=updateLiPDfromGoogle(L)

%make sure it actually has a google file

if ~isfield(L,'googleSpreadSheetKey')
    error('This dataset does not appear to have a google file')
end

%make a ts from the lipd file, that we will update
LTS=extractTimeseriesLiPD(L,1);

%make a google version of the TS file
%metadata first
GTS=getLiPDGoogleMetadata(L.googleSpreadSheetKey,L.googleMetadataWorksheet);
%then grab the data
GTS=getLiPDGooglePaleoData(GTS);

%number columns aren't coming as numbers!!!!!!!

%add in special fields (year, depth, age)
yy=find(strcmpi('year',{GTS.paleoData_variableName}'));
if ~isempty(yy)
    dum=repmat({GTS(yy).paleoData_values},length(GTS),1);
    [GTS.year]=dum{:};
    dum=repmat({GTS(yy).paleoData_units},length(GTS),1);
    [GTS.yearUnits]=dum{:};
end
aa=find(strcmpi('age',{GTS.paleoData_variableName}'));
if ~isempty(aa)
    dum=repmat({GTS(aa).paleoData_values},length(GTS),1);
    [GTS.age]=dum{:};
    dum=repmat({GTS(aa).paleoData_units},length(GTS),1);
    [GTS.ageUnits]=dum{:};
end
dd=find(strcmpi('depth',{GTS.paleoData_variableName}'));
if ~isempty(dd)
    dum=repmat({GTS(dd).paleoData_values},length(GTS),1);
    [GTS.depth]=dum{:};
    dum=repmat({GTS(dd).paleoData_units},length(GTS),1);
    [GTS.depthUnits]=dum{:};
end

%new structure
%start with the old one
NTS=LTS;

%are there any fields that are new?
newFields=setdiff(fieldnames(GTS),fieldnames(LTS));

if length(newFields)>0
    bc=repmat({''},length(NTS),1);
    %then you have to deal with new fields...
    for n=1:length(newFields)
        [NTS.(newFields{n})]=bc{:};
    end
end


%now go through all the fields and replace with google if they changed
anyChanges=0;
gnames=fieldnames(GTS);
for g=1:length(gnames)
    O={NTS.(gnames{g})}';
    N={GTS.(gnames{g})}';
    if ~isequal(O,N)%check to see if it changed,
        anyChanges=1;
        display(['updating ' (gnames{g})])
       [NTS.(gnames{g})]=N{:};
    end
end

L=collapseTS(NTS,1);

   