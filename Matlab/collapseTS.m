function Dnew=collapseTS(TS,yearTS)
%tries to convert a LiPD Timeseries object back into a LiPD Hierarchical
%object
%TS is the TS structure
%yearTS is an optional flag to tripped if your TS includes entries for
%year/age/etc

 if nargin<2
     yearTS=0;
 end

%create a LiPD object for every unique dataSetName
udsn=unique({TS.dataSetName}');

for i=1:length(udsn)
    %find TS entries that match that unique Name
    fts=find(strcmp(udsn{i},{TS.dataSetName}'));
    
    for f=1:length(fts) %make a paleoDataTable entry for each TS
        T=TS(fts(f));
        T=removeEmptyStructureFields(T);
        fT=fieldnames(T);
        
        %base level
        %all the fields that don't have underscores (except year and age)
        b=find(cellfun(@isempty,(strfind(fT,'_'))));
        yi=find(strncmpi('year',fT,4));
        ai=find(strncmpi('age',fT,3));
        yai=union(ai,yi);
        %or depth
        di=find(strncmpi('depth',fT,5));
        yai=union(yai,di);

        b=setdiff(b,yai);
        
        for bi=1:length(b)
            Dnew.(matlab.lang.makeValidName(udsn{i})).(fT{b(bi)})=T.(fT{b(bi)});
        end
        
        %funding
        fun=find(strncmp('funding',fT,7));
        if numel(fun)>0
            Dnew.(matlab.lang.makeValidName(udsn{i})).funding=cell(1,1); %assign cell to funding
            for fin=1:length(fun)
                funVarName=fT{fun(fin)};
                fundNum=str2num(funVarName(8:(strfind(funVarName,'_')-1)));
                if isempty(fundNum)
                    fundNum=1;
                end
                try
                Dnew.(matlab.lang.makeValidName(udsn{i})).funding{fundNum}.(funVarName(strfind(funVarName,'_')+1:end))=T.(fT{fun(fin)});
                catch DO
                                    Dnew.(matlab.lang.makeValidName(udsn{i})).funding{fundNum}.(funVarName(strfind(funVarName,'_')+1:end))=char(T.(fT{fun(fin)}));
                end
            end
        end
        
        
        %pub
        if f==1
            Dnew.(matlab.lang.makeValidName(udsn{i})).pub=cell(1,1); %assign cell to pub
        end
        p=find(strncmp('pub',fT,3));
        for pin=1:length(p)
            pubVarName=fT{p(pin)};
            pubNum=str2num(pubVarName(4:(strfind(pubVarName,'_')-1)));
             if isempty(pubNum)
                    pubNum=1;
             end
            Dnew.(matlab.lang.makeValidName(udsn{i})).pub{pubNum}.(pubVarName(strfind(pubVarName,'_')+1:end))=...
                T.(fT{p(pin)});
        end
        
        %geo
        if f==1
            Dnew.(matlab.lang.makeValidName(udsn{i})).geo=struct; %assign geo to structure
        end
        g=find(strncmp('geo_',fT,4));
        
        for gin=1:length(g)
            geoVarName=fT{g(gin)};
            
            Dnew.(matlab.lang.makeValidName(udsn{i})).geo.(geoVarName(strfind(geoVarName,'_')+1:end))=...
                T.(fT{g(gin)});
        end
        
        
        
        %paleoData
        if f==1
            Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData=struct; %assign paleoData to structure
        end
        pd=find(strncmp('paleoData_',fT,10));
        
        %get or create the name of the relevant paleodata table
        if isfield(T,'paleoData_tableName')
            
            pdName=T.paleoData_tableName;
            TS(fts(f)).paleoData_paleoDataTableName=pdName;
            
        elseif isfield(T,'paleoData_paleoDataTableName')
            pdName=T.paleoData_paleoDataTableName;
            
        else
            pdName='s1';
            T.paleoData_paleoDataTableName='s1';
            TS(fts(f)).paleoData_paleoDataTableName=pdName;
            
        end
        
        
        
        
        %check if this name has been used before - make sure entries are same
        %find all other TS with this dataSetName and paleoData_tableName
        samei=find(strcmp(udsn{i},{TS.dataSetName}') & strcmp(T.paleoData_paleoDataTableName,{TS.paleoData_paleoDataTableName}'));
        if length(samei)>1
            clear dll
            for dl=1:length(samei)
                dll(dl)=length(TS(samei(dl)).paleoData_values);
            end
            
            %if they're not all thesame length, rename all tables including the length
            if length(unique(dll))>1
                pdName=['pdt' num2str(length(T.paleoData_values))];
            end
        end
        
        
        %assign in paleoData Table Name
        
        Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData.(pdName).paleoDataTableName=pdName;
           
        
        %ignore paleodata name from pd
        pd=setdiff(pd,find(strcmp(fT,'paleoData_paleoDataTableName')));
        
        %also handle the google worksheet key differently
        if any(strcmp('paleoData_googWorkSheetKey',fT))
            Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData.(pdName).googWorkSheetKey=T.paleoData_googWorkSheetKey;
            pd=setdiff(pd,find(strcmp(fT,'paleoData_googWorkSheetKey')));
        end
        
        
        %get variablename name
        variableName=matlab.lang.makeValidName(T.paleoData_variableName);
       
        %see if that name has been used already
        alreadyNames=fieldnames(Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData.(pdName));
        %iterate through numbers until it's unique
        aNi=1;
        origName=variableName;
        while any(strcmp(variableName,alreadyNames))
           variableName=[origName num2str(aNi)];
           aNi=aNi+1;
        end
        
        
        
        
        
        %add in the variable
        for pdin=1:length(pd)
            pdVarName=fT{pd(pdin)};
            
            %add in parameter
            Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData.(pdName).(variableName).(pdVarName(strfind(pdVarName,'_')+1:end))=...
                T.(fT{pd(pdin)});
            
            
        end
        
        
        if yearTS % if years are included as TS entries do something new
            
            
        else
            %add year as a column
            yearFlag=0;
            if any(strcmp('year',fT))
                if length(T.year) == length(T.paleoData_values)
                    Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData.(pdName).year.values=T.year;
                    Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData.(pdName).year.units='AD';
                    Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData.(pdName).year.description='Year AD';
                    Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData.(pdName).year.variableName='year';
                    Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData.(pdName).year.dataType='float';
                    yearFlag=1;
                end
            end
            %add age as column
            ageFlag=0;
            if any(strcmp('age',fT))
                %don't add age if it's a different length than the data
                if length(T.age) == length(T.paleoData_values)
                    Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData.(pdName).age.values=T.age;
                    Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData.(pdName).age.units='BP';
                    Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData.(pdName).age.description='Years before present (1950) BP';
                    Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData.(pdName).age.variableName='age';
                    Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData.(pdName).age.dataType='float';
                    ageFlag=1;
                end
            end
            if ~ageFlag && ~yearFlag
                error(['no age or year data in record:' matlab.lang.makeValidName(udsn{i}) '. The linearity (and existence) of time are necessary assumptions in the LiPD framework | a likely problem is that the length of the data does not match the length of the year and/or age vectors'])
            end
        end
        %check for climate interpretation
        if any(strncmp('climateInterpretation_',fT,22))
            ci=find(strncmp('climateInterpretation_',fT,22));
            for cin=1:length(ci)
                ciVarName=fT{ci(cin)};
                
                %add in parameter
                Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData.(pdName).(variableName).climateInterpretation.(ciVarName(strfind(ciVarName,'_')+1:end))=...
                    T.(fT{ci(cin)});
            end
        end
        
        %check for calibration
        if any(strncmp('calibration_',fT,12))
            cai=find(strncmp('calibration_',fT,12));
            for cain=1:length(cai)
                caiVarName=fT{cai(cain)};
                
                %add in parameter
                Dnew.(matlab.lang.makeValidName(udsn{i})).paleoData.(pdName).(variableName).calibration.(caiVarName(strfind(caiVarName,'_')+1:end))=...
                    T.(fT{cai(cain)});
            end
        end
        
    end
    
end

df=fieldnames(Dnew);
if length(df)==1
    Dnew=Dnew.(df{1});
end


