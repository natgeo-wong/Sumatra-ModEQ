function [] = lighten_RGBcpt(finName,pct)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        lighten_RGBcpt                                %
% lighten GMT rgb cpt                                                  %
%                                                                      %
% INPUT:                                                               %
% finName - GMT cpt file format                                        %
% pct     - how much percentage to lighten.e.g. 10%                    %
%                                                                      %
% OUTPUT:                                                              %
% a new GMT cpt file                                                   %
%                                                                      %
% first created by Lujia Feng Fri May  2 16:30:37 SGT 2014             %
% last modified by Lujia Feng Fri May  2 16:37:09 SGT 2014             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fin = fopen(finName,'r');
%                      1  2  3  4  5  6  7  8
colorsCell = textscan(fin,'%f %f %f %f %f %f %f %f','CommentStyle','#');
colors     = cell2mat(colorsCell);
fclose(fin);

lightened = round(255*pct);
colors(:,[ 2 3 4 6 7 8 ]) = min(colors(:,[ 2 3 4 6 7 8 ])+lightened, 255);

[ ~,basename,~ ] = fileparts(finName);
foutName = [ basename '_lighten' num2str(pct*100,'%2.0f') 'pct.cpt' ];
fout = fopen(foutName,'w');
fprintf(fout,'# output by lighten_RGBcolor.m from %s\n',finName);
fprintf(fout,'# COLOR_MODEL = RGB\n');
fprintf(fout,'%10.0f %6.0f %6.0f %6.0f %10.0f %6.0f %6.0f %6.0f\n',colors');
fclose(fout);
