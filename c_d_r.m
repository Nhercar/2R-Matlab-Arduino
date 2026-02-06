function [x, y] = c_d_r(q1_grados, q2_grados, L1, L2)
% SOLUCIONARIO DEL PROFESOR
% Calcula la posición del extremo del robot 2-DOF usando Matrices DH

    % 1. Conversión a Radianes
    q1 = deg2rad(q1_grados);
    q2 = deg2rad(q2_grados);

    % 2. Definición de parámetros DH [theta, d, a, alpha]
    % q1 y q2 son variables, d y alpha son 0 en robot plano
    dh_params = [
        q1, 0, L1, 0;  % Eslabón 1
        q2, 0, L2, 0   % Eslabón 2
    ];

    % 3. Cálculo de Matrices de Transformación
    
    % T01: De Base a Eslabón 1
    T01 = calcular_matriz_dh(dh_params(1,1), dh_params(1,2), dh_params(1,3), dh_params(1,4));
    
    % T12: De Eslabón 1 a Eslabón 2
    T12 = calcular_matriz_dh(dh_params(2,1), dh_params(2,2), dh_params(2,3), dh_params(2,4));
    
    % 4. Cinemática total (Multiplicación matricial)
    T_total = T01 * T12;
    
    % 5. Extracción de coordenadas (Vector de posición P)
    % La última columna contiene [Px; Py; Pz; 1]
    x = T_total(1, 4); 
    y = T_total(2, 4);
    
    % --- VERIFICACIÓN ANALÍTICA (Opcional, para debug) ---
    % x_check = L1*cos(q1) + L2*cos(q1 + q2);
    % y_check = L1*sin(q1) + L2*sin(q1 + q2);
    % Si x y x_check son iguales, las matrices están bien.
end

function T = calcular_matriz_dh(theta, d, a, alpha)
    % Implementación de la matriz estándar DH
    T = [cos(theta), -sin(theta)*cos(alpha),  sin(theta)*sin(alpha), a*cos(theta);
         sin(theta),  cos(theta)*cos(alpha), -sin(theta)*sin(alpha), a*sin(theta);
         0,           sin(alpha),             cos(alpha),            d;
         0,           0,                      0,                     1];
end