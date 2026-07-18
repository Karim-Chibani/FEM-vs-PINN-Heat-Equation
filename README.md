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

On considère un problème de conduction thermique stationnaire dans un domaine carré
\(\Omega=(0,1)\times(0,1)\subset\mathbb{R}^2\).

Le problème étudié est

$$
\begin{cases}
-\nabla \cdot \left(k(x,y)\nabla u\right)=1000, & \text{dans } \Omega,\\[6pt]
u=0, & \text{sur } \partial\Omega.
\end{cases}
$$

où $\(u(x,y)\)$ désigne la température.

Ce problème est **linéaire**, car l'inconnue \(u\) et son gradient apparaissent de manière linéaire dans l'équation. L'existence et l'unicité de la solution faible sont établies à l'aide du **théorème de Lax–Milgram**, après formulation faible du problème.

## Méthodes numériques

### Méthode des éléments finis (MATLAB)

Les principales étapes sont :

- Génération du maillage triangulaire.
- Utilisation des éléments finis linéaires \(P_1\).
- Construction de la matrice de rigidité.
- Assemblage du système linéaire.
- Application des conditions de Dirichlet.
- Résolution du système.

---

### Physics-Informed Neural Networks (PyTorch)

Le réseau de neurones est entraîné en minimisant une fonction de perte comprenant :

- le résidu de l'équation différentielle ;
- les conditions aux limites.

Aucun maillage n'est nécessaire pour cette approche.

---

## Résultats

Les résultats obtenus comprennent :

- Distribution de la température par FEM.
- Distribution de la température par PINN.
- Comparaison visuelle entre les deux solutions.
- Évaluation quantitative à l'aide des indicateurs MAE et RMSE.

---

## Comparaison

| Indicateur | Valeur |
|------------|---------:|
| Valeur maximale (FEM) | 0.83164 |
| Valeur maximale (PINN) | 1.02877 |
| MAE | 0.093796 |
| RMSE | 0.125434 |

---

## Structure du projet

```
Heat-Conduction-FEM-vs-PINN
│
├── MATLAB
│   └── heat_fem.m
│
├── PINN
│   └── pinn_heat.py
│
├── Images
│   ├── fem_solution.png
│   ├── pinn_solution.png
│   ├── comparaison.png
│   └── loss.png
│
├── requirements.txt
│
└── README.md
```

---

## Technologies utilisées

- MATLAB
- Python
- PyTorch
- NumPy
- Matplotlib

---

## Perspectives

Les développements futurs pourront porter sur :

- les problèmes non linéaires ;
- les conductivités dépendant de la température ;
- les géométries complexes ;
- les PINNs adaptatifs et la décomposition de domaine.

---

## Auteur

**Karim Chibani**

Titulaire d'un Master en Mathématiques Appliquées au calcul scientifique 

Université Sidi Mohamed Ben Abdellah – Fès
