clear all;
T = linspace(0, 150, 10000);
% Cold Stream Inputs %
CS_n = 3;
CS_in = [40, 40, 80];
CS_out = [50, 70, 90];
lowest_CS = min(CS_in);
highest_CS = max((CS_out));
CS_duty = [1000, 1000, 400];
% Hot Stream Inputs %
HS_n = 3;
HS_in = [90, 90, 120];
HS_out = [80, 75, 110];
HS_duty = [2000, 1500, 500];
highest_HS = max(HS_in);
% Heat shifting %
Shift = 1500;
CS_heat = zeros(CS_n, numel(T));  % Preallocate CS_heat
HS_heat = zeros(HS_n, numel(T));  % Preallocate HS_heat

for i = 1:CS_n
    CS_grad = CS_duty(i) / (CS_out(i) - CS_in(i));
    HS_grad = HS_duty(i) / (HS_out(i) - HS_in(i));
    for j = 1:numel(T)
        CS_heat(i,j) = CS_grad * (T(j) - CS_in(i)) * heaviside(T(j) - CS_in(i)) ...
                       - CS_grad * (T(j) - CS_in(i)) * heaviside(T(j) - CS_out(i)) ...
                       + CS_duty(i) * heaviside(T(j) - CS_out(i));
        HS_heat(i,j) = HS_grad * (T(j) - HS_in(i)) * heaviside(T(j) - HS_in(i)) ...
                       - HS_grad * (T(j) - HS_in(i)) * heaviside(T(j) - HS_out(i)) ...
                       + HS_duty(i) * heaviside(T(j) - HS_out(i));
    end
end


CS_heat_total = sum(CS_heat, 1);
HS_heat_total = sum(HS_heat, 1);

CS_shifted = CS_heat_total + Shift;

CS_indeces = (CS_shifted >= (Shift+1)) & (CS_shifted <= (sum(CS_duty)+Shift-1));
CSX = CS_shifted(CS_indeces);
CSY = T(CS_indeces);
HS_indeces = (HS_heat_total >= 1) & (HS_heat_total <= (sum(HS_duty)-1));
HSX = HS_heat_total(HS_indeces);
HSY = T(HS_indeces);
plot(HSX, HSY,'LineWidth',1,'color','r')
xlim([((-1*sum(HS_duty)/20)) ((sum(HS_duty)+sum(HS_duty)/20))])
ylim([(lowest_CS-5) (highest_HS+5)])
hold on
plot(CSX, CSY,'LineWidth',1,'color','b')
xlabel('heat / kW')
ylabel('Temperature / K')
legend('Hot Steams','Cold Steams')
