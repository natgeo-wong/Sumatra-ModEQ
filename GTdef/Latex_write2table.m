function [ ] = Latex_write2table(table)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             Latex_write2table.m                             %
% generate latex table for the data                                           %
%                                                                             %
% INPUT:                                                                      %
% table structure                                                             %
% table.position  - table position                                            %
%   = 'head' the beginning of table                                           %
%   = 'body' the body of table                                                %
%   = 'tail' the end of table                                                 %
%   = 'head_body_tail' the whole table                                        %
% table.ftexName      - output file name                        [string]      %
% table.opentype      - open permission 'r' or 'w'              [string]      %
% table.tablenum      - use table name e..g, 'A1'               [string]      %
% table.caption       - table caption                           [string]      %
% table.footnoteCell  - footnote                                [cell]        %
% talbe.footlabelCell - footnote label e.g. a, b, c             [cell]        %
% table.label         - table label                             [string]      %
% table.multiCol      - columns for each heading                [row vector]  %
% table.headCell      - headings for each column                [cell]        %
% table.headnoteCell  - footnote for headings                   [cell]        %
% table.submultiCol   - columns for each subheading             [row vector]  %
% table.subheadCell   - subheadings for each column             [cell]        %
% table.unitCell      - unit                                    [cell]        %
% table.unitnoteCell  - footnote for headings                   [cell]        %
% table.dataCell      - table main body                         [cell]        %
%   = 'nan' print out '-' for no values                                       %
%   = 'space' only print out a space                                          %
% table.printCell    - fprintf output format                    [cell]        %
% table.alignCell    - how to align data for each column        [cell]        %
% table.resize       - resize ratio of table                                  %
%   = [string], then use resizebox, if = '', no need to resize                %
%   = [scalar] between [0 1], then use scalebox, if = nan, no need to scale   %
% table.colspace  - e.g., '8pt'                                 [string]      %
%                                                                             %
% first created by Lujia Feng Mon Jul  7 14:51:58 SGT 2014                    %
% used table structure lfeng Wed Jul  9 10:52:51 SGT 2014                     %
% introduced 'nan' & 'space' for dataCell lfeng Thu Jul 10 13:34:31 SGT 2014  %
% added headnoteCell, unitnoteCell etc lfeng Sat Jul 12 10:23:29 SGT 2014     %
% make resize not hard-coced lfeng Wed Feb  4 13:17:17 SGT 2015               %
% last modified by Lujia Feng Wed Feb  4 13:56:31 SGT 2015                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------------ preparation ------------------------------%
position      = table.position;
ftexName      = table.ftexName;
opentype      = table.opentype;
tablenum      = table.tablenum; 
caption       = table.caption; 
footnoteCell  = table.footnoteCell;
footlabelCell = table.footlabelCell;
label         = table.label;     
multiCol      = table.multiCol;
headCell      = table.headCell;  
headnoteCell  = table.headnoteCell;
submultiCol   = table.submultiCol;
subheadCell   = table.subheadCell;  
unitCell      = table.unitCell;  
unitnoteCell  = table.unitnoteCell;
dataCell      = table.dataCell;  
printCell     = table.printCell;  
alignCell     = table.alignCell; 
resize        = table.resize;
colspace      = table.colspace;

colnum    = sum(multiCol);
headnum   = length(multiCol);

% pre-checking
headsize  = length(headCell);
hnotesize = length(headnoteCell);
if ~isequal(headnum,headsize,hnotesize)
   error('Latex_write2table ERROR: multiCol(=%d), headCell(=%d), and headnoteCell(=%d) must have the same length!',headnum,headsize,hnotesize);
end
unitsize  = length(unitCell);
unotesize = length(unitnoteCell);
datasize  = size((dataCell),2);
typesize  = length(printCell);
alignsize = length(alignCell);
if ~isequal(colnum,unitsize,unotesize,datasize,typesize,alignsize)
   error('Latex_write2table ERROR: sum(multiCol)(=%d), dataCell(=%d), unitCell(=%d), unitnoteCell(=%d), printCell(=%d), and alignCell(=%d) must have the same length!'...
   ,colnum,datasize,unitsize,unotesize,typesize,alignsize);
end

fout = fopen(ftexName,opentype);
if strcmp(opentype,'a') && ~isempty(strfind(position,'head'))
   fprintf(fout,'\\vspace{2pc}\n'); 
end

%------------------------------ table head ------------------------------%
if strfind(position,'head')
   % reset table number from 0
   if ~isempty(tablenum)
      fprintf(fout,'\\setcounter{table}{0}\n'); 
   end
   
   % begin table
   fprintf(fout,'\\begin{table}\n');
   
   % specify table number, e.g., A1
   if ~isempty(tablenum)
      fprintf(fout,'\\tablenum{%s}\n',tablenum); 
   end
   
   % caption
   if ~isempty(caption)
      fprintf(fout,'\\caption{%s}\n',caption);
   end
   
   % alignment
   %fprintf(fout,'\\centering\n');
   
   % space between columns default = 6 pts
   if ~isempty(colspace)
      fprintf(fout,'\\setlength{\\tabcolsep}{%s}\n',colspace);
   end
   
   % resizebox{35pc}{!} or scalebox{0.7}
   % cell alignment
   if ~isempty(resize)
      if ischar(resize)
         fprintf(fout,'\\resizebox{%s}{!}{\n',resize);
      elseif isnumeric(resize)
         fprintf(fout,'\\scalebox{%f}{\n',resize);
      else
         error('Latex_write2table ERROR: resize must be either string or float!');
      end
   end
   
   % begin tabular
   fprintf(fout,'\\begin{tabular}{');
   for ii=1:colnum
      if ii~=colnum
         fprintf(fout,'%s ',alignCell{ii});
      else
         fprintf(fout,'%s',alignCell{ii});
      end
   end
   fprintf(fout,'}\n');
   
   % horizontal tableline
   %fprintf(fout,'\\hline\n');
   fprintf(fout,'\\noalign{\\smallskip}\\hline\\noalign{\\smallskip}\n');

   % headings
   mcolnum = length(multiCol);
   for ii=1:mcolnum
      spancol = multiCol(ii);
      heading = headCell{ii};
      hnote   = headnoteCell{ii};
      if strcmp(heading,'nan')
         fprintf(fout,'\\multicolumn{%.0f}{c}{-}',spancol);
      elseif strcmp(heading,'space')
         fprintf(fout,'\\multicolumn{%.0f}{c}{}',spancol);
      else
         if isempty(regexpi(hnote,'(nan|space)'))
            fprintf(fout,'\\multicolumn{%.0f}{c}{%s\\tablenotemark{%s}}',spancol,heading,hnote);
         else
            fprintf(fout,'\\multicolumn{%.0f}{c}{%s}',spancol,heading);
         end
      end
      if ii~=mcolnum
         fprintf(fout,' & ');
      else
         fprintf(fout,'\\\\\n');
      end
   end
   
   % divider within headings
   if ~isempty(multiCol)
      fprintf(fout,'\\noalign{\\smallskip}\n');
      for ii=1:mcolnum
         if multiCol(ii)~=1
            startcol = sum(multiCol(1:ii-1))+1;
            endcol   = sum(multiCol(1:ii));
            fprintf(fout,'\\cline{%.0f-%.0f}\n',startcol,endcol);
         end
      end
      fprintf(fout,'\\noalign{\\smallskip}\n');
   end

   % unit
   if ~isempty(unitCell)
      for ii=1:colnum
         unit  = unitCell{ii};
         unote = unitnoteCell{ii};
         if strcmp(unit,'nan')
            fprintf(fout,'\\multicolumn{1}{c}{-}');
         elseif ~strcmp(unit,'space')
            if isempty(regexpi(unote,'(nan|space)'))
               fprintf(fout,'\\multicolumn{1}{c}{%s\\tablenotemark{%s}}',unit,unote);
            else
               fprintf(fout,'\\multicolumn{1}{c}{%s}',unit);
            end
         end
         if ii~=colnum
            fprintf(fout,' & ');
         else
            fprintf(fout,'\\\\\n');
         end
      end
   end
   
   % horizontal tableline
   fprintf(fout,'\\noalign{\\smallskip}\\hline\\noalign{\\smallskip}\n');
end


%------------------------------ table body ------------------------------%
if strfind(position,'body')
   % subheadings
   if ~isempty(submultiCol)
      fprintf(fout,'\\\\ [-2ex]\n');
      mcolnum = length(submultiCol);
      for ii=1:mcolnum
         if ii~=mcolnum
            fprintf(fout,'\\multicolumn{%.0f}{c}{%s} & ',submultiCol(ii),subheadCell{ii});
         else
            fprintf(fout,'\\multicolumn{%.0f}{c}{%s} \\\\ [1ex] \n',submultiCol(ii),subheadCell{ii});
         end
      end
   end
   
   % data
   if ~isempty(dataCell)
      rownum = size(dataCell,1);
      for jj=1:rownum
         for ii=1:colnum
            data = dataCell{jj,ii};
            % nan value
            if isnan(data)
               %fprintf(fout,'-');
               fprintf(fout,'\\multicolumn{1}{c}{-}');
            elseif ~strcmp(data,'space')
            % has value
               fprintf(fout,printCell{ii},data);
            end
            if ii~=colnum
               fprintf(fout,' & ');
            else
               fprintf(fout,' \\\\\n');
            end
         end
      end
   end
end

%------------------------------ table tail ------------------------------%
if strfind(position,'tail')
   % horizontal tableline
   fprintf(fout,'\\noalign{\\smallskip}\\hline\\noalign{\\smallskip}\n');
   
   % end tabular
   fprintf(fout,'\\end{tabular}\n');
   
   % resize table
   if ~isempty(resize)
      fprintf(fout,'}\n');
   end
   
   % footnote
   if ~isempty(footnoteCell)
      for ii=1:length(footnoteCell)
         fprintf(fout,'\\tablenotetext{%s}{%s}\n',footlabelCell{ii},footnoteCell{ii});
      end
   end
   
   % label
   if ~isempty(label)
      fprintf(fout,'\\label{%s}\n',label);
   end
   
   % end table
   fprintf(fout,'\\end{table}\n\n\n');
end

fclose(fout);
