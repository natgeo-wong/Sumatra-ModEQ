function [ fitobj,gof ] = GPS_fitrneu(functype,rneu,dflag,Deq,Teq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GPS_fitrneu.m				        %
% fit GPS time series use any user-defined function     			%
% quick plot the function and time series					%
% Note: may need to change regression parameters				%
%										%
% INPUT:									% 
% (1) functype - user-defined function used to fit the data			%
%     options = linear, offset, diffrate, exp, ln, log10, log10_offset1  	%
%										%
% (2) rneu = [ day time north east vert northErr eastErr vertErr ] 		%
%     dflag - data flag: 1 means data; 0 means outliers 			%
%     dflag,day,time,north,east,vert,northErr,eastErr,vertErr all column vectors%
%										%
% (3) func - fit function           						%
% e.g. 'GPS_func_log10(t,b,v,O,a,Teq,tau)'					%
%										%
% (4) Deq  - day of the EQ in yearmmdd format [scalar] 				%
%            or [row vector] for log10_offset1 					%
%            need to be converted to Teq in decimal years 			%
%										%
% (5) Teq  - day of the EQ in decimal years [scalar] 				%
% note: specify either (4) or (5)						%
%										%
% OUTPUT: 									%
% (1) fitobj - results returned in fit object					%
% (2) gof    - goodness of fit							%
%										%
% first created by lfeng Wed Jul 27 16:06:54 SGT 2011				%
% added functype lfeng Wed Nov 30 12:58:59 SGT 2011				%
% added log10_offset1 lfeng Fri Dec  2 09:53:27 SGT 2011			%
% added input Teq lfeng Tue Jan 17 02:38:46 SGT 2012				%
% last modified by lfeng Tue Jan 17 02:49:08 SGT 2012				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% open fit toolbox to test
% cftool(rneu(:,2),rneu(:,3));

%------------------------------- Date Preparation -------------------------------
% use only data, not outliers
ind      = find(dflag); 
yearmmdd = rneu(ind,1); 
time     = rneu(ind,2);
% range for displacement
dispMin  = min(min(rneu(ind,3:5)));
dispMax  = max(max(rneu(ind,3:5)));
dispRange = dispMax-dispMin;

% convert Deq to Teq
if ~isempty(Deq) & isempty(Teq)
   len = length(Deq);
   for ii=1:len
      indEQ = find(yearmmdd==Deq(ii));
      if any(indEQ)					
         Teq(ii) = time(indEQ);						% if Deq exists in data
      else
         [ ~,~,Teq(ii) ] = GPS_YEARMMDDtoDCMLYEAR(Deq(ii));	% if Deq not in data
      end
   end
elseif (isempty(Deq) & isempty(Teq)) | (~isempty(Deq) & ~isempty(Teq))
   error('GPS_fitrneu ERROR: specify either Deq or Teq!');
end

% weight for curve fitting
wgt0 = 1./rneu(:,6:8).^2;			% weight is the inverse of squared formal error

%------------------------------- Fitting Preparation -------------------------------
MaxFunEvalsNum = 5000;
MaxIterNum     = 5000;
switch functype
   %%%%%%%%%%%%%% linear %%%%%%%%%%%%%%%
   case 'linear'            % left empty intentionally
   %%%%%%%%%%%%%% offset %%%%%%%%%%%%%%%
   case 'offset'
      func = 'GPS_func_offset(t,b,v,O,Teq)';
      fopt = fitoptions('Method','NonLinearLeastSquares',...
                        'MaxFunEvals',MaxFunEvalsNum,...
                        'MaxIter',MaxIterNum,...
                        'Lower',[ dispMin,-1e3,-dispRange ],...
                        'Upper',[ dispMax, 1e3, dispRange ],...
                        'StartPoint',[ 1,-1,100 ]);
                    
      ft = fittype(func,'indep','t',...
                  'dependent','y',...
                  'problem','Teq',...
                  'coeff',{'b','v','O'},...
                  'options',fopt);

   %%%%%%%%%%%%%% rate change %%%%%%%%%%%%%%%
   case 'diffrate'
      func = 'GPS_func_diffrate(t,b,v1,v2,O,Teq)';
      fopt = fitoptions('Method','NonlinearLeastSquares',...
                        'MaxFunEvals',MaxFunEvalsNum,...
                        'MaxIter',MaxIterNum,...
                        'Lower',[ dispMin,-1e3,-1e3,-dispRange ],...
                        'Upper',[ dispMax, 1e3, 1e3, dispRange ],...
                        'StartPoint',[ 1,1,1,100 ]);
                    
      ft = fittype(func,'indep','t',...
                  'dependent','y',...
                  'problem','Teq',...
                  'coeff',{'b','v1','v2','O'},...
                  'options',fopt);

   %%%%%%%%%%%%%% natural log %%%%%%%%%%%%%%%
   case 'ln'
      func = 'GPS_func_ln(t,b,v,O,a,tau,Teq)';		% ln & log10 shouldn't have much difference
      fopt = fitoptions('Method','NonlinearLeastSquares',...
                        'MaxFunEvals',MaxFunEvalsNum,...
                        'MaxIter',MaxIterNum,...
                        'Lower',[ dispMin,-1e3,-dispRange,-1e4,  0 ],...
                        'Upper',[ dispMax, 1e3, dispRange, 1e4,100 ],...
                        'StartPoint',[ 1,1,100,-1,0.001 ]);
                    
      ft = fittype(func,'indep','t',...
                  'dependent','y',...
                  'problem','Teq',...
                  'coeff',{'b','v','O','a','tau'},...
                  'options',fopt);

   %%%%%%%%%%%%%% log 10 %%%%%%%%%%%%%%%
   case 'log10'
      func = 'GPS_func_log10(t,b,v,O,a,tau,Teq)';	% ln & log10 shouldn't have much difference
      fopt = fitoptions('Method','NonlinearLeastSquares',...
                        'MaxFunEvals',MaxFunEvalsNum,...
                        'MaxIter',MaxIterNum,...
                        'Lower',[ dispMin,-1e3,-dispRange,-1e4,  0 ],...
                        'Upper',[ dispMax, 1e3, dispRange, 1e4,100 ],...
                        'StartPoint',[ 1,1,100,-1,0.001 ]);
                    
      ft = fittype(func,'indep','t',...
                  'dependent','y',...
                  'problem','Teq',...
                  'coeff',{'b','v','O','a','tau'},...
                  'options',fopt);

   %%%%%%%%%%%%%% log 10 & one offset %%%%%%%%%%%%%%%
   case 'log10_offset1'
      func = 'GPS_func_log10_offset1(t,b,v,Oeq,a,tau,Ooffset,Teq,Toffset)';
      fopt = fitoptions('Method','NonlinearLeastSquares',...
                        'MaxFunEvals',MaxFunEvalsNum,...
                        'MaxIter',MaxIterNum,...
                        'Lower',[ dispMin,-1e3,-dispRange,-1e4,  0,-dispRange ],...
                        'Upper',[ dispMax, 1e3, dispRange, 1e4,100, dispRange ],...
                        'StartPoint',[ 1,1,100,-1,0.001,100 ]);
                    
      ft = fittype(func,'indep','t',...
                  'dependent','y',...
                  'problem',{'Teq','Toffset'},...
                  'coeff',{'b','v','Oeq','a','tau','Ooffset'},...
                  'options',fopt);

   %%%%%%%%%%%%%% exponential %%%%%%%%%%%%%%%
   case 'exp'
      func = 'GPS_func_exp(t,b,v,O,a,tau,Teq)';
      fopt = fitoptions('Method','NonlinearLeastSquares',...
                        'MaxFunEvals',MaxFunEvalsNum,...
                        'MaxIter',MaxIterNum,...
                        'Lower',[ dispMin,-1e3,-dispRange,-1e4,  0 ],...
                        'Upper',[ dispMax, 1e3, dispRange, 1e4,100 ],...
                        'StartPoint',[ 1,1,100,-1,0.001 ]);
                    
      ft = fittype(func,'indep','t',...
                  'dependent','y',...
                  'problem','Teq',...
                  'coeff',{'b','v','O','a','tau'},...
                  'options',fopt);

   %%%%%%%%%%%%%% other %%%%%%%%%%%%%%%
    otherwise
      error('GPS_fitrneu ERROR: fit function type is not corret!');
end

%------------------------------- Fit each component (N,E,V) -------------------------------
switch functype
   case 'linear'
      for ii=1:3
         dat = rneu(ind,ii+2);
         wgt = wgt0(ind,ii);
         [ fitobj0,gof0 ] = fit(time,dat,'poly1','weight',wgt);     % 'poly1' - fitobj(x) = p1*x + p2 
         if ii==1
             fitobj.north = fitobj0;
             gof.north = gof0;
         end
         if ii==2
             fitobj.east  = fitobj0; 
             gof.east = gof0;
         end
         if ii==3
             fitobj.vert  = fitobj0; 
             gof.vert = gof0;
         end
      end
        
   case 'log10_offset1'
      for ii=1:3
         dat = rneu(ind,ii+2);
         wgt = wgt0(ind,ii);
         [ fitobj0,gof0 ] = fit(time,dat,ft,...
	 'problem',num2cell(Teq),'weight',wgt,'Robust','LAR');    % time & dat need to be column vectors
                                            
         if ii==1
             fitobj.north = fitobj0;
             gof.north = gof0;
         end
         if ii==2
             fitobj.east  = fitobj0; 
             gof.east = gof0;
         end
         if ii==3
             fitobj.vert  = fitobj0; 
             gof.vert = gof0;
         end
      end

   otherwise
      for ii=1:3
         dat = rneu(ind,ii+2);
         wgt = wgt0(ind,ii);
         [ fitobj0,gof0 ] = fit(time,dat,ft,'problem',Teq,...     % time & dat need to be column vectors
                                        'weight',wgt,'Robust','LAR');    
         if ii==1
             fitobj.north = fitobj0;
             gof.north = gof0;
         end
         if ii==2
             fitobj.east  = fitobj0; 
             gof.east = gof0;
         end
         if ii==3
             fitobj.vert  = fitobj0; 
             gof.vert = gof0;
         end
      end
end
