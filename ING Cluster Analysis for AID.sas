* Partea de modelare;

/*IMPORT DATELE din CSV*/ 

* Tabela BankingProduct;
%web_drop_table(WORK.date); 
 
 
FILENAME REFFILE '/home/u58145036/sasuser.v94/Analiza inteligenta/Proiect/BankingProducts.csv'; 
 
PROC IMPORT DATAFILE=REFFILE 
	DBMS=CSV 
	OUT=WORK.date1; 
	GETNAMES=YES; 
RUN; 
 
PROC CONTENTS DATA=WORK.date1; RUN; 
 
%web_open_table(WORK.date1); 

* Tabela Clients;
%web_drop_table(WORK.date2); 
 
 
FILENAME REFFILE '/home/u58145036/sasuser.v94/Analiza inteligenta/Proiect/Clients.csv'; 
 
PROC IMPORT DATAFILE=REFFILE 
	DBMS=CSV 
	OUT=WORK.date2; 
	GETNAMES=YES; 
RUN; 
 
PROC CONTENTS DATA=WORK.date2; RUN; 
 
%web_open_table(WORK.date2); 

* Tabela Transactions;
%web_drop_table(WORK.date3); 
 
 
FILENAME REFFILE '/home/u58145036/sasuser.v94/Analiza inteligenta/Proiect/Transactions.csv'; 
 
PROC IMPORT DATAFILE=REFFILE 
	DBMS=CSV 
	OUT=WORK.date3; 
	GETNAMES=YES; 
RUN; 
 
PROC CONTENTS DATA=WORK.date3; RUN; 
 
%web_open_table(WORK.date3); 

*INNER JOIN intre tabele;

%web_drop_table(WORK.date);

/* Query code generated for SAS Studio by Common Query Services */

PROC SQL; 
CREATE TABLE WORK.date 
AS 
SELECT DATE1.CLIENT_ID, DATE1.PRODUCT, DATE1.INITIAL_AMOUNT, DATE1.NO_OF_MONTHLY_INSTALLMENTS, DATE1.OPEN_DATE, DATE2.AGE, DATE2.GENDER, DATE2.MONTHLY_INCOME, DATE2.CITY_RESIDENCE, DATE3.TRANSACTION_ID, DATE3.TRANSACTION_DATE, DATE3.MERCHANT_NAME, DATE3.TRANSACTION_AMOUNT, DATE3.TRANSACTION_CURRENCY, DATE3.MERCHANT_CATEGORY_CODE, DATE3.TRANSACTION_TYPE_ID 
FROM WORK.DATE1 DATE1 
INNER JOIN WORK.DATE2 DATE2 
ON 
   ( DATE1.CLIENT_ID = DATE2.CLIENT_ID ) 
INNER JOIN WORK.DATE3 DATE3 
ON 
   ( DATE2.CLIENT_ID = DATE3.CLIENT_ID ) ; 
QUIT;

%web_open_table(WORK.date);

* Transformare tranzactii in RON, cnf curs mediu 2019, bnr.ro;
DATA date;
set work.date;
    if TRANSACTION_CURRENCY = 'EUR' then TRANSACTION_AMOUNT = TRANSACTION_AMOUNT*4.7452;
    if TRANSACTION_CURRENCY = 'USD' then TRANSACTION_AMOUNT = TRANSACTION_AMOUNT*4.2379;
    if TRANSACTION_CURRENCY = 'CHF' then TRANSACTION_AMOUNT = TRANSACTION_AMOUNT*4.2652;
run;


* Creare variabila County;
data work.date;
   set work.date;
      if CITY_RESIDENCE = 'Afumati - Comuna' or 'Bragadiru' or 'Chiajna - Comuna' or 'Pantelimon' or 'Popesti Leordeni' or 'Voluntari' then County = 'Ilfov';
      if CITY_RESIDENCE = 'Arad' then County = 'Arad';
      if CITY_RESIDENCE = 'Bacau' or 'Balcani - Comuna' then County = 'Bacau';
      if CITY_RESIDENCE = 'Balteni - Comuna' then County = 'Gorj';
      if CITY_RESIDENCE = 'Baraolt' then County = 'Covasna';
      if CITY_RESIDENCE = 'Bocsa' or 'Vrani - Comuna' then County = 'Caras Severin';
      if CITY_RESIDENCE = 'Braila' or 'Chiscani - Comuna' then County = 'Braila';
      if CITY_RESIDENCE = 'Brasov' or 'Codlea' or 'Sacele' then County = 'Brasov';
      if CITY_RESIDENCE = 'Bucuresti' then County = 'Bucuresti';
      if CITY_RESIDENCE = 'Buzau' or 'Viperesti - Comuna' then County = 'Buzau';
      if CITY_RESIDENCE = 'Campulung Moldoven' or 'Suceava' then County = 'Suceava';
      if CITY_RESIDENCE = 'Cluj Napoca' or'Floresti - Comuna' then County = 'Cluj';
      if CITY_RESIDENCE = 'Com.Cheveresu Mare' or 'Dumbravita - Comun' or 'Dumbravita - Sat' or 'Faget' or 'Timisoara' then County = 'Timis';
      if CITY_RESIDENCE = 'Com.Craiva' or 'Izvoru - Comuna' or 'Pitesti' or 'Stefanesti' then County = 'Arges';
      if CITY_RESIDENCE = 'Constanta' or 'Harsova' then County = 'Constanta';
      if CITY_RESIDENCE = 'Craiova	' then County = 'Dolj';
      if CITY_RESIDENCE = 'Dragasani' or 'Ramnicu Valcea' then County = 'Valcea';
      if CITY_RESIDENCE = 'Drobeta Turnu Seve' then County = 'Mehedinti';
      if CITY_RESIDENCE = 'Frumoasa - Comuna' or 'Slava Rusa - Sat' or 'Tulcea' then County = 'Tulcea';
      if CITY_RESIDENCE = 'Galati' or 'Sendreni - Sat' or 'Vladesti - Comuna' then County = 'Galati';
      if CITY_RESIDENCE = 'Giurgiu' or 'Joita - Comuna' then County = 'Giurgiu';
      if CITY_RESIDENCE = 'Iasi' or 'Lunca Cetatuii - S' or 'Mosna - Comuna' or 'Sat Coropceni' then County = 'Iasi';
      if CITY_RESIDENCE = 'Medias' or 'Sibiu' then County = 'Sibiu';
      if CITY_RESIDENCE = 'Moreni' or 'Moroeni - Comuna' then County = 'Dambovita';
      if CITY_RESIDENCE = 'Oradea' then County = 'Bihor';
      if CITY_RESIDENCE = 'Ploiesti' then County = 'Prahova';
      if CITY_RESIDENCE = 'Satu Mare' then County = 'Satu Mare';
      if CITY_RESIDENCE = 'Saveni - Sat' then County = 'Botosani';
      if CITY_RESIDENCE = 'Zalau' then County = 'Salaj';
      
run;

/*ANALIZEZ INDICATORII TENDINTEI CENTRALE SI PERCENTILELE PT ELIMINAREA OUTLIERS 
PROCEDURA MANUALA */ 
 
proc means data=work.date mean MEDIAN max min std n NMISS P1 P99 /*noprint*/; 
var  
INITIAL_AMOUNT 
NO_OF_MONTHLY_INSTALLMENTS
AGE
MONTHLY_INCOME
TRANSACTION_AMOUNT
; 
output out = Means (drop = _type_ _freq_) mean = max = min = std = n = NMISS = P1 = P99 = / autoname; 
run; 

*Filtrare date;
proc sql noprint;
create table work.filter as select 

INITIAL_AMOUNT, 
NO_OF_MONTHLY_INSTALLMENTS,
AGE,
MONTHLY_INCOME,
TRANSACTION_AMOUNT,
PRODUCT,
CLIENT_ID

from WORK.DATE; 
quit;
* 1260 observatii;

* CURATARE DATE;
data work.date_curatate ;  
   set work.date ;  
   	if INITIAL_AMOUNT < 7500 or INITIAL_AMOUNT > 1000000 then delete;  
    if AGE < 18 or AGE > 65 then delete; 
 	if MONTHLY_INCOME < 1000 or MONTHLY_INCOME >= 11500 then delete;  
    if TRANSACTION_AMOUNT < 2 or TRANSACTION_AMOUNT > 3000 then delete; 

run; 
* n = 1179 observatii;

* ANALIZA SI MODELAREA DATELOR;
* Standardizare date;
* medie 0 si dispersie 1;

proc stdize data = work.date_curatate  
method = range  
out = date_std  
outstat = stat_date; 
var  
INITIAL_AMOUNT 
NO_OF_MONTHLY_INSTALLMENTS
AGE
MONTHLY_INCOME
TRANSACTION_AMOUNT;
run; 

* ACL;
proc varclus data = work.date_std maxeigen = 0.7 short; 
var 
INITIAL_AMOUNT 
NO_OF_MONTHLY_INSTALLMENTS
AGE
MONTHLY_INCOME
TRANSACTION_AMOUNT;
run; 

/*SEGMENTAREA DATELOR*/ 

/*Determinarea grupelor initiale*/ 
 
proc fastclus data = work.date_std  
maxclusters	= 50  
	maxiter = 0  /*numar maxim de iteratii*/ 
	OUTSEED = work.centers; /*centrele claselor*/ 
var  
NO_OF_MONTHLY_INSTALLMENTS
MONTHLY_INCOME
AGE
TRANSACTION_AMOUNT
;
run; 

/*Aplicarea metodei centrelor mobile pentru crearea a 50 de clusteri foarte omogeni */ 
 
proc fastclus data = work.date_std   
	maxclusters = 50 
	maxiter = 50  
	seed = work.centers  
	out = work.clusters  
	cluster = preclus 
	OUTSTAT = work.stat_centers  
	Outseed = work.centers_final; 
*outseed-> centrele de gr finale;
var  
NO_OF_MONTHLY_INSTALLMENTS
MONTHLY_INCOME
AGE
TRANSACTION_AMOUNT
; 
run; 

*Rol descriptiv: proc sort si proc freq aici;
proc sort data = work.clusters; 
by preclus; 
run; 
 
proc freq data = work.clusters  noprint; 
tables preclus/out = fr_preclus; 
run; 

/*Aplicarea metodei Ward pentru obtinerea unui arbore de clasificare */ 
 
ods graphics on;  
proc cluster data = work.centers_final   
method = ward ccc pseudo  
outtree = work.tree; 
var  
NO_OF_MONTHLY_INSTALLMENTS
MONTHLY_INCOME
AGE
TRANSACTION_AMOUNT
; 
copy preclus;  
run;  
ods graphics off;  

/*Se selectează 8 segmente */ 
* se salveaza arborele in fiecare nivel in work.tree;

proc tree data = work.tree noprint ncl = 8 out = work.rezultate ; 
copy  
preclus
NO_OF_MONTHLY_INSTALLMENTS
MONTHLY_INCOME
AGE
TRANSACTION_AMOUNT
; 
run; 
 
proc sort data = work.rezultate; 
by preclus; 
run; 
 
/*Creez o tabela in care adaug informatia referitoare la segment peste informatiile referitoare la cei 50 de clusteri initial formati*/ 
 
data work.clusteri;  
merge work.rezultate work.clusters;  
by preclus;   
run; 
* n = 1179 observatii;
 
proc freq data = work.clusteri; 
tables preclus*cluster / 
out = cross_preclus_cluster ; 
run; 

/*Adaug in tabela initiala doua variabile referitoare la clusterul si segmentul de apartenenta */ 
proc sort data = work.date_curatate; 
by CLIENT_ID; 
run; 

proc sort data = work.clusteri; 
by CLIENT_ID; 
run; 

*combine tables -> tasks & utilities -> tasks -> data -> combine tables -> one-to-one-merge -> use proc sql;
proc sql noprint;
	create table work.segmente as select a.*, b.* from
(select *, monotonic() as __n__ from WORK.DATE_CURATATE) as a full join
(select *, monotonic() as __n__ from WORK.CLUSTERI) as b on a.__n__=b.__n__;
	alter table work.segmente drop __n__;
quit;
* n = 1179;

proc sql; 
create table work.date_segmentat as 
select a.*, 
b.cluster as SEGMENT label ' ' 
from work.segmente  a  left join work.rezultate b on a.preclus = b.preclus; 
quit; 
* n = 1179;

/*Calcul medii segmente*/ 

proc means data = work.date_segmentat mean MEDIAN max min range std; 
class SEGMENT; 
var  
NO_OF_MONTHLY_INSTALLMENTS
MONTHLY_INCOME
AGE
TRANSACTION_AMOUNT
; 
output out = var_cant; 
run; 


* ARBORE DE DECIZIE CHAID;
* Crearea unei variabile binare;
* Varianta Credit Card -> AUC = 0.93, dar la ":" pe ramuri e dubios, 
    avand in vedere ca nu sunt multi clienti din BD ce-l prefera (~ 200/1000);
* Mergem pe var Personal Loan sau Mortgage Avantaj Plus ca e mai sigur dpv al preferintelor clientilor, 
  si asa are sens ":" pe ramuri a arborelui de decizie & clasificare;    

data work.date;
   set work.date_curatate;
      if PRODUCT = 'Mortgage Avantaj Plus' then PRODUCT = 'Yes';
   	else PRODUCT = 'No';
run;

* ARBORE DE DECIZIE CHAID;
ods graphics on; 
 
proc hpsplit data = work.date plots = zoomedtree /*(node = 4)*/ seed = 123 cvmodelfit intervalbins = 500; 
   class PRODUCT; 
   model PRODUCT (event ='Yes') =   	
INITIAL_AMOUNT
NO_OF_MONTHLY_INSTALLMENTS
AGE
MONTHLY_INCOME
/*TRANSACTION_AMOUNT*/
		; 
   grow chaid; 
   prune costcomplexity (leaves = 10); 
run; 
 
ods graphics off; 



