pub=D.Africa_ColdAirCave_Sundqvist_2013.pub;

%write a pub object to a cell in bibtex format to be later written to a
%text file

for p = 1:length(pub)
    bib = pub{p};
    
    %if author field is a cell, replace appropriately
    if isfield(bib,'author')
        if iscell(bib.author)
            bib.author=authorCell2BibtexAuthorString(bib.author);
        end
    else
       error('There should really be an author')
    end
        
    
    %find citeKey
    if isfield(bib,'citeKey')
        citeKey=bib.citeKey;
    else
        firstAuthor = bib.author(1:(min(regexp(bib.author,'\W')-1)));
        firstWord = bib.title(1:(min(regexp(bib.title,'\W')-1)));
        citeKey=lower([firstAuthor num2str(bib.pubYear) firstWord]);
    end
    
    %deal with type
    if isfield(bib,'type')
        bibType=bib.type;
        if ~isempty(strfind(bibType,'article'))
                    bibType='article';
        end
    else
        bibType='article';
    end
    
    
    %pub fields to write out. 
    toWrite = {'author','journal','pubYear','publisher','title',...
        'volume','DOI','pages','abstract','keywords','url','issue'};
        
    %bibtex version of those names
    bibNames ={'Author','Journal','Year','Publisher','Title',...
        'Volume','DOI','Pages','Abstract','Keywords','Url','Issue'};
    
    doubleBracket = [0 0 0 0 1 0 0 0 1 0 0 0];
    
    bibOut = cell(1,1);
    
    bibOut{1,1}=['@' bibType '{' citeKey ','];
    j=2;
    for i=1:length(toWrite)
        if isfield(bib,toWrite{i})
            if isnumeric(bib.(toWrite{i}))
                bib.(toWrite{i})=num2str(bib.(toWrite{i}));
            end
            if doubleBracket(i)
                bibOut{j,1}=[bibNames{i} ' = {{' bib.(toWrite{i}) '}},'];
            else
                bibOut{j,1}=[bibNames{i} ' = {' bib.(toWrite{i}) '},'];
            end
            j=j+1;
        end
    end
    lastString =  bibOut{j-1,1};
    lastString(end) = '}';
    bibOut{j-1,1} =  lastString;
    
    bigBib{p,1}=bibOut;
    
    
    
    
    
%     
%     fid = fopen('test.bib','w');
%     for i=1:size(bibOut,1)
%     fprintf(fid,'%s\n',bibOut{i,1});
%     end
%     fclose(fid);
%     
%     
    
        
    end
    