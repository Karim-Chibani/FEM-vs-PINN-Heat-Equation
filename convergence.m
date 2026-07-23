%% Étude de convergence de la méthode des éléments finis (P1)
clear; clc; close all;

% Paramètres du problème
f_source = 1000;
k_func = @(x, y) 205 * (x < 0.5) + 50 * (x >= 0.5);

% Liste des résolutions de maillage à tester (Nx = Ny)
liste_N = [10, 20, 40, 80, 160];
u_max_liste = zeros(length(liste_N), 1);
temps_calcul = zeros(length(liste_N), 1);

disp('--- Début de l''étude de convergence MEF ---');

for step = 1:length(liste_N)
    Nx = liste_N(step);
    Ny = Nx;
    
    tic; % Début du chrono pour mesurer la vitesse
    
    % 1. Maillage
    x = linspace(0, 1, Nx+1);
    y = linspace(0, 1, Ny+1);
    [X, Y] = meshgrid(x, y);
    nodes = [X(:), Y(:)];
    N_nodes = size(nodes, 1);
    
    N_elements = 2 * Nx * Ny;
    elements = zeros(N_elements, 3);
    elem_counter = 1;
    for j = 1:Ny
        for i = 1:Nx
            n1 = (j-1)*(Nx+1) + i;
            n2 = n1 + 1;
            n3 = j*(Nx+1) + i;
            n4 = n3 + 1;
            elements(elem_counter,   :) = [n1, n2, n4];
            elements(elem_counter+1, :) = [n1, n4, n3];
            elem_counter = elem_counter + 2;
        end
    end
    
    % 2. Assemblage avec Matrice Creuse (Sparse)
    K = sparse(N_nodes, N_nodes);
    F = zeros(N_nodes, 1);
    
    for e = 1:N_elements
        idx = elements(e, :);
        coord = nodes(idx, :);
        
        cg = mean(coord);
        k_element = k_func(cg(1), cg(2));
        
        M = [ones(3,1), coord];
        Area = 0.5 * abs(det(M));
        
        b = [coord(2,2)-coord(3,2); coord(3,2)-coord(1,2); coord(1,2)-coord(2,2)];
        c = [coord(3,1)-coord(2,1); coord(1,1)-coord(3,1); coord(2,1)-coord(1,1)];
        
        Ke = zeros(3,3);
        for i = 1:3
            for j = 1:3
                Ke(i,j) = k_element * (b(i)*b(j) + c(i)*c(j)) / (4 * Area);
            end
        end
        Fe = (f_source * Area / 3) * ones(3, 1);
        
        K(idx, idx) = K(idx, idx) + Ke;
        F(idx) = F(idx) + Fe;
    end
    
    % 3. Conditions aux limites et Résolution (Réduction)
    is_boundary = (nodes(:,1) == 0) | (nodes(:,1) == 1) | ...
                  (nodes(:,2) == 0) | (nodes(:,2) == 1);
    
    free_nodes = find(~is_boundary);
    U = zeros(N_nodes, 1);
    U(free_nodes) = K(free_nodes, free_nodes) \ F(free_nodes);
    
    temps_calcul(step) = toc; % Fin du chrono
    u_max_liste(step) = max(U);
    
    fprintf('Maillage %3dx%3d | u_max = %.6f | Temps = %.4f s\n', ...
            Nx, Ny, u_max_liste(step), temps_calcul(step));
end

%% Tracé du graphique de convergence
figure('Color', 'w');

% Graphique : Convergence de la valeur maximale max(u)
plot(liste_N, u_max_liste, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', [0 0.4470 0.7410]);
grid on;
xlabel('Nombre de subdivisions N (N_x = N_y)', 'FontSize', 11);
ylabel('Valeur maximale max(u)', 'FontSize', 11);
title('Convergence spatiale de la solution MEF (P1)', 'FontSize', 12);

disp('--- Étude terminée avec succès ---');