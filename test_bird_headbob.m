% We are going to do a simulation of the stance phase of a pigeon walking
% with a head on top. For now the head is stationary and we just do
% simulation of the stance phase. 
clear
clc
close all

%% Set parameters
parms.g=-9.81; % [m/s^2] gravitational acceleration
pigeon_mass=1; % [kg] total pigeon mass 
head_mass_rel=.000001; % [] proportion of head mass relative to total pigeon mass
hh_rel=1.05; % head height relative to leg length
bobtime_rel=.20; % [] relative time duration of headmotion  
parms.L=1; % [m] leg length
parms.alpha=.3; % [rad] half leg spread angle
parms.xh0=0.1*parms.L;

%% (potential) sweeping parameters:
delay_rel=.2;
parms.speed=2*parms.L; % [m/s] desired walking speed

%% derived parameters
parms.mp=(1-head_mass_rel)*pigeon_mass; % [kg] pigeon pelvis mass   
parms.mh=head_mass_rel*pigeon_mass; % [kg] pigeon head mass
parms.hh=hh_rel*parms.L; % [m] head height 
parms.step_length=2*parms.L*sin(parms.alpha); % [m] step length
parms.step_time=parms.step_length/parms.speed; % [s] desired step duration
parms.bobtime=parms.step_time*bobtime_rel; % [s]
parms.delay=delay_rel*parms.step_time; % [s]
%% free parameters
% potentially add simulation time ?? 
Phat_push=1; % [Ns] push off magnitude
phid0=-1; % [rad/s] phidot of stance leg AT END OF PREVIOUS STANCE PHASE
step_time=parms.step_length/parms.speed;
x0 = [phid0; Phat_push; step_time]; % initial guess for design parms

%% perform simulation:
[Wcoll,c_coll,state_end,t,state,Ekin_stance,Wgravity,Wneck,Wpush] = bird_headbob_optim(x0, parms);

phi=state(:,1);
phid=state(:,2);
xh=state(:,3);
yh=parms.hh;

%% State plots; not really a test, but demonstration plot
figure;
plot(t,state(:,1:2))
xlabel('Time [s]');
ylabel('leg angles [rad, rad/s]');
title('states vs time of stance phase for headbobbing bird');
legend('phi','phidot')

figure;
plot(state(:,1),state(:,2))
xlabel('phi [rad]');
ylabel('phidot [rad/s]');
title('phase diagram of stance phase');
legend('phi','phidot')
%% animation
figure;
for iStep=1:length(t)
    r_p=parms.L*[cos(phi(iStep)) sin(phi(iStep))];
    plot([0 r_p(1)],[0 r_p(2)],'k'); hold on
    plot(xh(iStep),yh,'ro','linewidth',2); hold on
    plot(r_p(1),r_p(2),'ko','linewidth',2,'markersize',8); hold on
    plot([r_p(1) xh(iStep)],[r_p(2) yh],'b--'); hold on
    xlabel('x axis [m]')
    ylabel('y axis [m]')
    legend('leg','head','pelvis','neck')
    title('stick diagram of stance leg and head')
    axis([-1 1 0 1.5]*parms.L)
    drawnow
    axis equal
end
%% Energy plot
figure
plot(t,Ekin_stance-Wgravity-Wneck)
xlabel('Time [s]');
ylabel('delta Ekin - Wtot [J]');
title('Energy balance of stance phase for headbobbing bird'); 
