clear all 
clc
fs=1e11; % Частота дискретизации %%%%%% !!!!!!!!!!!!!
T=1/fs % период дискретизации
K=5e5; % количество отсчетов с антенны %%%%%% !!!!!!!!!!!!!
PerIssledovaniya = K * T
t = (0:K-1)*T;
R = 20000;% (м) расстояние от антенны до цели
h = 30; % (м) высота антенны 
H1 = 400; % (м) высота цели 
c = 3e8;
H2 = H1 - h;
H3 = H1 + h;
BA = hypot(R,H2);
CA = hypot(R,H3);
raznost_M = CA - BA % (м) разность прихода сигналов 
raznost_S = raznost_M/c% (c) разность прихода сигналов 
Os4et_zaderzhki = round(raznost_S/T); % количество отсчетов задержки 
max_Tsig6 = 12000/c
PeriodIzl = max_Tsig6/10 % (c) В 3 раз меньше допустимого длительность импульса
Os4et_perIzl = round(PeriodIzl/T);
protsentNeperecritiya = raznost_S/PeriodIzl*100 

alfa = asin(H2/BA+H3/CA);
UgolPrihoda = rad2deg(alfa)

Fnes = 10e9;
deviatsia = 15e6;
FreqMax = Fnes+deviatsia;
FreqMin = Fnes-deviatsia;
%Вводные данные по нарпавлениям
th1 = 0; % направление #1
th2 = UgolPrihoda; % направление #2 
% Vkm=[400  400]; %км/ч скорость цели с направления D
% Vm=Vkm/3.6; %м/с
% Fd1=(2*Vm)/0.03 % частота Доплера  с направления D 
p1=1; % мощность сигнала с направления #1
p2=1; %мощность сигнала с направления #2
d=0.5; % расстояния между элементов относительно lambda
M=200; % количество элементов антенны
doas=[th1 th2]*pi/180; %DOA s of signals in rad.
P=[p1 p2];
F=[Fnes Fnes];

NP=1; % мощность шума
r=length(doas);
%%%% Вектора прихода от различных источников %%%%%%%%%%%
for m=1:M
    parfor th=1:r
        A(m,th)=exp(+1i*2*pi*(m-1)*d*sin(doas(th)));
    end
end
Signal generation
%Рост ЛЧМ (Linear Chirp) 
% y = chirp(t,FreqMin,PeriodIzl,FreqMax);
% signal = [y(1,1:Os4et_perIzl),zeros(1,K-Os4et_perIzl)]
% a = chirp(t,FreqMin,PeriodIzl/2,FreqMax);
% b = chirp(t,FreqMin,PeriodIzl/2,FreqMax);
% signal = [a(1,1:Os4et_perIzl/2),rot90(b(1,1:Os4et_perIzl/2),2),zeros(1,K-Os4et_perIzl)]
%Сигнал зерканый ЛЧМ (2крышы)
% a = chirp(t,FreqMin,PeriodIzl/2,FreqMax);
% b = chirp(t,FreqMin,PeriodIzl/2,FreqMax);
% signal = [a(1,1:Os4et_perIzl/4),rot90(b(1,1:Os4et_perIzl/4),2),a(1,1:Os4et_perIzl/4),rot90(b(1,1:Os4et_perIzl/4),2),zeros(1,K-Os4et_perIzl)]
6oy
% a = chirp(t,FreqMin,PeriodIzl/2,FreqMax);
% b = chirp(t,FreqMin,PeriodIzl/2,FreqMax);
% signal = [rot90(b(1,1:Os4et_perIzl/4),2),a(1,1:Os4et_perIzl/4),rot90(b(1,1:Os4et_perIzl/4),2),a(1,1:Os4et_perIzl/4),zeros(1,K-Os4et_perIzl)]
%Сигнал зерканый ЛЧМ (8)
a = chirp(t,FreqMin,PeriodIzl/2,FreqMax);
b = chirp(t,FreqMin,PeriodIzl/2,FreqMax);
signal = [rot90(b(1,1:Os4et_perIzl/8),2),a(1,1:Os4et_perIzl/8),rot90(b(1,1:Os4et_perIzl/8),2),a(1,1:Os4et_perIzl/8),rot90(b(1,1:Os4et_perIzl/8),2),a(1,1:Os4et_perIzl/8),rot90(b(1,1:Os4et_perIzl/8),2),a(1,1:Os4et_perIzl/8),zeros(1,K-Os4et_perIzl)]
%Сигнал зерканый ЛЧМ (7)
% a = chirp(t,FreqMin,PeriodIzl/2,FreqMax);
% b = chirp(t,FreqMin,PeriodIzl/2,FreqMax);
% signal = [a(1,1:Os4et_perIzl/8),rot90(b(1,1:Os4et_perIzl/8),2),a(1,1:Os4et_perIzl/8),rot90(b(1,1:Os4et_perIzl/8),2),a(1,1:Os4et_perIzl/8),rot90(b(1,1:Os4et_perIzl/8),2),a(1,1:Os4et_perIzl/8),rot90(b(1,1:Os4et_perIzl/8),2),zeros(1,K-Os4et_perIzl)]
% %%%%%%генерация шума (АБГШ)%%%%%%%%%
noise=wgn(M,K,NP,'real','linear') %некоррелированный шум
A;
diag(sqrt(P));
signal;
Time Delay

signal2=[zeros(1,Os4et_zaderzhki),signal(1,1:K-Os4et_zaderzhki)]; %  #1 цель
sig1=[signal; signal2] % сигнал с задержками
X=A*diag(sqrt(P))*sig1+noise; %генерация сигнала в решетке
R=X*X'/K; %Spatial correlation matrix
R;
[E ,D]=eig(R); %разложение корреляционной матрицы на собственные вектора и значения 
E; %собственные вектора
D; %собственные значения
[D,I]=sort(diag(D),1,'descend'); %Поиск r наибольших собственный значений
r = 2
E=E (:,I); %сортировка, что сигнальные значения стояли сначала
Es=E (:,1:r); %получения матрицы сигнального подпространства
En=E(:,r+1:M); %получения матрицы шумового подпространства

%%%%%%%%%%%%%% MUSIC algorithm %%%%%%%%%%%%%%
angles=(-1:0.01:9);
for m=1:M
    for th=1:length(angles)
        a(m,th)=exp(+1i*2*pi*(m-1)*d*sin(angles(th)*pi/180));
    end
end
for k=1:length(angles)
    %расчет MUSIC "spectrum" всевдоспектр
    music_spectrum(k)=(a(:,k)'*a(:,k))/(a(:,k)'*En*En'*a(:,k));
end


%%%%%%построение спектральной плотности мощности %%%%%%%%%%%%%%
music_spectrum=10*log10(abs(music_spectrum/max(music_spectrum)));

plot(angles,music_spectrum);
grid on
title('MUSIC Spectrum')
xlabel('Angle in degrees(\theta)')
ylabel('PMU(\theta) dB')
plot(X(1,:))