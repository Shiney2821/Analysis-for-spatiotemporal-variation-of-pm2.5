function []=td_print_G(res,file_sal,op1)
% PURPOSE: Generate output of temporal disaggregation methods.
%          Specific design for Guerrero method
% ------------------------------------------------------------
% SYNTAX: td_print_G(res,file_sal,op1);
% ------------------------------------------------------------
% OUTPUT: file_sal: an ASCII file with detailed output of
% Guerrero temporal disaggregation methods (td)
% ------------------------------------------------------------
% INPUT: res: structure generated by guerrero()
%        file_sal: name of the ASCII file for output
%        op1: option on output series
%            =1 high freq. estimates are printed
%            =0 high freq. estimates are NOT printed
% ------------------------------------------------------------
% LIBRARY: tasa, aggreg, mprint
% ------------------------------------------------------------
% SEE ALSO: guerrero, td_print

% written by:
% Enrique M. Quilis
% Instituto Nacional de Estadistica
% Paseo de la Castellana, 183
% 28046 - Madrid (SPAIN)

% -----------------------------------------------------------
% -----------------------------------------------------------
% Loading the structure

meth=res.meth;

if (meth ~= 'Guerrero')
    error ('*** ONLY GUERRERO METHOD IS ALLOWED ***')
end

% -----------------------------------------------------------
% Basic parameters
N=res.N;
n=res.n;
pred=res.pred;
s=res.s;
p=res.p;
et=res.et;
ta=res.ta;
type=res.type;

% -----------------------------------------------------------
% Series
Y = res.Y;
x = res.x;
y    = res.y;
d_y  = res.y_dt;
y_li = res.y_lo;
y_ls = res.y_up;

% -----------------------------------------------------------
% Residuals
u = res.u;
U = res.U;

% -----------------------------------------------------------
% Parameters
beta = res.beta;
beta_sd =res.beta_sd;
beta_t =res.beta_t;
rho = res.rho;

% -----------------------------------------------------------
% Information criteria
aic=res.aic;
bic=res.bic;

% -----------------------------------------------------------
% Descriptive measures (one indicator case only)

if (p == 2)
   % Correlation between Y and X (levels)
   x_short=x(1:s*N,2);
   X=aggreg(res.ta,res.N,res.s)*x_short;
   AUX=corrcoef(res.Y,X);
   c1=AUX(1,2);
   % Correlation between Y and X (yoy rates)
   TY=tasa(Y,1); TY=TY(2:N);
   TX=tasa(X,1); TX=TX(2:N);
   AUX=corrcoef(TY,TX);
   c2=AUX(1,2);
   % Correlation between y and x (levels)
   AUX=corrcoef(res.y,res.x(:,2));
   c3=AUX(1,2);
   % Correlation between y and x (yoy rates)
   ty=tasa(res.y,s);
   tx=tasa(res.x(:,2),s);
   AUX=corrcoef(ty(s+1:n),tx(s+1:n));
   c4=AUX(1,2);
   c5=std(ty(s+1:n),1);
   c6=std(tx(s+1:n),1);
end
% Correlation between y and x*beta
xb=x*beta;
% ... levels
AUX=corrcoef(res.y,xb);
c7=AUX(1,2);
% ... yoy rates
ty=tasa(res.y,s);
txb=tasa(xb,s);
AUX=corrcoef(ty(s+1:n),txb(s+1:n));
c8=AUX(1,2);

% -----------------------------------------------------------
% Output on ASCII file

sep1='****************************************************';
sep ='----------------------------------------------------';

fid=fopen(file_sal,'w');
fprintf(fid,'\n ');
fprintf(fid,'%s \n',sep1);
fprintf(fid,' TEMPORAL DISAGGREGATION METHOD: %s \n ',meth);
fprintf(fid,'%s \n',sep1);
fprintf(fid,'\n ');
fprintf(fid,'%s\n',sep);
fprintf(fid,' Number of low-frequency observations : %4d\n ',N );
fprintf(fid,'Frequency conversion                 : %4d\n ',s );
fprintf(fid,'Number of high-frequency observations: %4d\n ',n );
fprintf(fid,'Number of extrapolations             : %4d\n ',pred );
fprintf(fid,'Number of indicators (+ constant)    : %4d\n ',p );
fprintf(fid,'%s \n',sep);
fprintf(fid,' Type of disaggregation: ');
switch ta
case 1
   fprintf(fid,'sum (flow). \n');
case 2
   fprintf(fid,'average (index). \n');
case 3
   fprintf(fid,'interpolation (stock). \n');
end; %of switch ta
fprintf(fid,'%s \n',sep);
fprintf(fid,' Estimation method: ');
fprintf(fid,'BLUE. \n');
fprintf(fid,'%s\n',sep);
beta_tot = [beta beta_sd beta_t];
fprintf(fid,' Beta parameters (columnwise):\n ');
fprintf(fid,'  * Estimate \n ');
fprintf(fid,'  * Std. deviation \n ');
fprintf(fid,'  * t-ratios \n ');
fprintf(fid,'%s \n',sep);
fprintf(fid,'%10.4f      %10.4f      %10.4f\n ',beta_tot' );
fprintf(fid,'%s \n',sep);
% Descriptive measures (one indicator case only)
if (p == 2)
    fprintf(fid,' AIC: %8.4f\n ',aic);
    fprintf(fid,'BIC: %8.4f\n ',bic);
    fprintf(fid,'%s \n',sep);
    fprintf(fid,'Low-frequency correlation (Y,X) \n ');
    fprintf(fid,' - levels     : %6.4f\n ',c1 );
    fprintf(fid,' - yoy rates  : %6.4f\n ',c2 );
    fprintf(fid,'%s\n',sep);
    fprintf(fid,'High-frequency correlation (y,x) \n ');
    fprintf(fid,' - levels     : %6.4f\n ',c3 );
    fprintf(fid,' - yoy rates  : %6.4f\n ',c4 );
    fprintf(fid,'%s\n',sep);
    fprintf(fid,'High-frequency volatility of yoy rates \n ');
    fprintf(fid,' - estimate   : %6.4f\n ',c5 );
    fprintf(fid,' - indicator  : %6.4f\n ',c6 );
    fprintf(fid,' - ratio      : %6.4f\n ',(c5/c6) );
    fprintf(fid,'%s\n',sep);
end
fprintf(fid,'High-frequency correlation (y,x*beta) \n ');
fprintf(fid,' - levels     : %6.4f\n ',c7 );
fprintf(fid,' - yoy rates  : %6.4f\n ',c8 );
fprintf(fid,'%s\n',sep);
fprintf(fid,' Compatibility test:\n ');
fprintf(fid,' - k : %8.4f\n ',res.k );
fprintf(fid,'%s \n',sep);
fprintf(fid,'\n ');
fprintf(fid,' ARIMA model for scaled indicator:\n ');
fprintf(fid,'\n ');
aux=[length(res.rexw.ar_reg)-1 res.rexw.d length(res.rexw.ma_reg)-1];
fprintf(fid,'(%2d  %1d  %2d  ) ',aux );
aux=[length(res.rexw.ar_sea)-1 res.rexw.bd length(res.rexw.ma_sea)-1]; 
aux(1)=aux(1)/s; aux(3)=aux(3)/s; 
fprintf(fid,'(%2d  %1d  %2d  )\n ',aux );
fprintf(fid,'\n ');
% Using mptint() of Econometrics Toolbox
info.fmt='%8.4f'; info.width=110; info.fid=fid;
fprintf(fid,' - Regular AR operator:\n ');
aux=res.rexw.ar_reg; mprint(aux,info);
fprintf(fid,' - Regular MA operator:\n ');
aux=res.rexw.ma_reg; mprint(aux,info);
fprintf(fid,' - Seasonal AR operator:\n ');
aux=res.rexw.ar_sea; mprint(aux,info);
fprintf(fid,' - Seasonal MA operator:\n ');
aux=res.rexw.ma_sea; mprint(aux,info);
fprintf(fid,'%s \n',sep);
fprintf(fid,' ARIMA model for discrepancy :\n ');
fprintf(fid,'\n ');
aux=[length(res.rexd.ar_reg)-1 res.rexd.d length(res.rexd.ma_reg)-1];
fprintf(fid,'(%2d  %2d  %2d  ) ',aux );
aux=[length(res.rexd.ar_sea)-1 res.rexd.bd length(res.rexd.ma_sea)-1];
aux(1)=aux(1)/s; aux(3)=aux(3)/s; 
fprintf(fid,'(%2d  %2d  %2d  )\n ',aux);
fprintf(fid,'\n ');
% Using mptint() of Econometrics Toolbox
info.fmt='%8.4f'; info.width=110; info.fid=fid;
fprintf(fid,' - Regular AR operator:\n ');
aux=res.rexd.ar_reg; mprint(aux,info);
fprintf(fid,' - Regular MA operator:\n ');
aux=res.rexd.ma_reg; mprint(aux,info);
fprintf(fid,' - Seasonal AR operator:\n ');
aux=res.rexd.ar_sea; mprint(aux,info);
fprintf(fid,' - Seasonal MA operator:\n ');
aux=res.rexd.ma_sea; mprint(aux,info);
fprintf(fid,'%s\n',sep);
% Detailed output (if op1==1)
if (op1 == 1)
   fprintf(fid,' High frequency series (columnwise):\n ');
   fprintf(fid,'  * Estimate \n ');
   fprintf(fid,'  * Std. deviation \n ');
   fprintf(fid,'  * 1 sigma lower limit \n ');
   fprintf(fid,'  * 1 sigma upper limit \n ');
   fprintf(fid,'  * Residuals \n ');
   fprintf(fid,'----------------------------------------------------\n ');
   tot=[y(1:n-pred) d_y(1:n-pred) y_li(1:n-pred) y_ls(1:n-pred) u(1:n-pred)];
   fprintf(fid,'%10.4f      %10.4f      %10.4f      %10.4f      %8.4f\n ',tot' );
   fprintf(fid,'----------------------------------------------------\n ');
   tot=[y(n-pred+1:n) d_y(n-pred+1:n) y_li(n-pred+1:n) y_ls(n-pred+1:n) u(n-pred+1:n)];
   fprintf(fid,'%10.4f      %10.4f      %10.4f      %10.4f      %8.4f\n ',tot' );
   fprintf(fid,'----------------------------------------------------\n ');
end
fprintf(fid,'\n ');
fprintf(fid,'Elapsed time: %8.4f\n ',et);
fclose(fid);
