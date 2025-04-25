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


function temp_monitor(a)
    % doc temp_monitor: Monitors temperature and controls LEDs.
    h = figure;
    timeVec = [];
    tempVec = [];
    ledState = false;
    
    while ishandle(h)
        temp = (readVoltage(a, 'A0') - 0.5) / 0.01;
        time = now;
        
        % Update plot
        timeVec = [timeVec, time];
        tempVec = [tempVec, temp];
        plot(timeVec - timeVec(1), tempVec);
        xlabel('Time (s)');
        ylabel('Temperature (°C)');
        drawnow;
        
        % Control LEDs
        if temp >= 18 && temp <= 24
            writeDigitalPin(a, 'D9', 1);
            writeDigitalPin(a, 'D10', 0);
            writeDigitalPin(a, 'D11', 0);
        elseif temp < 18
            % Blink yellow every 0.5s
            writeDigitalPin(a, 'D10', ledState);
            ledState = ~ledState;
            pause(0.5);
        else
            % Blink red every 0.25s
            writeDigitalPin(a, 'D11', ledState);
            ledState = ~ledState;
            pause(0.25);
        end
    end
end



function temp_prediction(a)
    % doc temp_prediction: Predicts temperature and alerts rate changes.
    prevTemp = (readVoltage(a, 'A0') - 0.5) / 0.01;
    
    while true
        currentTemp = (readVoltage(a, 'A0') - 0.5) / 0.01;
        rate = (currentTemp - prevTemp) * 60; % °C/min
        predictedTemp = currentTemp + rate * 5;
        
        fprintf('Current: %.2f°C, Rate: %.2f°C/min, Predicted: %.2f°C\n', ...
            currentTemp, rate, predictedTemp);
        
        % Control LEDs
        if rate > 4
            writeDigitalPin(a, 'D11', 1);
        elseif rate < -4
            writeDigitalPin(a, 'D10', 1);
        else
            writeDigitalPin(a, 'D9', 1);
        end
        
        prevTemp = currentTemp;
        pause(1);
    end
end