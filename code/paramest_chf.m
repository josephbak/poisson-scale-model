SymbolFactors = { '^GSPC' };
yDataIndex = getYahooDailyData(SymbolFactors, '01/01/2013', '12/31/2015', 'mm/dd/yyyy');
datalength = length(yDataIndex.(genvarname(SymbolFactors{1})).AdjClose);
numoffactor = length(SymbolFactors);
retIndex = ...
    log(yDataIndex.(genvarname(SymbolFactors{1})).AdjClose(2:datalength)./yDataIndex.(genvarname(SymbolFactors{1})).AdjClose(1:datalength-1));

    stdret = (retIndex-mean(retIndex))/std(retIndex);

    wk = 0.1:0.1:1;
    wk = wk(:);
    samplelogsymcf = log(samplechf(wk, stdret));

    initial = [1, 1.4, 1, 0.0];

    opt = optimoptions(@lsqnonlin, 'TolX', 1e-9, 'TolFun', 1e-9, 'MaXFunEvals', 1000);
    [xlsq, resnorm] = lsqnonlin(@(x)errstcf(x, samplelogsymcf, wk, @chf_PSM), initial, [0, -Inf, 0, -inf], [Inf, Inf,Inf, Inf], opt);
    
    [empCumDis,xi_empCumDis] = ksdensity(stdret(:),'function','cdf');
    [empFreDis,xi] = ksdensity(stdret(:));
    pdfPSM = pdf_PSM( xi, xlsq );  
    cdfPSM = cdf_PSM( xi, xlsq );  

    pdfNormal = pdf('norm', xi, 0, 1);
    cdfNormal = cdf('norm', xi, 0, 1);

    figure(1),plot(xi, empFreDis, 'k', xi, pdfPSM, 'r', xi, pdfNormal, 'b') 
    figure(2),plot(xi, log(empFreDis), 'k', xi, log(pdfPSM), 'r', xi, log(pdfNormal), 'b') 
    figure(3),plot(xi_empCumDis, empCumDis, 'k', xi_empCumDis, cdfPSM, 'b') 

    [h,pPSM,ksstatPSM,cv] = kstest(stdret(:),[xi_empCumDis(:),cdfPSM(:)]);
    [adPSM, ad2PSM] = ad2test_FFT( stdret(:),[xi_empCumDis(:),cdfPSM(:)] );
    ad2PSM=ad2PSM*length(stdret);
    pAD2PSM=1-AD(length(stdret),ad2PSM);
    
    
    figure(4)
    plot(-4:0.1:4, pdf_PSM( -4:0.1:4, xlsq )./pdf('norm', -4:0.1:4, 0, 1));
    figure(5)
    plot(-4:0.1:4, cdf_PSM( -4:0.1:4, xlsq )./cdf('norm', -4:0.1:4, 0, 1));
return
