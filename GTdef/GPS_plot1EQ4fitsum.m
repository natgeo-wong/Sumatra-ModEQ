function [] = GPS_plot1EQ4fitsum(fitsumName,Deq,ylen)

siteName   = fitsumName(1:4);
[ fitsum ] = GPS_readfitsum(fitsumName,siteName,1);

% select the EQ
ind = fitsum.eqMat(:,1)==Deq;

if any(ind)
    % Deq is origin time
    tt    = (0:0.001:ylen)';
    nn    = zeros(size(tt));
    ee    = zeros(size(tt));
    uu    = zeros(size(tt));
    nnlog = zeros(size(tt));
    eelog = zeros(size(tt));
    uulog = zeros(size(tt));
    nnlg2 = zeros(size(tt));
    eelg2 = zeros(size(tt));
    uulg2 = zeros(size(tt));

    eqMat    = fitsum.eqMat(ind,:);
    funcMat  = fitsum.funcMat(ind,:);
    paramMat = fitsum.paramMat(ind,:);

    funcNum  = size(funcMat,1);
    for ii=1:funcNum
        func   = funcMat(ii,:);
        ff     = reshape(func,[],3)';
        funcN = ff(1,:); funcE = ff(2,:); funcU = ff(3,:);
        % add rate changes
        if ~isempty(regexpi(func,'diffrate'))
            fprintf(1,'diffrate used!\n');
            if strfind(funcN,'diffrate')
                nndV  = paramMat(ii,4);
                nn    = nn    + nndV*tt;
                nnlog = nnlog + nndV*tt;
                nnlg2 = nnlg2 + nndV*tt;
            end
            if strfind(funcE,'diffrate')
                eedV  = paramMat(ii,11);
                ee    = ee    + eedV*tt;
                eelog = eelog + eedV*tt;
                eelg2 = eelg2 + eedV*tt;
            end
            if strfind(funcU,'diffrate')
                uudV  = paramMat(ii,18); 
                uu    = uu    + uudV*tt;
                uulog = uulog + uudV*tt;
                uulg2 = uulg2 + uudV*tt;
            end
        end
        % add offsets    
        if ~isempty(regexpi(funcN,'(log|off|exp)_\w+')) || ~isempty(regexpi(funcN,'k[0-9]{2}_\w+'))
            nnO   = paramMat(ii,5);
            nn    = nn    + nnO;
	    nnlog = nnlog + nnO;
	    nnlg2 = nnlg2 + nnO;
        end
        if ~isempty(regexpi(funcE,'(log|off|exp)_\w+')) || ~isempty(regexpi(funcE,'k[0-9]{2}_\w+'))
            eeO   = paramMat(ii,12); 
            ee    = ee    + eeO;
	    eelog = eelog + eeO;
	    eelg2 = eelg2 + eeO;
        end
        if ~isempty(regexpi(funcU,'(log|off|exp)_\w+')) || ~isempty(regexpi(funcU,'k[0-9]{2}_\w+'))
            uuO   = paramMat(ii,19); 
            uu    = uu    + uuO;
	    uulog = uulog + uuO;
	    uulg2 = uulg2 + uuO;
        end
        % add log changes
        if ~isempty(regexpi(func,'log'))
            if ~isempty(regexpi(funcN,'log'))
                nnaa  = paramMat(ii,6);
                nntau = paramMat(ii,7);
                nn    = nn    + nnaa*log10(1+tt/nntau); 
                nnlog = nnlog + nnaa*log10(1+tt/nntau); 
            end
            if ~isempty(regexpi(funcE,'log'))
                eeaa  = paramMat(ii,13); 
                eetau = paramMat(ii,14); 
                ee    = ee    + eeaa*log10(1+tt/eetau);
                eelog = eelog + eeaa*log10(1+tt/eetau);
            end
            if ~isempty(regexpi(funcU,'log'))
                uuaa  = paramMat(ii,20);
                uutau = paramMat(ii,21);
                uu    = uu    + uuaa*log10(1+tt/uutau); 
                uulog = uulog + uuaa*log10(1+tt/uutau); 
            end
        end
        % add lg2 changes
        if ~isempty(regexpi(func,'lg2'))
            fprintf(1,'lg2 used!\n');
            if ~isempty(regexpi(funcN,'lg2'))
                nnaa  = paramMat(ii,6);
                nntau = paramMat(ii,7);
                nn    = nn + nnaa*log10(1+tt/nntau); 
                nnlg2 = nnlg2 + nnaa*log10(1+tt/nntau); 
            end
            if ~isempty(regexpi(funcE,'lg2'))
                eeaa  = paramMat(ii,13); 
                eetau = paramMat(ii,14); 
                ee    = ee + eeaa*log10(1+tt/eetau);
                eelg2 = eelg2 + eeaa*log10(1+tt/eetau);
            end
            if ~isempty(regexpi(funcU,'lg2'))
                uuaa  = paramMat(ii,20);
                uutau = paramMat(ii,21);
                uu    = uu + uuaa*log10(1+tt/uutau); 
                uulg2 = uulg2 + uuaa*log10(1+tt/uutau); 
            end
        end
    end

    % plot log postseismic
    figure
    subplot(3,1,1); 
    plot(tt,nnlog,'LineWidth',2,'Color','r');

    subplot(3,1,2); 
    plot(tt,eelog,'LineWidth',2,'Color','r');

    subplot(3,1,3); 
    plot(tt,uulog,'LineWidth',2,'Color','r');

    % plot lg2 postseismic
    figure
    subplot(3,1,1); 
    plot(tt,nnlg2,'LineWidth',2,'Color','g');

    subplot(3,1,2); 
    plot(tt,eelg2,'LineWidth',2,'Color','g');

    subplot(3,1,3); 
    plot(tt,uulg2,'LineWidth',2,'Color','g');

    % plot all postseismic
    figure
    subplot(3,1,1); 
    plot(tt,nn,'LineWidth',3,'Color','b'); hold on
    plot(tt,nnlog,'LineWidth',2,'Color','r');
    plot(tt,nnlg2,'LineWidth',2,'Color','g');

    subplot(3,1,2); 
    plot(tt,ee,'LineWidth',3,'Color','b'); hold on
    plot(tt,eelog,'LineWidth',2,'Color','r');
    plot(tt,eelg2,'LineWidth',2,'Color','g');

    subplot(3,1,3); 
    plot(tt,uu,'LineWidth',3,'Color','b'); hold on
    plot(tt,uulog,'LineWidth',2,'Color','r');
    plot(tt,uulg2,'LineWidth',2,'Color','g');

    % plot coseismic & postseismic
    tt = [ 0; tt ];
    nn = [ 0; nn ];
    ee = [ 0; ee ];
    uu = [ 0; uu ];

    figure
    subplot(3,1,1); 
    plot(tt,nn,'LineWidth',3); hold on
    plot(0,nnO,'Marker','o','MarkerSize',8,'MarkerFaceColor','r','MarkerEdgeColor','r');

    subplot(3,1,2); 
    plot(tt,ee,'LineWidth',3); hold on
    plot(0,eeO,'Marker','o','MarkerSize',8,'MarkerFaceColor','r','MarkerEdgeColor','r');

    subplot(3,1,3); 
    plot(tt,uu,'LineWidth',3); hold on
    plot(0,uuO,'Marker','o','MarkerSize',8,'MarkerFaceColor','r','MarkerEdgeColor','r');
else
    error('GPS_plot1EQ4fitsum ERROR: %s does not include %8.0f!',fitsumName,Deq);
end
