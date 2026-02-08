classdef ArduinoManager < handle
    properties (Access = private)
        SerialObj          % The serialport object
        BaudRate = 9600
        HandshakeQuery = "?"
        HandshakeResponse = "A"
    end
    
    properties (SetAccess = private)
        ConnectedPort = "" % Stores the found COM port
        IsConnected = false
    end
    
    methods
        % --- Constructor: Scans and Connects ---
        function obj = ArduinoManager()
            disp("Initializing Arduino Manager...");
            obj.scanAndConnect();
        end
        
        % --- Method to Scan Ports ---
        function scanAndConnect(obj)
            % Get list of all available serial ports
            portList = serialportlist("available");
            
            if isempty(portList)
                error("No serial ports found. Please connect the Arduino.");
            end
            
            disp("Scanning ports: " + join(portList, ", "));
            
            % Iterate through every port found
            for i = 1:length(portList)
                currentPort = portList(i);
                try
                    fprintf("Probing %s... ", currentPort);
                    
                    % 1. Open Connection
                    s = serialport(currentPort, obj.BaudRate);
                    configureTerminator(s, "LF");
                    flush(s);
                    
                    % 2. Wait for Arduino Reset (CRITICAL STEP)
                    % When Serial opens, Arduino reboots. We must wait ~2s.
                    pause(2); 
                    
                    % 3. Send Handshake "?"
                    writeline(s, obj.HandshakeQuery);
                    
                    % 4. Listen for "A" (Timeout 1 second)
                    startTick = tic;
                    found = false;
                    while(toc(startTick) < 1.0)
                        if s.NumBytesAvailable > 0
                            response = readline(s);
                            if contains(response, obj.HandshakeResponse)
                                found = true;
                                break;
                            end
                        end
                    end
                    
                    if found
                        fprintf("SUCCESS! Arduino found.\n");
                        obj.SerialObj = s;
                        obj.ConnectedPort = currentPort;
                        obj.IsConnected = true;
                        return; % Stop searching
                    else
                        fprintf("No response.\n");
                        delete(s); % Close this port and try next
                    end
                    
                catch
                    fprintf("Error accessing port.\n");
                    if exist('s', 'var'), delete(s); end
                end
            end
            
            error("Could not find an Arduino with the correct sketch.");
        end
        
        % --- Method to Move Servos ---
        function setServos(obj, angle1, angle2)
            if ~obj.IsConnected
                error("Arduino not connected.");
            end
            
            % Sanitize inputs
            if angle1 < -90 || angle1 > 90 || angle2 < -90 || angle2 > 90
                warning("Ángulos fuera de rango: -90 - 90.");
            end
            
            % Format: "angle1,angle2"
            commandStr = sprintf("%d,%d", round(angle1), round(angle2));
            
            try
                writeline(obj.SerialObj, commandStr);
                dibujar_robot2R(angle1, angle2, 11, 8.75);
            catch
                warning("Connection lost.");
                obj.IsConnected = false;
            end
        end

        function dibujar_robot2R(q1_grados, q2_grados, L1, L2)
            % 1. Obtener posición del codo (Cojuntura 2)
            q1_rad = deg2rad(q1_grados);
            x_codo = L1 * cos(q1_rad);
            y_codo = L1 * sin(q1_rad);
            
            % 2. Obtener posición del efector final (usando tu función c_d_r)
            [x_final, y_final] = c_d_r(q1_grados, q2_grados, L1, L2);
            
            % 3. Definir los puntos de la estructura [Base, Codo, Extremo]
            puntos_x = [0, x_codo, x_final];
            puntos_y = [0, y_codo, y_final];
            
            % 4. Dibujar
            plot(puntos_x, puntos_y, '-o', 'LineWidth', 3, 'MarkerSize', 6, 'MarkerFaceColor', 'k');
            grid on;
            axis equal;
            % Ajustar límites según la longitud total para que no salte el gráfico
            limite = L1 + L2 + 0.5;
            xlim([-limite, limite]); ylim([-limite, limite]);
        end
        
        % --- Destructor ---
        function delete(obj)
            if ~isempty(obj.SerialObj) && isvalid(obj.SerialObj)
                delete(obj.SerialObj);
                disp("Arduino connection closed.");
            end
        end
    end
end