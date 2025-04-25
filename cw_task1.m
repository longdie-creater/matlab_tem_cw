% Task 1a: Thermistor setup (hardware)
% Task 1b: Read temperature

duration=600;
tempData=zeros(1,duration);
time=1:duration;

for t=1:duration
    voltage=readVoltage(a,'A0');
    temp=(voltage-0.5)/0.01; % MCP9700A formula
    tempData(t)=temp;
    pause(1);
end

minTemp=min(tempData);
maxTemp=max(tempData);
avgTemp=mean(tempData);

% Task 1c: Plot
plot(time,tempData);
xlabel('Time (s)');
ylabel('Temperature (°C)');

% Task 1d: Print to screen
fprintf('Date: %s\tLocation: Cabin\n', datestr(now, 'dd-mm-yyyy'));
for minute = 0:10
    idx = minute * 60 + 1;
    fprintf('Time: Minute %d\tTemperature: %.2f°C\n', minute, tempData(idx));
end

% Task 1e: Write to file
fileID = fopen('cabin_temperature.txt', 'w');
fprintf(fileID, 'Date: %s\tLocation: Cabin\n', datestr(now, 'dd-mm-yyyy'));
for minute=0:10
    idx=minute*60+1;
    fprintf(fileID, 'Time: Minute %d\tTemperature: %.2f°C\n', minute, tempData(idx));
end
fclose(fileID);




% 步骤 2: 设置LED连接引脚
greenLED='D8';
yellowLED='D10';
redLED='D12';
sensorPin='A0';

figure;
h=plot(NaN, NaN);
xlabel('Time (s)');
ylabel('Temperature (°C)');
xlim([0 60]);
ylim([0 40]);

V0=0.5;
TC=0.02;

time=0;
temperatureArray=[];

while true
voltage=readVoltage(a, sensorPin);
temperature=(voltage-V0)/TC;

time=time+1;
temperatureArray=[temperatureArray temperature];
set(h,'XData',[get(h,'XData') time],'YData',temperatureArray);
drawnow;


if temperature>=18 && temperature<=24

writeDigitalPin(a,greenLED,1);
writeDigitalPin(a,yellowLED,0);
writeDigitalPin(a,redLED,0);

elseif temperature<18
writeDigitalPin(a,greenLED,0);
for i=1:10
writeDigitalPin(a,yellowLED,1);
pause(0.5);
writeDigitalPin(a,yellowLED,0);
pause(0.5);
end

elseif temperature>24
writeDigitalPin(a,greenLED,0);
for i=1:10
writeDigitalPin(a,redLED,1);
pause(0.25);
writeDigitalPin(a,redLED,0);
pause(0.25);
end
end
pause(1);
end





% 步骤2: 设置LED连接引脚
greenLED = 'D10';
yellowLED = 'D8';
redLED = 'D9';
sensorPin = 'A0'; % 温度传感器连接到A0引脚
% MCP9700A的零度电压为500mV，温度系数为20mV/°C
V0 = 0.5; % 零度电压（500mV）
TC = 0.02; % 温度系数（20mV/°C）
% 步骤3: 创建实时图表
figure;
h = plot(NaN, NaN); % 初始化空图
xlabel('Time (s)');
ylabel('Temperature (°C)');
xlim([0 60]); % 设置X轴范围
ylim([0 40]); % 设置Y轴范围
% 步骤4: 持续读取温度数据并更新图表
time = 0; % 时间从0开始
previousTemperature = 0; % 上一次温度
previousTime = time; % 上一次时间
temperatureChanges = []; % 存储温度变化值
temperatureArray = []; % 存储温度数据
while true
% 读取温度数据
voltage = readVoltage(a, sensorPin); % 从A0引脚读取传感器电压
temperature = (voltage - V0) / TC; % 将电压转换为温度
% 计算温度变化速率（单位°C/s）
deltaTemperature = temperature - previousTemperature;
deltaTime = time - previousTime; % 时间差（单位：秒）
% 温度变化速率：℃/s 转换为 ℃/min
rateOfChange = (deltaTemperature / deltaTime) * 60; % 速率转换为每分钟°C
% 保存数据
temperatureChanges = [temperatureChanges rateOfChange]; % 保存温度变化速率
temperatureArray = [temperatureArray temperature]; % 保存温度数据
% 更新上一次的温度和时间
previousTemperature = temperature;
previousTime = time;
% 更新温度数组和时间
time = time + 1; % 增加时间（秒）
% 更新图表
set(h, 'XData', [get(h, 'XData') time], 'YData', temperatureArray);
drawnow; % 刷新图表
% 步骤5: 控制LED
if rateOfChange > 4 % 温度变化率大于4°C/min（升高）
writeDigitalPin(a, redLED, 1); % 红色LED常亮
writeDigitalPin(a, yellowLED, 0); % 关闭黄色LED
writeDigitalPin(a, greenLED, 0); % 关闭绿色LED
elseif rateOfChange < -4 % 温度变化率小于-4°C/min（下降）
writeDigitalPin(a, yellowLED, 1); % 黄色LED常亮
writeDigitalPin(a, redLED, 0); % 关闭红色LED
writeDigitalPin(a, greenLED, 0); % 关闭绿色LED
else % 温度变化率在±4°C/min以内（稳定）
writeDigitalPin(a, greenLED, 1); % 绿色LED常亮
writeDigitalPin(a, yellowLED, 0); % 关闭黄色LED
writeDigitalPin(a, redLED, 0); % 关闭红色LED
end
% 步骤6: 预测未来5分钟的温度
predictionTime = 5; % 预测时间：5分钟
predictedTemperature = temperature + (rateOfChange * predictionTime);
disp(['Predicted Temperature in 5 minutes: ', num2str(predictedTemperature), ' °C']);
% 每秒更新一次
pause(1); % 等待1秒再获取下一次数据
end