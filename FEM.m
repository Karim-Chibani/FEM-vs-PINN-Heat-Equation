%% 1. Définition du problème
% Équation : -div(k*grad(u)) = 1000 sur [0,1]x[0,1]
% CL : u = 0 sur les bords (Dirichlet)
f_source = 1000; 

% Fonction pour la conductivité discontinue k(x,y)
k_func = @(x, y) 205 * (x < 0.5) + 50 * (x >= 0.5);

%% 2. Création du maillage (Maillage triangulaire structuré)
Nx = 100; Ny = 100; % Nombre de subdivisions en x et y
x = linspace(0, 1, Nx+1);
y = linspace(0, 1, Ny+1);
[X, Y] = meshgrid(x, y);
nodes = [X(:), Y(:)]; % Matrice des nœuds (N_noeuds x 2)
N_nodes = size(nodes, 1);

% Génération des triangles (éléments P1)
elements = [];
for j = 1:Ny
    for i = 1:Nx
        % Indices des 4 nœuds d'une cellule carrée
        n1 = (j-1)*(Nx+1) + i;
        n2 = n1 + 1;
        n3 = j*(Nx+1) + i;
        n4 = n3 + 1;
        % Découpage du carré en 2 triangles
        elements = [elements; n1, n2, n4; n1, n4, n3];
    end
end
N_elements = size(elements, 1);

%% 3. Choix des éléments finis (P1)
% Les fonctions de forme P1 sont linéaires par élément.
% Les gradients de ces fonctions sur un triangle sont constants.

%% 4. Initialisation de K et F
K = zeros(N_nodes, N_nodes); % Matrice de rigidité globale
F = zeros(N_nodes, 1);       % Vecteur force global

%% 5 & 6. Calcul de Ke/Fe et Assemblage
for e = 1:N_elements
    % Nœuds de l'élément courant
    idx = elements(e, :);
    coord = nodes(idx, :); % Coordonnées des 3 sommets
    
    % Calcul du centre de gravité pour évaluer k(x,y)
    cg = mean(coord);
    k_element = k_func(cg(1), cg(2));
    
    % Matrice de passage / Calcul de l'aire du triangle
    % Aire = 0.5 * det([1, x1, y1; 1, x2, y2; 1, x3, y3])
    M = [ones(3,1), coord];
    Area = 0.5 * abs(det(M));
    
    % Gradients des fonctions de forme P1 (Formule analytique)
    % N_i(x,y) = (a_i + b_i*x + c_i*y) / (2*Area)
    b = [coord(2,2)-coord(3,2); coord(3,2)-coord(1,2); coord(1,2)-coord(2,2)];
    c = [coord(3,1)-coord(2,1); coord(1,1)-coord(3,1); coord(2,1)-coord(1,1)];
    
    % Calcul de Ke (Matrice de rigidité élémentaire)
    Ke = zeros(3,3);
    for i = 1:3
        for j = 1:3
            Ke(i,j) = k_element * (b(i)*b(j) + c(i)*c(j)) / (4 * Area);
        end
    end
    
    % Calcul de Fe (Vecteur charge élémentaire - Intégration exacte pour f constante)
    Fe = (f_source * Area / 3) * ones(3, 1);
    
    % Assemblage dans les structures globales
    K(idx, idx) = K(idx, idx) + Ke;
    F(idx) = F(idx) + Fe;
end

%% 7. Application des conditions aux limites (Dirichlet u=0)
% Identification des nœuds sur le bord
is_boundary = (nodes(:,1) == 0) | (nodes(:,1) == 1) | ...
              (nodes(:,2) == 0) | (nodes(:,2) == 1);
boundary_nodes = find(is_boundary);

% Méthode de pseudo-élimination (pénalisation ou forçage)
for i = 1:length(boundary_nodes)
    idx = boundary_nodes(i);
    K(idx, :) = 0;
    K(idx, idx) = 1;
    F(idx) = 0; % Valeur de Dirichlet (u = 0)
end

%% 8. Résolution du système KU = F
U = K \ F;

%% 9. Visualisation des résultats
figure('Color', 'w');
trisurf(elements, nodes(:,1), nodes(:,2), U, 'EdgeColor', 'none');
view(3);
grid on;
colorbar;
title('Approximation P1 de la solution u(x,y)');
xlabel('X'); ylabel('Y'); zlabel('u(x,y)');
shading interp; % Lissage visuel
max(U)


%% --- EXPORTATION DES DONNÉES DIRECTES EN CSV ---

% 1. استخراج إحداثيات X و Y من مصفوفة nodes اللي عندك ف الكود
X_nodes = nodes(:, 1);
Y_nodes = nodes(:, 2);

% 2. جمع الإحداثيات والحل U ف جدول واحد (Table)
% (ملاحظة: U خاص يكون عمود، إيلا كان سطر كدير ليه U')
csv_table = table(X_nodes, Y_nodes, U, 'VariableNames', {'X', 'Y', 'U_matlab'});

% 3. كتابة الجدول ف ملف CSV
writetable(csv_table, 'solution_matlab_direct.csv');

disp('¡ Fichier "solution_matlab_direct.csv" créé avec succès !');