

**********************************
*  CARACTERÍSTICAS DE LA ENOE    *
*							     *
**********************************
* Julio Cesar Martinez Sanchez
* jcms2665@gmail.com


*  	Contenido  

*0. Cargar y filtrar la base
*1. Esquema de muestreo
	*1.1. Totales	
	*1.2. Promedio
	*1.3. Proporcion
	*1.4. Subpoblaciones (Generacion pseudoestratos)
*3. Pruebas de hipotesis
	*3.1.  Estimadores 215
	*3.1.  Estimadores 214
*4. Modelos de regresion
	*4.1. Muestro Aleatorio Simple
	*4.2. Muestro Estratificado y por Conglomerados
	*4.3. Comparacion entre modelos	
	
	
	
*0. Cargar y filtrar la base

	/* Antes de iniciar con el analisis, se debe de filtrar a los casos validos que
	   son aquellos residentes habituales con entrevista completa y dentro del rango
	   de edad */

	   
	use "C:\Users\JC\Desktop\BUAP\sdemt215.dta", clear	
	
	gen filtro=((c_res==1 | c_res==3) & r_def==0 & (eda>=15 & eda<=98))
	tab filtro [fw=fac], m


*1. Definir el esquema de muestreo

	/* Stata tiene varios metodos para hacer calcular los errores de muestreo, 
	   pero en este caso se va a usar "Linealizacion por Series de Taylor". */

	svyset upm [pw=fac], strata(est_d) vce(linearized)

	*1.1. Totales	
	
		svy, subpop(filtro): tab clase2, format(%11.3g) count se cv ci level(90)

	*1.2. Promedio

		/* Para el caso particular de la ENOE se genera otro filtro con 98
		   Edad no especificada para mayores de 12 anos y mes*/

		gen int f2=((c_res==1 | c_res==3) & r_def==0 & (eda>=15 & eda<=97))
		svy, subpop (f2): mean eda if (clase1==1), level(90)
		estat cv

	*1.3. Proporcion
	
		svy, subpop (filtro):prop clase1, level(90)
		estat cv


	*1.4. Subpoblaciones (Problemas)
	
		/* Cuando se analizan poblaciones muy pequenas pueden presentar problemas.
		   En particular al momento de calcular el coeficiente de variacion
		   aparece la siguiente leyenda:
		   
		   Note: missing standard errors because of stratum with single sampling unit.*/


		gen ti=((c_res==1 | c_res==3) & r_def==0 & (eda>=12 & eda<15) & clase2==1)
		tab ti [fw=fac]
		svy, subpop (ti): tab rama if (sex==2 & eda==14), format(%11.3g) count se cv ci level(90)

		/* La solucion: crear "pseudoestratos". Para ello, Stata tiene varios metodos
		   como: missing, certainty, scaled, o centered  */
		
		svyset, clear
		svyset upm [pw=fac], strata(est_d) vce(linearized) single(sca)
		svy, subpop (ti): tab rama if (sex==2 & eda==14), format(%11.3g) count se cv ci level(90)


*2. Pruebas de hipotesis

	   
	/* http://www.beta.inegi.org.mx/contenidos/proyectos/enchogares/regulares/enoe/doc/enoe_significancia.pdf */

	*2.1.  Estimadores 215
		svyset, clear
		svyset upm [pw=peso], strata(est_d) vce(linearized) single(sca)
		svy, subpop(filtro): tab clase2, format(%11.3g) count se cv ci level(90)

	*2.1.  Estimadores 214
		svyset, clear
		use "C:\Users\JC\Desktop\BUAP\sdemt214.dta", clear
		svyset upm [pw=peso], strata(est_d) vce(linearized) single(sca)
		gen filtro=((c_res==1 | c_res==3) & r_def==0 & (eda>=15 & eda<=98))
		svy, subpop(filtro): tab clase2, format(%11.3g) count se cv ci level(90)
		

