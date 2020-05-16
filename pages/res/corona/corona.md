---
title:        Modelling the Corona Outbreak
kewords:              
last_updated: May 16,2020    
summary:              
sidebar:      corona_sidebar
permalink:    corona.html  
folder:       corona 
---    



Epidemological modelling has come into focus due to the Corona Crisis.
[The Basic Reproduction Number (R0)](https://en.wikipedia.org/wiki/Basic_reproduction_number)
is a core indicator,
defined as the number of secondary infections that arise from a typical
primary case *in a completely susceptible population*.
In emperical work it may be more convenient to work with The Effective Reproduksjon Number
($$R_{eff}$$ or simply $$R$$). 
This is defined as the number of secondary infections that arise from a typical primary case.

How can this number be calculated?

The time between the symptom onset of the primary and secondary case is usually called
*generation interval*, but sometimes *serial interval* or *generation time*.
This can be empirically observed in detailed outbreak studies and it's distribution
estimated. *Wallinga and Teunis(2004)* found that the generation
intervals observed during the SARS-2 outbreak in Singapore in 2003
to follow a Weibull distribution with a shape parameter α and a scale parameter β,
with values corresponding to a mean generation interval of 8.4 days and a standard deviation of 3.8 days
*Obadia et al (2012)* apply a gamma distribution with mean 2.6 and standard deviation 1.0
for the German 1918 Spanish Flu outbreak.

For an outbreak with a new virus such as Corona/Covid-19 the precise values of parameters
of the generation interval distribution will not be known (i.e. before detailed tracking
studies have been carried out). However, if we can assume the new virus to have similar
distribution characteristics to previously known cases, then the efficient reproduction number R
can be calculated from the growth rate of the confirmed cases in the new outbreak.

*Wallinga and Lipsitch(2007)* (WL) derive the relationship between the outbreak growth rate $$r$$
and the reproduction number $$R$$ from the
[Lotka-Euler equation](https://en.wikipedia.org/wiki/Euler%E2%80%93Lotka_equation)
and the
[moment generating function](https://en.wikipedia.org/wiki/Moment-generating_function)
of the generation interval distribution.
WL discusses varous theoretical generation distributions, but most useful is their
empirical treatment. This approach is in more detail described in *Wallinga and Teunis(2004)*(WT).
WT show that the relative likelihood $$p_{ij}$$ that case $$_{i}$$ has been infected by
case $$_{j}$$, given their difference in time of symptom onset $$t_{i} – t_{j}$$ ,
can be expressed in terms of the probability distribution for the generation interval.










There exists a R implementation in the [R0 Package](https://rdrr.io/cran/R0/) on
[cran r](https://cran.r-project.org/), described in *Obadia(2012)*.
Here we implement the methods by means of [Julia](https://julialang.org/) code.




Links and pdfs:

[Wallinga and Teunis(2004))](https://www.researchgate.net/publication/8361277_Different_Epidemic_Curves_for_Severe_Acute_Respiratory_Syndrome_Reveal_Similar_Impacts_of_Control_Measures)
[pdf]({{ site.url}}/pdf/Wallinga_Teunis_2004_Epidemic_Curves.pdf)

[Wallinga and Lipsitch(2007)](https://royalsocietypublishing.org/doi/10.1098/rspb.2006.3754)
[pdf]({{ site.url}}/pdf/Wallinga_2007_Generation_Intervals.pdf)

[Obadia et al(2012) R0 Package (Article)](https://www.researchgate.net/publication/233948297_The_R0_package_A_toolbox_to_estimate_reproduction_numbers_for_epidemic_outbreaks)
[pdf]({{ site.url}}/pdf/R0_Obadia-2012.pdf)

[R0 Package on cranR](https://rdrr.io/cran/R0/)

[Blasius Julia Github Repository](https://github.com/berndblasius/Covid19)

[Dyrehaugen Jupyter Notebook on Github (Julia Code)](https://github.com/dyrehaugen/jcorona/blob/master/corona.ipynb)

{% include links.html %}


[//]: # [reference](url)
[//]: # [pdf]({{ site.url}}/pdf/pdffile.pdf) 



[//]: # Given a *generation interval distribution* for the disease and *empirical observations* of
[//]: # the outbreak, the Basic Reproduction Number can be estimated. (Formula (3.6) in WL):
[//]: # 
[//]: # $$R = \frac{r}{\sum_{i=1}^{n} y_{i}(e^{-ra_{i-1}} - e^{-ra_{i}}) / (a_{i} - a_{i-1})}$$
[//]: # 
[//]: # Here $$R$$ is the Reproduction Number. $$r$$ is the growth rate of the epidemic.
[//]: # $$a_{i}$$ are the interval borders in a histogram of the empirical distribution of generation intervals. 
[//]: # $$y_{i}$$ are the observed relative frequencies of observed generation intervals.
[//]: # 
[//]: # 


[//]: # EOF
