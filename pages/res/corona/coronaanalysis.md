---
title:        Corona Outbreak Analysis
kewords:              
last_updated: May 20, 2020    
summary:              
sidebar:      corona_sidebar
permalink:    coronaanalysis.html  
folder:       corona 
---    

[//]: # (Comments on edit:? )

*Analysis updated 20-05-20*

For the analysis here I select a few countries of particular interest to me:
```
clist  = ["Argentina" "Belgium" "Brazil" "Norway" "Panama" "Spain" "Sweden" "Thailand"]
plist  = [45.195774,  11.589623, 212.559417, 5.421241,4.314767, 46.754778, 10.099265, 67.799978]
```
The numbers are country population fetched from Worldometer.info

How hard hit are these countries?

Let us look at the number of deaths per million inhabitants.

{% include image.html file="corona/dth_03.png" alt="dth_03.png"  %}

The most striking feature is the large dispersion.
This immediately asks for explanations.
A list of explaining factors might include:  population density, urbanization,
demography, general health conditions, commuting and travel,
quality of public Health Services, air pollution, social habits of interaction, etc.

Epidemimological models simplifies all such factors into some *contact parameters* - or
transmission probalilities.
A contagious person is asumed to spread the virus to others through direct or indirect
physical contact. How easily this takes place is also dependent on the specific virus in question.
Where the new Corona (SARS2-Covid-19) virus stays on this scale is not yet known with certainty -
may be more contagious than 'ordinary' influenza.

Epidemological models are *compartmental*. They put the population into *bins* and model how
people move between the bins, taking demographics and physical mobility into consideration. 
How the bins are delineated may differ, simple SIR (Susceptible, Infected, Recovered) or
more complex. NIPH, The Norwegian Institute of Public Health, applies a detailed model
with compartments:

* $$S$$     - Suscpetible, 
* $$E_{1}$$ - Exposed, not infectious, no symptoms
* $$E_{2}$$ - Exposed, presymptomatic, infectious
* $$I_{a}$$ - Infectious, asympotmatic
* $$I$$     - Infectious, sympotmatic
* $$R$$     - Recovered

In this model geographic resolution is very detailed - at the municipality level.
Commuting is considered - people staying in one zone at day (workplace) and another at night (domicile)
carrying the virus around.
Other models might include compartments for *Hospitalized*, *Under Incentive Care*, etc.
Our curve above shows the number of *Deaths*, not included in many models, rather treated as a residual category.
How detailed and which compartments the model includes is of course dependent on it's intended use.
Most models are developed by public health authorities with epidemic management under outbreaks as the
focal issue - i.e. the capacity of hospitals to handle the infected and sick, or on vaccine issues.
The focus here is more macro - how and why the epidemic progresses so differently in different countries.

How is the infectiousness of the epidemic changing over time?

Let us look at the effective reproduction number $$R_{eff}$$ :

{% include image.html file="corona/cfm_05.png" alt="cf_05.png"  %}

Again, the most striking feature is the large dispersion.
The goal of the Public Health Authorities is to get the reproduction number under 1.0 as fast as possible,
and keep it there so the epidemic gradually dies out.
How fast?
The table shows number of days (since first 100 confirmed cases) till $$R_{eff}$$ gets under 1.0 and stays there.

| Country   | Days     |
|-----------|---------:|
| Thailand  |	10     |
| Norway    |   18     |
| Spain	    |   25     |
| Belgium   |   35     |
| Panama    |   50     |

Argentina stays at 1.92 after 52 days, Brazil at 1.74 after 59 days and Sweden at 1.22 after 66 days.
(data updated 200519).
Even worse, Argentina seems to have been on a worrying upwards trend for a long period (10-50 days),
and Brazil is again pointing up at around day 60.
Only Panama has had a clear second wave days 20-40, but has come down to around 1.0 since.

How can such differences be *explained*?

*Belgium* is at the top on our *impact measure* - with 786 deaths per million population.
On our *containment measure* they score in the middle with 35 days.
I do not have specific information on the Belgian epidemic management, so this factor remains open here.
But Belgium is a densely populated and highly urbanized country as well a a major traffic hub with
the EU institutions in Brussels.

*Spain* scores second 	on our *impact measure*	- with 594 deaths per million population.
With 25 days the reproduction number in Spain was brought down  much quicker than in Belgium.
This might explain the lesser impact, although much higher than in the rest of the sample countries.
The deaths in Spain are very concentrated, mainly to Madrid and Barcelona.
And they are concentrated in the Elderly Care Institutions.
I suspect two factors have played an important role: 1) Health Care Working conditions and 2) Pollution.
Health care workers in Spain were told to stay on job in the early phase of
the epidemic, neither could they afford to be home with light symptoms.
Some 20-25% of all confirmed cases in Spain is hospital workers.
In Norway they were from start told to stay home if they felt a little unwell.
Madrid and Barcelona are heavily polluted regions - as are the European craddle in Lombardy.
[Ogen's study](https://doi.org/10.1016/j.scitotenv.2020.138605)
[[pdf]({{ site.url}}/pdf/corona/Ogen_2020_Nitrogen_Pollution_Corona.pdf)
reveils that the epidemic has been much worse in heavily polluted areas than elsewhere.
If the virus is able to travel by attaching to microparticles in polluted air *social distancing*
cannot cope.
For Spain the celebrations of 'Women's Day' 8 of March in Barcelona with large congregations in the beginning of
the epidemic, but before lockdown (March 14) were a perfect timing of a *superspread event*.

*Sweden* scores third   on our *impact measure* - with 371 deaths per million population -
and has yet to get the reproduction number -as we calculate it- under 1.0, as of day 66.
Sweden deliberately choosed an *openness strategy* - aiming to fast gain *herd immunity*,
with much weaker lockdown measures, if at all.
We do not have numbers for percentage of people who have gained immunity (nor for how long) -
only future studies can bring forward such figures.
So eeven if the Swedish strategy will end up as the best in the long run, it certainly
has big costs in the shorter term.
[Turchin](http://peterturchin.com/cliodynamica/a-tale-of-two-countries/)
consideres these issues in a comparision with *Denmark* (not in our sample)
without reaching any firm conclusion.
Similar to Spain, Sweden seems to have a lot of deaths concentrated in Elderly Care Institutions.
Sweden has a very large immigrant population with a mixture of nationalities working in such
institutions - a factor that may have complicated the enforcement of strict and new regimes of
hygiene and behaviour due to the virus risks.


*Norway* (together with Denmark) quickly introduced lockdown measures (although not as heavily as Spain)
and also fast got the reproduction number under the critical level (18 days).
One of the first confirmed cases were identified by a doctor in a major hospital returning from ski-holiday.
The Hospital administration asked him to stay on work even if he had mild symptoms and wanted to stay home.
This initial error forced several hundreds patients and hospital workers into quaranteen and caused
major alarm. After that very strict measures to keep potentially contagious personell at home.
Norway thus have a much lower death rate in institutions for elderly than Sweden.

*Panama* looks like the epidemic is underway to be contained.

*Brazil* do not have control  and the epidemic is progressing fastly.

*Argentina* seems to be on a very bad course.

*Thailand* seems to be a success story









[//]: # ................................................

Links:

[Cori Time-Varying Reproduction Numbers (2013)](https://academic.oup.com/aje/article/178/9/1505/89262)
[pdf]({{ site.url}}/pdf/corona/Cori_2013_Time_Varying_Reproduction.pdf)

[Engebretsen Spread Model (Article) (2019)](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1006879)
[pdf]({{ site.url}}/pdf/corona/Engebretsen_2019_Spread_Model_Article.pdf)

[EpiEstim Package on CranR](https://cran.r-project.org/web/packages/EpiEstim/index.html)

[NIPH Coronavirus Modelling Web Page](https://www.fhi.no/en/id/infectious-diseases/coronavirus/coronavirus-modelling-at-the-niph-fhi/)

[NIPH Modelling Report 200516 (pdf)](https://www.fhi.no/contentassets/e6b5660fc35740c8bb2a32bfe0cc45d1/vedlegg/nasjonale-rapporter/2020.05.16-corona-report.pdf)
[pdf]({{ site.url}}/pdf/corona/NIPH_200516-Corona-Modelling_Report.pdf)

[NIPH Spread Model on GitHub](https://github.com/folkehelseinstituttet/spread)

[NIPH Spread Model Package on CranR](https://cran.r-project.org/web/packages/spread/index.html)

[Ogen on Nitrogen Pollution and Corona](https://doi.org/10.1016/j.scitotenv.2020.138605)
[pdf]({{ site.url}}/pdf/corona/Ogen_2020_Nitrogen_Pollution_Corona.pdf)

[Pyeyo (2020) Pandemic Politics](https://osf.io/preprints/socarxiv/vb5q3)
[pdf]({{ site.url}}/pdf/corona/Pueyo_2020_Pandemic_Politics.pdf)

[Salje (2020) Estimating SARS-CoV-2 France](https://science.sciencemag.org/content/early/2020/05/12/science.abc3517)
[pdf]({{ site.url}}/pdf/corona/Salje_2020_Estimating_SARS-Cov2_Burden_in_France.pdf)


[Turchin on Effectiveness of Public Health Measures](http://peterturchin.com/cliodynamica/how-effective-are-public-health-measures-in-stopping-covid-19/)

[Turchin on Denmark vs Sweden](http://peterturchin.com/cliodynamica/a-tale-of-two-countries/)

[Turchin R-model on Github](http://peterturchin.com/cliodynamica/how-effective-are-public-health-measures-in-stopping-covid-19/)


{% include links.html %}

[//]: # {% include image.html file="imagefile.png" alt="imagename"  %}
[//]: # [pdf]({{ site.url}}/pdf/corona/pdffile.pdf)
[//]: # [reference](url)
[//]: # [intraref](/jdt/file.html)

[//]: # EOF
