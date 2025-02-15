function PL=PL_free(fc,dist,Gt,Gr)
% Free Space Path loss Model
% Input
%       fc        : carrier frequency[Hz]
%       dist      : between base station and mobile station[m]
%       Gt        : transmitter gain
%       Gr        : receiver gain
% output
%       PL        : path loss[dB]

%MIMO-OFDM Wireless Communications with MATLAB��   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%2010 John Wiley & Sons (Asia) Pte Ltd

lamda = 3e8/fc;
tmp = lamda./(4*pi*dist*1000);
if nargin>2,  tmp = tmp*sqrt(Gt);  end
if nargin>3,  tmp = tmp*sqrt(Gr);  end
PL = -20*log10(tmp); % Eq.(1.2)/(1.3)
