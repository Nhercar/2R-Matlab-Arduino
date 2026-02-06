function [q1, q2] = c_i_r(x, y, L1, L2)
% SOLUCIONARIO DEL PROFESOR - MÉTODO GEOMÉTRICO
%
% Entradas: x, y (coordenadas), L1, L2 (longitudes)
% Salidas: q1, q2 (ángulos en GRADOS)

    % 1. Calcular r cuadrado (distancia al cuadrado al origen)
    r2 = x^2 + y^2;
    
    % 2. Calcular el Coseno de q2 (Ley de Cosenos)
    % r^2 = L1^2 + L2^2 + 2*L1*L2*cos(q2)
    numerador = r2 - L1^2 - L2^2;
    denominador = 2 * L1 * L2;
    D = numerador / denominador;
    
    % --- GESTIÓN DE ERRORES (Punto inalcanzable) ---
    % El coseno debe estar entre -1 y 1. Si D > 1 o D < -1, el robot no llega.
    if D > 1
        warning("El punto (%.2f, %.2f) está demasiado LEJOS.", x, y);
        D = 1; % Clampear para evitar números imaginarios
    elseif D < -1
        warning("El punto (%.2f, %.2f) está demasiado CERCA.", x, y);
        D = -1;
    end
    
    % 3. Calcular q2 (Codo) en radianes
    % Aquí elegimos la configuración "Codo Abajo" o "Codo Arriba".
    % Generalmente sin el signo menos es una configuración, y con él, la otra.
    % Para robots SCARA simples, acos(D) suele ir bien.
    q2_rad = acos(D); 
    
    % 4. Calcular q1 (Hombro) en radianes
    % Ángulo base hacia el punto (beta)
    beta = atan2(y, x);
    
    % Ángulo interno debido a la altura del segundo eslabón (alpha)
    % Usamos trigonometría básica proyectando L2
    k2 = L2 * sin(q2_rad);
    k1 = L1 + L2 * cos(q2_rad);
    alpha = atan2(k2, k1);
    
    % Restamos alpha de beta (para configuración codo arriba/abajo estándar)
    q1_rad = beta - alpha;
    
    % 5. Convertir a Grados para el Servo
    q1 = rad2deg(q1_rad);
    q2 = rad2deg(q2_rad);
    
    % --- RESTRICCIÓN DE SALIDA (Opcional) ---
    % Los servos reales no entienden ángulos negativos. 
    % Si el cálculo da negativo (ej: -10), a veces conviene sumar 360 o 
    % simplemente avisar de que está fuera de rango mecánico.
end