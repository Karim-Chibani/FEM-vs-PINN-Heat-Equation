# FEM-vs-PINN-Heat-Equation
Comparison between the Finite Element Method (FEM) and Physics-Informed Neural Networks (PINNs) for solving the stationary heat equation.

# Résolution de l'équation de la chaleur par la méthode des éléments finis (FEM) et les Physics-Informed Neural Networks (PINNs)

## Présentation

Ce projet présente la résolution numérique d'un problème stationnaire de conduction thermique dans un matériau hétérogène. Deux approches sont étudiées et comparées :

- **La méthode des éléments finis (FEM)** implémentée sous **MATLAB**.
- **Les Physics-Informed Neural Networks (PINNs)** implémentés sous **PyTorch**.

L'objectif est de comparer les performances des deux méthodes pour résoudre une équation aux dérivées partielles avec une conductivité thermique discontinue.

---

## Modélisation mathématique

On considère un problème de conduction thermique stationnaire dans un domaine carré $\Omega=(0,1)\times(0,1)\subset\mathbb{R}^{2}$.

Le problème étudié est :

$$
-\nabla \cdot \left(k(x,y)\nabla u\right)=1000, \qquad \text{dans } \Omega,
$$

avec des conditions aux limites de Dirichlet homogènes :

$$
u=0, \qquad \text{sur } \partial\Omega.
$$

La conductivité thermique $k(x,y)$ est discontinue à l'interface $x = 0.5$ :
- $k(x,y) = 205$ pour $x < 0.5$
- $k(x,y) = 50$ pour $x \ge 0.5$

Ce problème est **linéaire**, car l'inconnue $u$ et son gradient apparaissent de manière linéaire dans l'équation. L'existence et l'unicité de la solution faible sont établies à l'aide du **théorème de Lax–Milgram**, après formulation faible du problème.

---

## Méthodes numériques

### Méthode des éléments finis (MATLAB)

Les principales étapes sont :
- Génération du maillage triangulaire structuré.
- Utilisation des éléments finis linéaires $P_1$.
- Construction de la matrice de rigidité globale (utilisation de matrices creuses `sparse`).
- Assemblage du système linéaire.
- Application des conditions de Dirichlet (méthode de réduction des nœuds libres).
- Résolution du système linéaire $K U = F$.

---

### Physics-Informed Neural Networks (PyTorch)

Le réseau de neurones (MLP) est entraîné en minimisant une fonction de perte basée sur le résidu de l'EDP :
- Intégration stricte des conditions aux limites (*Hard Enforcement* dans le `forward`).
- Évaluation des dérivées secondes par différentiation automatique (`torch.autograd`).
- Optimisation par l'algorithme d'Adam.

---

## Études de Convergence

### 1. Convergence spatiale de la méthode des éléments finis (FEM)
Afin de valider la solution FEM comme solution de référence, une étude de convergence spatiale a été menée en affinant progressivement le maillage ($N_x = N_y \in \{10, 20, 40, 80, 160\}$) :

| Maillage ($N_x \times N_y$) | Nombre de nœuds | Valeur maximale $\max(u)$ | Écart relatif vs $160 \times 160$ | Temps de calcul (s) |
|:---------------------------:|:---------------:|:-------------------------:|:---------------------------------:|:------------------:|
| $10 \times 10$              | 121             | 0.822464                  | $1.18 \, \%$                      | 0.17 s             |
| $20 \times 20$              | 441             | 0.827830                  | $0.53 \, \%$                      | 0.04 s             |
| $40 \times 40$              | 1 681           | 0.831550                  | $0.088 \, \%$                     | 0.18 s             |
| $80 \times 80$              | 6 561           | 0.831911                  | $0.045 \, \%$                     | 1.01 s             |
| **$160 \times 160$**        | **25 921**      | **0.832285**              | **Référence**                     | **13.31 s**        |

> **Conclusion FEM :** La solution se stabilise de manière asymptotique vers $\max(u) \approx 0.8323$. L'écart relatif passant en dessous de $0.05 \, \%$ dès $N = 80$, la solution de référence est scientifiquement validée et indépendante du maillage.

---

### 2. Convergence temporelle du modèle PINN
L'analyse du comportement de la perte (*PDE Loss*) au cours des 6000 époques d'entraînement montre :
- Une décroissance monotone significative de la perte, passant de $1.00 \times 10^6$ à $4.20 \times 10^3$.
- Une phase d'apprentissage rapide et d'adaptation entre l'époque 1300 et 3000.
- La présence d'oscillations contrôlées liées aux sauts stochastiques de l'optimiseur Adam, garantissant une bonne exploration de l'espace des paramètres.

---

## Résultats et Comparaison

Les résultats globaux obtenus sont :

| Indicateur | Valeur |
|------------|---------:|
| Valeur maximale (FEM $160 \times 160$) | 0.832285 |
| Valeur maximale (PINN) | 1.02877 |
| MAE | 0.093796 |
| RMSE | 0.125434 |
| Erreur relative $L^2$ | ~ 30.83 % |

> **Analyse :** L'erreur relative globale $L^2$ de $30.83\,\%$ s'explique par la discontinuité du coefficient de conductivité $k(x,y)$ à $x = 0.5$, entraînant une rupture de pente du gradient de température que les fonctions d'activation lisses (comme `Tanh`) peinent à capturer localement sans raffinement adaptatif.

---

## Structure du projet

Heat-Conduction-FEM-vs-PINN
│
├── MATLAB
│   ├── heat_fem.m
│   └── convergence_fem.m
│
├── PINN
│   ├── pinn_heat.py
│   └── convergence_pinn.py
│
├── Images
│   ├── fem_solution.png
│   ├── pinn_solution.png
│   ├── convergence_fem.png
│   ├── convergence_pinn.png
│   └── comparaison.png
│
├── requirements.txt
│
└── README.md

---

## Technologies utilisées

- **MATLAB** (Calcul matriciel creux, résolution MEF P1)
- **Python / PyTorch** (Scientific Machine Learning, Auto-differentiation)
- **NumPy & Matplotlib** (Traitements de données et visualisations)

---

## Perspectives

Les développements futurs pourront porter sur :
- **Domain Decomposition PINN (XPINNs)** : découpage du domaine au niveau de la discontinuité $x=0.5$ pour adapter les sous-réseaux à chaque conductivité $k$.
- Fonctions d'activation non-lisses (`SiLU` ou `GELU`) et rééchantillonnage adaptatif des points de collocation au voisinage de l'interface.
- Extension aux géométries complexes et conductivités dépendantes de la température.

---

## Auteur

**Karim Chibani**  
Titulaire d'un Master en Mathématiques Appliquées au Calcul Scientifique  
Université Sidi Mohamed Ben Abdellah – Fès









