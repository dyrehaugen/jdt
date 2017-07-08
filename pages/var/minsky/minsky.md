---
title: Minsky
keywords: varia
last_updated: June 26, 2017
tags: [varia]
summary: "Modelling Minsky"
sidebar: minsky_sidebar
permalink: minsky.html
folder: var
---

Steve Keen and Matheus Grasselli et. al. have developed a simple model of debt-deflation.
Here is the [pdf]({{ site.url}}/pdf/grasselli.pdf) of Grasselli and Costa Lima's article. 
The basic system consist of four differential equations:

$$\dot{\omega} = \omega [ \Phi (\lambda) - \alpha ]$$


$$\dot{\lambda} = \lambda [	   \frac{ \kappa ( 1 - \omega - r d )}{ \nu } - \alpha - \beta - \delta ]$$


$$\dot{d} = d [ r - \frac{ \kappa ( 1 - \omega - r d )}{ \nu } + \delta ]$$


$$\dot{p} = p[\psi(\frac{\kappa(1-\omega - r d )}{\nu } -\delta) - \frac{\kappa(1-\omega - r d )}{\nu}+\delta]$$

The variables involved are:

+ $$\omega$$   - wage share
+ $$\lambda$$  - employment rate
+ $$d$$        - debt
+ $$p$$        - ponzi speculation

$$\Phi (\lambda)$$ is the well known [*Phillips curve*](https://en.wikipedia.org/wiki/Phillips_curve), here specified as

$$\Phi(\lambda) = \frac{\phi_1}{(1 - \lambda)^2} - \phi_0$$

where $$\phi_0$$ are $$\phi_1$$ are constants.




The C++ code can be found [here.](/minskycode.html)


{% include links.html %}

