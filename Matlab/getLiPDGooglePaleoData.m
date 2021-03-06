function GTS=getLiPDGooglePaleoData(GTS)
checkGoogleTokens;
for ts=1:length(GTS)
    noTSid=0;
    TSid=GTS(ts).paleoData_TSid;
    if length(TSid)==0
        noTSid = 1;
        warning('This TSid field is empty. Shame on you.')
        TSid = createTSID(GTS(ts).paleoData_variableName,GTS(ts).dataSetName,GTS(ts).googleSpreadSheetKey,GTS(ts).paleoData_googleWorkSheetKey);
        warning(['Creating a new TSid... ' TSid ' - I hope we guess righton matching!'])
        GTS(ts).paleoData_TSid=TSid;
    end
    
    TSids=getWorksheetRow(GTS(ts).googleSpreadSheetKey,GTS(ts).paleoData_googleWorkSheetKey,2,aTokenSpreadsheet);
    if noTSid
        firstNoTSid = min(find(cellfun(@isempty,TSids)));
        editWorksheetCell(GTS(ts).googleSpreadSheetKey,GTS(ts).paleoData_googleWorkSheetKey,2,firstNoTSid,TSid,aTokenSpreadsheet)
        warning('Guessed about TSid, assuming missing ones are in order. If theyre not, this wont work.')
    end
    whichCol=find(strcmp(TSid,TSids));
    if isempty(whichCol)
        if length(TSids)==0
            error('Not getting any TSids from paleoData sheet. Maybe wrong worksheet key?')
        end
        if exist('nObs')
            warning(['can''t match the tsid ' TSid '; filling the column with NaNs'])
            GTS(ts).paleoData_values=nan(nObs,1);
        else
            error('I cant do anything if I cant match the first TSid')
        end
    elseif length(whichCol)>1
        error('Duplicate TSids in dataTable')
    else
        colData=getWorksheetColumn(GTS(ts).googleSpreadSheetKey,GTS(ts).paleoData_googleWorkSheetKey,whichCol,aTokenSpreadsheet);
        v=convertCellStringToNumeric(colData(3:end));
        if ischar(v)
            v=cellstr(v);
        end
        GTS(ts).paleoData_values=v;
        nObs = length(v);
    end
end


