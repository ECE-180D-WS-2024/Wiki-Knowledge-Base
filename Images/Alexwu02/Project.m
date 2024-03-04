<<<<<<< HEAD
% ECE 141 Project Part 1 Question 2
% Bailun Wu
% Closed-Loop PID controller with constant reference signal

%Define variables
s = tf('s');
t = 0:0.001:1500;
sigma = 5;
tau1 = 0.1;
tau2 = 0.1;
Ro = 1;
Wo = 1;

%Controller
%Note1: kp < 400(1+kd)
%Note2: Ki < 5kp(1+kd) - 0.0125kp^2
%Note3: Ki > 0   
diffp = 6300;
diffi = 7874;
Kd = 15;
Kp = 400*(1+Kd) - diffp;
Ki = 5*Kp*(1+Kd) - 0.0125*Kp^2 - diffi;

%Plotting
A = s^2*(tau1*s+1)*(tau2*s+1);
B = (Kp*s+Kd*s^2+Ki)*tau1*tau2*sigma;
C = (tau1*s+1)*s;
sysE = Ro-(Ro*B+Wo*C)/(A+B);
err = step(sysE,t);
figure(1);
plot(t,err,'LineWidth',2)
grid on
xlabel('t [s]');
ylabel('e(t), closed-loop');


=======
% ECE 141 Project Part 1 Question 2
% Bailun Wu
% Closed-Loop PID controller with constant reference signal

%Define variables
s = tf('s');
t = 0:0.001:1500;
sigma = 5;
tau1 = 0.1;
tau2 = 0.1;
Ro = 1;
Wo = 1;

%Controller
%Note1: kp < 400(1+kd)
%Note2: Ki < 5kp(1+kd) - 0.0125kp^2
%Note3: Ki > 0   
diffp = 6300;
diffi = 7874;
Kd = 15;
Kp = 400*(1+Kd) - diffp;
Ki = 5*Kp*(1+Kd) - 0.0125*Kp^2 - diffi;

%Plotting
A = s^2*(tau1*s+1)*(tau2*s+1);
B = (Kp*s+Kd*s^2+Ki)*tau1*tau2*sigma;
C = (tau1*s+1)*s;
sysE = Ro-(Ro*B+Wo*C)/(A+B);
err = step(sysE,t);
figure(1);
plot(t,err,'LineWidth',2)
grid on
xlabel('t [s]');
ylabel('e(t), closed-loop');


>>>>>>> ad08946e9c9ff574438cb76c959561c11378699e
