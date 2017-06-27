---
title: Minsky
keywords: varia
last_updated: June 26, 2017
tags: [varia]
summary: "Modelling Minsky"
sidebar: var_sidebar
permalink: minsky.html
folder: var
---

Steve Keen and Matheus Grasselli have developed a simple model of debt-deflation.


(1) $$\dot{\omega} = \omega [ \Phi (\lambda) - \alpha ]$$


(2) $$\dot{\lambda} = \lambda [	   \frac{ \kappa ( 1 - \omega - r d )}{ \nu } - \alpha - \beta - \delta ]$$


(3) $$\dot{d} = d [ r - \frac{ \kappa ( 1 - \omega - r d )}{ \nu } + \delta ]$$


(4) $$\dot{p} = p [ \psi ( \frac{ \kappa ( 1 - \omega - r d )}{ \nu } -\delta) - \frac{ \kappa ( 1 - \omega\
 - r d )}{ \nu } + \delta ]$$

I have put this into c++ code.
This makes it easy to check sensitivity of choice of initial parameters settings.



```c++
// ~/xlin/gsl/testminsky.cc
// 150924 003 Task now -> grid
// Basert på 150921 001 testminskyall.cc
// Unified source for (74) and (77) variants
//
// Todo:  Endre kappa def til arctan ? (se:'destabilizing..') 
//           

// GSL Manual 26.6
//  http://stackoverflow.com/questions/27913858/how-to-consult-gsl-ode-with-many-parameters-and-harmonic-functions
// http://www.tutorialspoint.com/matlab/matlab_differential.htm
// Løser differentialene vha octave-symbolic se ~/xoct/minsky/differentiate.
// Transformerer octave-løsningene til c++ (e)^ -> exp() og x^y -> pow(x,y)
// se testdiff.cpp i ~/xlin/cpp/scratch
// rk8 bruker ikke jac fjernet f.o.m versjon 014
//
#include <stdio.h>
#include <gsl/gsl_errno.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_odeiv2.h>

#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iomanip> // setiosflags(ios::fixed)
#include <limits>
#include <map>
#include <string>
#include <sstream>
#include <vector>

#include <boost/array.hpp>
#include <boost/tuple/tuple.hpp>
#include <boost/foreach.hpp>
#include <unistd.h>

using namespace std;

// Warn about use of deprecated functions.
#define GNUPLOT_DEPRECATE_WARN
#include "gnuplot-iostream.h"

#ifndef M_PI
#       define M_PI 3.14159265358979323846
#endif

inline void mysleep(unsigned millis){
  ::usleep(millis * 1000);
}

//http://stackoverflow.com/questions/7248627/setting-width-in-c-output-stream:
class formatted_output
{
private:
  int width, precision;
  std::ostream& stream_obj;
public:
  formatted_output(std::ostream& obj, int w, int p): width(w), precision(p),stream_obj(obj) {}
  template<typename T>
  formatted_output& operator<<(const T& output)  {
    stream_obj << std::fixed << std::setw(width) << std::setprecision(precision) << output;
    return *this;
  }
  formatted_output& operator<<(std::ostream& (*func)(std::ostream&))  {
    func(stream_obj);
    return *this;
  }
};

struct param_type {
  int eqset;
  double alfa;
  double beta;
  double delta;
  double nu;
  double r;
  double k1;
  double k2; 
  double k3;
  double k4;
  double k5;
  double k6;
  double k7;
  double k8;
} ;

double kappa(double k1, double k2, double k3, double profit){
  double response;
  response = k1 + exp(k2) * exp( k3 * profit);
  return response;
}  


double phi(double k4, double empshare){
  double response;
  response = (pow(k4,3)/(1.0-pow(k4,2)))/pow((1.0 - empshare),2) - k4/(1.0-pow(k4,2));
  return response;
}


double psi(double k5, double k6, double k7, double k8, double growthrate){
  double response;
  response = k5 + k6* exp(k7)*exp(k8 * growthrate);
  return response;
}

int func (double t, const double y[], double f[],
           void *params)
     {
       struct param_type *my_params_pointer = (param_type*) params;
        int eqset     = my_params_pointer->eqset;
	double alfa   = my_params_pointer->alfa;
	double beta   = my_params_pointer->beta;
	double delta  = my_params_pointer->delta;
	double nu     = my_params_pointer->nu;
	double r      = my_params_pointer->r;
	double k1     = my_params_pointer->k1;
	double k2     = my_params_pointer->k2;
	double k3     = my_params_pointer->k3;
	double k4     = my_params_pointer->k4;
	double k5     = my_params_pointer->k5;
	double k6     = my_params_pointer->k6;
	double k7     = my_params_pointer->k7;
	double k8     = my_params_pointer->k8;

        if (eqset == 74) {
	  f[0] =  y[0] * ( phi(k4, y[1]) - alfa) ;
	  f[1] =  y[1] * ( kappa(k1, k2, k3, 1 - y[0] - r * y[2]) /nu  - alfa - beta -delta);
	  f[2] =  y[2] * ( r -  kappa(k1, k2, k3, 1 - y[0] - r* y[2])/nu + delta) + kappa(k1, k2, k3,1 - y[0] - r * y[2]) - (1 - y[0]) + y[3];
	  f[3] =  y[3] * ( psi(k5, k6, k7, k8, kappa(k1, k2, k3, 1 - y[0] -r*y[2]) / nu  - delta) + kappa(k1, k2, k3, 1 - y[0] - r * y[2]) / nu - delta );
	}
	
	if (eqset == 77) {
	  f[0] =  y[0] * ( phi(k4, y[1]) - alfa) ;
	  f[1] =  y[1] * (( kappa(k1, k2, k3, 1 - y[0] - r/( y[2] * y[3] )) /nu ) - alfa - beta -delta);
	  f[2] =  y[2] * ( psi(k5, k6, k7, k8, kappa(k1, k2, k3, 1 - y[0] -r/(y[2] * y[3] )) / nu - delta) - r) - ( y[2] * y[2] * ( y[3] * kappa(k1, k2, k3,1 - y[0] - r/(y[2] * y[3])) - y[3] * (1 - y[0]) + 1 ));
	  f[3] =  y[3] * ( -psi(k5, k6, k7, k8, ( kappa(k1, k2, k3, 1 - y[0] -r/(y[2] * y[3])) / nu ) - delta) + (kappa(k1, k2, k3, 1 - y[0] - r/( y[2] * y[3] )) / nu) - delta );
	}

        return GSL_SUCCESS;
     }

     // fjernet - finnes i minsky.jac.cc = minsky.013.cc    
     /*
     int jac (double t, const double y[], double *dfdy, 
          double dfdt[], void *params)
     {
      return GSL_SUCCESS;
     }
     */


int main(int argc, char **argv) {

       if (argc < 2) {
         std::cout << "Usage: minsky eqset (74|77) [omega lambda d|upsilon  p|x num_steps])" << endl;
         exit(0);
       }

       int eqset = 74;	 
       if (argc > 1) eqset   = atoi(argv[1]);
       cout << eqset << endl; // CONTROL
       if (eqset != 74 && eqset != 77) {
         std::cout << "eqset has to be either 74 or 77" << endl;
         exit(0);
       }
       double y[4] = { 0.0, 0.0, 0.0, 0.0 } ; 
       if (eqset == 74){
	 //y[4] = { 0.95, 0.9, 0.0, 0.001 } ;   // omega, lambda, d, p
	 y[0] = 0.95;
	 y[1] = 0.9;
	 y[2] = 0.0;
	 y[3] = 0.001;
       }
       if (eqset == 77) {
	 //y[4] = { 0.95, 0.9, 0.12, 100 } ;   // omega, lambda, upsilon, x
	 y[0] = 0.95;
	 y[1] = 0.9;
	 y[2] = 0.12;
	 y[3] = 100.0;
	 
       }
       int num_steps = 100;
         
       if (argc > 2) y[0] = atof(argv[2]);
       if (argc > 3) y[1] = atof(argv[3]);
       if (argc > 4) y[2] = atof(argv[4]);
       if (argc > 5) y[3] = atof(argv[5]);
       if (argc > 6) num_steps = atoi(argv[6]);

       Gnuplot gp1;
       Gnuplot gp2;
       Gnuplot gp3;
       Gnuplot gp4;      

       std::ostringstream oss;
       oss << "set title \"";
       for (int j = 0; j < argc; j++)
	 { oss << argv[j] << ' '; }
       oss << "\\n\"" << std::endl ;
       std::cout << oss.str() << std::endl;

       std::ofstream funkout("minsky.funk.out");
       std::ofstream varout("minsky.var.out");       
       formatted_output fout(funkout, 16, 6);
       formatted_output vout(varout, 12, 6);              

       std::vector<std::pair<double, double> > xy_pts_A; // omega
       std::vector<std::pair<double, double> > xy_pts_B; // lambda
       std::vector<std::pair<double, double> > xy_pts_C; // d         // upsilon
       std::vector<std::pair<double, double> > xy_pts_D; // p         // x

       std::vector<std::pair<double, double> > xy_pts_E; // p (ponzi)      
       std::vector<std::pair<double, double> > xy_pts_F; // d (debt)
       std::vector<std::pair<double, double> > xy_pts_G; // g (growth)
       std::vector<std::pair<double, double> > xy_pts_Y; // Y

       double alfa   = 0.025;
       double beta   = 0.02;
       double delta  = 0.01;
       double nu     = 3.0;
       double r      = 0.03;
       double k1     = -0.0065;
       double k2     = -5 ;
       double k3     =  20;
       double k4     = 0.04;
       double k5     = -0.25;
       double k6     = 0.25;
       double k7     = -0.36;
       double k8     = 12.0;
       double growth = 0.0;
       double Y      = 0.0;

       double zphi;
       double zkappa;
       double zpsi;
       
       if (eqset == 74) {
         growth = kappa(k1, k2, k3, 1 - y[0] - r * y[2]) / nu - delta;
       }
       else if (eqset == 77) {
	 growth = kappa(k1, k2, k3, 1 - y[0] - r/( y[2] * y[3] )) / nu - delta;
       }
       Y = 100.0 * ( 1.0 + growth);
       
       struct param_type my_params = {eqset, alfa, beta, delta, nu, r, k1, k2, k3, k4, k5, k6, k7, k8 };

       // gsl_odeiv2_system sys = {func, jac, 4, &my_params};
       // http://www.physics.buffalo.edu/phy411-506/tools/gsl/ode/index.html
       // rk8pd bruker ikke jac settes til NULL:
       // gsl_odeiv2_system sys = {func, jac, 4, &my_params};
       gsl_odeiv2_system sys = {func, NULL, 4, &my_params};
       gsl_odeiv2_driver * d = 
       gsl_odeiv2_driver_alloc_y_new (&sys, gsl_odeiv2_step_rk8pd,
					1e-6, 1e-6, 0.0);
       int i = 0;

       double t = 0.0, t1 = 100.0;

       xy_pts_A.push_back(std::make_pair(t, y[0]));             //omega
       xy_pts_B.push_back(std::make_pair(t, y[1]));		//lambda	    
       xy_pts_C.push_back(std::make_pair(t, y[2]));             //d|upsilon
       xy_pts_D.push_back(std::make_pair(t, y[3]));		//p|x
       
       if (eqset == 77) {
	 xy_pts_E.push_back(std::make_pair(t, 1 / y[3]));         //ponzi
	 xy_pts_F.push_back(std::make_pair(t, 1 / y[3] / y[2]));  //debt
       }
       xy_pts_G.push_back(std::make_pair(t, growth));           //growth
       xy_pts_Y.push_back(std::make_pair(t, Y));                //Y

       zphi   = phi(k4, y[1]);
       if (eqset == 74) {
	 zkappa = kappa(k1, k2, k3, 1 - y[0] - r * y[2]);
	 zpsi   = psi(k5, k6, k7, k8, kappa(k1, k2, k3, 1 - y[0] -r * y[2]) / nu - delta);
       }
       if (eqset == 77) {
	 zkappa = kappa(k1, k2, k3, 1 - y[0] - r/( y[2] * y[3] ));
	 zpsi   = psi(k5, k6, k7, k8, kappa(k1, k2, k3, 1 - y[0] -r/(y[2] * y[3] )) / nu - delta);
       }
       fout << oss.str() << std::endl;
       fout << "t" << "phi" <<"kappa" << "psi" << std::endl;
       fout << t << zphi << zkappa << zpsi << std::endl;       

       vout << oss.str() << std::endl;
       if (eqset == 74)  {
	 vout << "t" << "omega" <<"lambda" << "d" << "p" << "growth" << "Y"  << std::endl;
	 vout << t  << y[0] << y[1] << y[2] << y[3] << growth << Y <<std::endl;       
       }
       if (eqset == 77) {
 	 vout << "t" << "omega" <<"lambda" << "upsilon" << "debt" << "ponzi" << "x" << "growth" << "Y"  << std::endl;
	 vout << t  << y[0] << y[1] << y[2] << y[3] <<  1/y[3]/y[2] <<1/y[3] << growth << Y <<std::endl;       }
       if (eqset == 74) {
	 printf ("%6s %10s %10s %10s %10s %10s %10s %10s %10s\n", "t","omega","lambda","d","p","","","growth","Y");
	 printf ("%6.0f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f\n", t, y[0], y[1], y[2], y[3], 0.0, 0.0, growth, Y);
       }
       if (eqset == 77) {
         printf ("%6s %10s %10s %10s %10s %10s %10s %10s %10s\n", "t","omega","lambda","upsilon","x","ponzi","debt","growth","Y");
         printf ("%6.0f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f\n", t, y[0], y[1], y[2], y[3], 1/y[3]/y[2], 1/y[3],growth, Y);
       }

       
       for (i = 1; i <= num_steps; i++)
         {
           double ti = i * t1 / 100.0;
           int status = gsl_odeiv2_driver_apply (d, &t, ti, y);
           if (status != GSL_SUCCESS)
	     {
	       printf ("error, return value=%d\n", status);
	       break;
	     }

           //Funksjonsverdiene:
	   zphi   = phi(k4, y[1]);
	   if (eqset == 74) {
	     zkappa = kappa(k1, k2, k3, 1 - y[0] - r * y[2]);
	     zpsi   = psi(k5, k6, k7, k8, kappa(k1, k2, k3, 1 - y[0] -r *y[2]) / nu - delta);
	     growth = kappa(k1, k2, k3, 1 - y[0] - r* y[2]) / nu - delta;
	   }
	   if (eqset == 77) {
	     zkappa = kappa(k1, k2, k3, 1 - y[0] - r/( y[2] * y[3] ));
	     zpsi   = psi(k5, k6, k7, k8, kappa(k1, k2, k3, 1 - y[0] -r/(y[2] * y[3] )) / nu - delta);
	     growth = kappa(k1, k2, k3, 1 - y[0] - r/( y[2] * y[3] )) / nu - delta;
	   }
	   Y = Y * ( 1 + growth);

	   fout << t << zphi << zkappa << zpsi << std::endl;
	   vout << t << y[0] << y[1] << y[2] << y[3] << growth << Y <<std::endl;       	   
	   if (eqset == 74) {
	     printf ("%6.0f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f\n", t, y[0], y[1], y[2], y[3], 0.0, 0.0, growth, Y);
	   }
	   if (eqset == 77) {
	     printf ("%6.0f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f\n", t, y[0], y[1], y[2], y[3], 1/y[3]/y[2], 1/y[3], growth, Y);
	   }
 	   xy_pts_A.push_back(std::make_pair(t, y[0]));
	   xy_pts_B.push_back(std::make_pair(t, y[1]));			    
	   xy_pts_C.push_back(std::make_pair(t, y[2]));
	   xy_pts_D.push_back(std::make_pair(t, y[3]));			    
	   if (eqset == 77) {
	     xy_pts_E.push_back(std::make_pair(t, 1 / y[3]));         //ponzi
	     xy_pts_F.push_back(std::make_pair(t, 1 / y[3] / y[2]));  //debt
	   }
	   xy_pts_G.push_back(std::make_pair(t, growth)); //growth
           xy_pts_Y.push_back(std::make_pair(t, Y)); //Y
	 }
     
       gsl_odeiv2_driver_free (d);

       // GNPLOTS:
       if (eqset == 74){
	 // Omega & Lambda:
	 gp1 << "set terminal x11 1 persist size 640,450 position 50,50\n";
	 gp1 << "set grid\n";
	 gp1 << oss.str() ; // Title string
	 gp1 << "set ylabel 'omega lambda'\n";
	 gp1 << "plot '-' with lines title 'omega', '-' with lines title 'lambda'\n";
	 gp1.send1d(xy_pts_A);
	 gp1.send1d(xy_pts_B);
	 // p & d:
	 gp2 << "set terminal x11 1 persist size 640,450 position 50,536\n";
	 gp2 << "set grid\n";
	 gp2 << oss.str() ; // Title string
	 gp2 << "set ylabel 'p\n";
	 gp2 << "set y2label 'd'\n";
	 gp2 << "set y2tics\n";
	 //gp2 << "plot '-' with lines title 'd\n";
 	 gp2 << "plot '-' with lines title 'p', '-' with lines  title 'd' axes x1y2\n";
	 gp2.send1d(xy_pts_D);
	 gp2.send1d(xy_pts_C);
	 
	 /*	 // p:
	 gp3 << "set terminal x11 1 persist size 640,450 position 690,536\n";
	 gp3 << "set grid\n";
	 gp3 << oss.str() ; // Title string
	 gp3 << "set ylabel 'p\n";
	 gp3 << "plot '-' with lines title 'p\n";
	 gp3.send1d(xy_pts_D);
	 */
       }

       if (eqset == 77) {
	 // Omega & Lambda & Upsilon & X:
	 gp1 << "set terminal x11 1 persist size 640,450 position 50,50\n";
	 gp1 << "set grid\n";
	 gp1 << oss.str() ; // Title string
	 gp1 << "set ylabel 'omega lambda upsilon'\n";
	 gp1 << "set y2label 'x'\n";
	 gp1 << "set y2tics\n";
	 gp1 << "plot '-' with lines title 'omega', '-' with lines title 'lambda', '-' with lines title 'upsilon','-' with lines  title 'x' axes x1y2\n";
	 gp1.send1d(xy_pts_A);
	 gp1.send1d(xy_pts_B);
	 gp1.send1d(xy_pts_C);
	 gp1.send1d(xy_pts_D);
	 // Ponzi & Debt: 
	 gp2 << "set terminal x11 2 persist size 640,450 position 50,536\n";
	 gp2 << "set grid\n";
	 gp2 << oss.str() ; // Title string
	 gp2 << "set ylabel 'ponzi'\n";
	 gp2 << "set y2label 'debt'\n";
	 gp2 << "set y2tics\n";
	 gp2 << "plot '-' with lines title 'ponzi', '-' with lines title 'debt' axes x1y2\n";
	 gp2.send1d(xy_pts_E);
	 gp2.send1d(xy_pts_F);
       }		    
       //  p/ponzi & growth:
       gp3 << "set terminal x11 2 persist size 640,450 position 690,50\n";
       gp3 << "set grid\n";
       gp3 << oss.str() ; // Title string
       gp3 << "set ylabel 'p/ponzi'\n";
       gp3 << "set y2label 'growthi'\n";
       gp3 << "set y2tics\n";
       gp3 << "plot '-' with lines title 'p/ponzi', '-' with lines title 'growth' axes x1y2\n";
       if (eqset == 74) gp3.send1d(xy_pts_D);
       if (eqset == 77) gp3.send1d(xy_pts_E);              
       gp3.send1d(xy_pts_G);        

       //  Y & d/debt:
       gp4 << "set terminal x11 2 persist size 640,450 position 690,536\n";
       gp4 << "set grid\n";
       gp4 << oss.str() ; // Title string
       gp4 << "set ylabel 'Y'\n";
       gp4 << "set y2label 'd/debt'\n";
       gp4 << "set y2tics\n";
       gp4 << "plot '-' with lines title 'Y', '-' with lines title 'd/debt' axes x1y2\n";
       gp4.send1d(xy_pts_Y);       
       if (eqset == 74) gp4.send1d(xy_pts_C);
       if (eqset == 77) gp4.send1d(xy_pts_F);              

       return 0;    
     }

// EOF

```

Then some end-notes here.

{% include links.html %}

