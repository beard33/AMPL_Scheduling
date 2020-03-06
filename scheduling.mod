
# Definizione dei parametri
param r >= 0;                                                    # numero processori
param T >= 0;                                                    # numero di processi
param t_max >= 0;                                                # tempo max per insieme tempo

# Definizione degli insiemi
set PROCESSI := 1..T;
set PROCESSORI := 1..r;
set TEMPO := 0..t_max;

# Parametri ulteriori
param D{PROCESSI} >= 0;                                          # consegna prevista
param p{PROCESSI, PROCESSORI} >= 0;                              # tempo esec. 

# Variabili
var utilizzo{PROCESSI, PROCESSORI, TEMPO} binary;                
var t_fine{PROCESSI} >= 0; 
var ritardo{i in PROCESSI} = t_fine[i] - D[i];  
var max_ritardo integer >= 0;


# Vincoli

# Vincolo per la definizione di t_fine[i]
# OK
subject to vincolo_completamento {i in PROCESSI}:
	 sum{t in TEMPO} (t + p[i,r])*utilizzo[i,r,t] <= t_fine[i] ;

subject to vincolo_fine {i in PROCESSI} :
	t_fine[i] <= t_max;

# Vincolo per garantire esecuzione unica dell'operazione nel tempo t_max
# OK
subject to vincolo_continuita {i in PROCESSI, j in PROCESSORI} : 
    sum{t in TEMPO} utilizzo[i,j,t]=1;

# Vincolo per avere al massimo un'operazione per ciascun processo in esecuzione per ogni istante t
# OK
subject to vincolo_operazione {i in PROCESSI, t in TEMPO}:
    sum{j in PROCESSORI} utilizzo[i,j,t]<=1;

# Vincolo per garantire l'ordine esecutivo tra operazioni dello stesso processo (che non venga eseguita operazione 2 prima di 
# operazione 1 conclusa)
# OK 
subject to vincolo_ordine {i in PROCESSI, j in PROCESSORI, t in TEMPO}:
    sum{k in 0..t} utilizzo[i,max(j-1, 1),k] >= utilizzo[i,j,t];

# vincolo per massimizzare il ritardo utilizzando una variabile ausiliaria max_ritardo
# OK

subject to massimo_ritardo {i in PROCESSI}:
    max_ritardo >=  ritardo[i];
        
# vincolo per evitare che due processi eseguano operazioni in contemporanea sullo stesso processore
subject to non_sovrapp1 {t in TEMPO, j in PROCESSORI}:
	sum{i in PROCESSI, k in max(t-p[i,j]+1,0)..(t)} utilizzo[i,j,k]<=1;

# vincolo per evitare che l'operazione di un processo venga eseguita prima che sia terminata la precedente 
subject to non_sovrapp2 {i in PROCESSI, t in TEMPO} :
	sum{ j in PROCESSORI, k in max(t-p[i,j]+1,0)..(t)} utilizzo[i,j,k] <= 1;
	
minimize min_ritardo : max_ritardo;
#minimize fine : sum {i in PROCESSI} t_fine[i];  	






