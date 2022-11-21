*====================================================================
*Trabajo Microeconometria II
*Autor: Roger Gomez
*Tema: Probit ordenado con data ENADI 2018-MINEDU
*===================================================================
clear all
set more off

cd "C:\Users\user\Desktop\mia_ii"
dir
use BaseENDI_2018.dta

*Creación de variables de interés
*VD: Estado de bienestar respecto a sus ingresos

tab  P313
label list  P313

gen cvlab=.
 replace cvlab=1 if P313==4
 replace cvlab=2 if P313==3
 replace cvlab=3 if P313==2
  replace cvlab=4 if P313==1
  label define cvlab 1 "Muy mala" 2 "Mala" 3 "Buena" 4 "Muy buena"
  label values cvlab cvlab

tab cvlab P313 

*sexo
tab P301C_01
label list P301C_01

gen sex=.
 replace sex=1 if P301C_01==2
 replace sex=0 if P301C_01==1
  label define sex 1 "Mujer" 0 "Varón" 
  label values sex sex

tab sex  P301C_01

*VI: Gasto mensual del hogar (monto declarado)
rename P314 gastohog
sum gastohog
hist gastohog

gen lgastohog=ln(gastohog)
hist lgastohog

*VI: N° integrantes que viven permanentemente
sum P3010
rename P3010 miehog

*VI: Edad del directivo
sum P301D_01
gen edad=P301D_01 
gen edad2=edad^2 

* VI: Condicion laboral
tab P201B
label list P201B
gen condlab=.
 replace condlab=1 if P201B==1  | P201B==2
 replace condlab=2 if P201B==3  | P201B==4
 replace condlab=3 if P201B==6  | P201B==7 | P201B==8
 replace condlab=4 if P201B==9
 label define condlab 1 "Designado" 2 "Encargado" 3 "Contratado" 4 "Sin contrato"
 label values condlab condlab
  
 tab condlab P201B
 
*descriptivos
sum cvlab sex condlab gastohog miehog edad

*preparar variable dependiente e independiente

global ylist cvlab
global xlist sex condlab lgastohog miehog edad edad2

describe $ylist $xlist
summarize $ylist $xlist

tabulate $ylist
 
* Estimando los humbrales "theta"
 oprobit $ylist
 
display (1- .9946)*100
display ((1- .8133)*100)-((1- .9946)*100)
display ((1-.9732)*100)-((1- .9946)*100)
graph pie, over (cvlab)  plabel(_all percent, size(*1) color(white)) title(Nivel de satisfacción laboral del director) note("Fuente: ENDI 2018") missing name (g1)

*probit ordinal
 oprobit $ylist $xlist
 eststo oprobit
 esttab 
 
* probit ordenado excluyendo las variables no significativas
global xlist1 i.condlab c.lgastohog c.miehog

oprobit $ylist $xlist1
eststo poprobit
esttab 

*efecto marginal para cada categoria de la v. dependiente
	
		quietly oprobit $ylist $xlist1 
		margins, dydx(*) predict(outcome(1)) post
		eststo cat1
		quietly oprobit $ylist $xlist1 
		margins, dydx(*) predict(outcome(2)) post
		eststo cat2
		quietly oprobit $ylist $xlist1
		margins, dydx(*) predict(outcome(3)) post
		eststo cat3
		quietly oprobit $ylist $xlist1 
		margins, dydx(*) predict(outcome(4)) post
		eststo cat4

 esttab 
 
 
 * Prediccion
predict p1oprobit, pr outcome(1)
predict p2oprobit, pr outcome(2)
predict p3oprobit, pr outcome(3)
predict p4oprobit, pr outcome(4)
summarize p1oprobit p2oprobit p3oprobit p4oprobit
tabulate $ylist
 
 
 
 
 
 
 
 