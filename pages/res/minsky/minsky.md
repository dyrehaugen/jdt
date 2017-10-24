---
title: Modelling Financial Instability
keywords: varia
last_updated: July 10, 2017
tags: [varia]
summary: "A C++ program to modell financial instability based on Steve Keen andMatheus Grasselli"
sidebar: minsky_sidebar
permalink: minsky.html
folder: var
---

Steve Keen and Matheus Grasselli et. al. have developed a simple model of debt-deflation.
Here is the [pdf]({{ site.url}}/pdf/grasselli.pdf) of Grasselli and Costa Lima's article.
The work is a mathematical formulation of Hyman Minsky's
[Financial Instability Hypothesis](https://en.wikipedia.org/wiki/Financial_instability_hypothesis#Minsky.27s_financial_instability_hypothesis)

The basic system consist of four differential equations:

$$\dot{\omega} = \omega [ \Phi (\lambda) - \alpha ]$$


$$\dot{\lambda} = \lambda [	   \frac{ \kappa ( 1 - \omega - r d )}{ \nu } - \alpha - \beta - \delta ]$$


$$\dot{d} = d [ r - \frac{ \kappa ( 1 - \omega - r d )}{ \nu } + \delta ] + \kappa ( 1 - \omega - r d ) - (1 - \omega) + p$$


$$\dot{p} = p[\Psi(\frac{\kappa(1-\omega - r d )}{\nu } -\delta) - \frac{\kappa(1-\omega - r d )}{\nu}+\delta]$$

The variables involved are:

+ $$\omega$$   - wage share
+ $$\lambda$$  - employment rate
+ $$d$$        - debt
+ $$p$$        - ponzi speculation

$$\Phi (\lambda)$$ is the well known [*Phillips curve*](https://en.wikipedia.org/wiki/Phillips_curve), here specified as

$$\Phi(\lambda) = \frac{\phi_1}{(1 - \lambda)^2} - \phi_0$$

where $$\phi_0$$ are $$\phi_1$$ are constants.
This specification allows for a non-linar relationship between
the wage share and the employment rate.
As $$\lambda$$ moves towards full employment more than proportional
increases in $$\Phi$$ accelerates the relative increase in the wage
share $$\omega$$ through equation (1). $$\alpha$$ is the growth rate of labour productivity.

$$\kappa(1 - \omega - r d)$$ is the investment function. $$(1 - \omega)$$
being the gross profit share and $$r d$$ the costs of servicing debt $$d$$
at interest rate $$r$$, here specified as

$$\kappa(1 - \omega - r d) = \kappa_0 + \kappa_1 e^{\kappa_2(1 - \omega - r d) }$$

with constants $$\kappa_0, \kappa_1$$ and $$\kappa_2$$,
so that investments are an increasing function of profits.
Dividing investments by the *capital-output ratio* $$\nu$$ gives the
increased production.
To arrive at the change in the employment rate $$\lambda$$ in equation (2)
we have to subtract labour productivity increase $$\alpha$$,
growth of work force $$\beta$$ and depriciation $$\delta$$.

The growth rate of the economy becomes:

$$\frac{ \kappa ( 1 - \omega - r d )}{ \nu } - \delta$$

so that  existing debt in equation (3) grows by

$$d [ r - \frac{ \kappa ( 1 - \omega - r d )}{ \nu } + \delta ]$$

pluss investments

$$\kappa ( 1 - \omega - r d )$$

minus profits

$$(1 - \omega)$$

pluss ponzi speculation $$p$$ driven by the growth rate of the economy
as in (4).


The speculation function

$$\Psi(\frac{\kappa(1-\omega - r d )}{\nu } -\delta)$$ 

is here specified as

$$\Psi(1 - \omega - r d) = \Psi_0 + \Psi_1 e^{\Psi_2(1 - \omega - r d) \
}$$

with constants $$\Psi_0, \Psi_1$$ and $$\Psi_2$$
so that speculation increases with the growth rate.







The C++ code can be found [here.](/minskycode.html)


{% include links.html %}

