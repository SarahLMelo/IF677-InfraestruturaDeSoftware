/*O código compila no gcc, no clang o switch-case está bugado, talvez seja meu sistema operacional (estou usando o manjaro)
Eu comentei em diferentes momentos, aí metade dos comentários tão em português e a outra metade em ingles, espero que não tenha problema
*/

#include <stdio.h>
#include <pthread.h>

int executions; //Numero de execuções
int cnt; //Um contador para saber que iterações estamos mandando
int debug[1000]; //Um array usado para debugar o código
pthread_mutex_t lock; //Meu mutex para a função de requisitar iterações do guided e do dynamic

#define OMP_NUM_THREADS 4

int teto(int numerador, int divisor){ //Uma função teto pois a ceil do math.h não estava compilando
    int chao = numerador/divisor;
    double exato = ((double)numerador)/divisor;

    if(exato-chao > 0)
        return chao+1;
    
    else
        return chao;
    
}

int f(int x){ //A função f que será executada dentro do loop, como eu fiz ela global, decidi não colocar como argumento da função
    debug[x] = 1;
    return x + 1;
}

typedef struct{ //Struct dos argumentos da minha thread
    int numberOfI;
    int i[1000];
    int closeThread; //For dynamic and guided use only

} threadArgs;

typedef struct{ //Struct utilizada no dynamic args para passar o chunck_size e o passo, se fosse em c++ com a biblioteca padrão, utilizaria um pair
    int chunk_size, passo;

} dynamicArgs;

void *ompStatic(void *arg){ //Função omp se a schedule escolhida for a estática
    threadArgs *myArgs = (threadArgs *) arg;

    for(int j=0; j<(*myArgs).numberOfI; j++){
        f((*myArgs).i[j]);
    }
}

threadArgs requestD(int chunk_size, int passo){ //Request used in the dinamic schedule
    pthread_mutex_lock(&lock);
    threadArgs argumentos;
    argumentos.numberOfI = 0;

    if(!executions) argumentos.closeThread = 1;
    else argumentos.closeThread = 0;

    for(int i=0; i<chunk_size && executions > 0; i++){
        argumentos.i[argumentos.numberOfI] = cnt;
        cnt += passo;
        argumentos.numberOfI++;
        executions--;
    }

    pthread_mutex_unlock(&lock);

    return argumentos;
}

threadArgs requestG(int chunk_size, int passo){ //Request used in the guided schedule
    pthread_mutex_lock(&lock);
    threadArgs args;
    args.numberOfI = 0;

    int sent = teto(executions, OMP_NUM_THREADS);

    if(!executions) args.closeThread = 1;
    else args.closeThread = 0;

    for(int i=0; i<sent && executions; i++){
        args.i[args.numberOfI] = cnt;
        cnt += passo;
        args.numberOfI++;
        executions--;
    }

    pthread_mutex_unlock(&lock);

    return args;
}

void *ompDynamic(void *arg){ //Função omp se a schedule escolhida for a dinâmica
    dynamicArgs *myArgs = (dynamicArgs *) arg;

    threadArgs args = requestD((*myArgs).chunk_size, (*myArgs).passo);

    while(!args.closeThread){
        for(int j=0; j<args.numberOfI; j++){
            f(args.i[j]);
    }

        args = requestD((*myArgs).chunk_size, (*myArgs).passo);
    }
}

void *ompGuided(void *arg){ //Função omp se a schedule escolhida for a guiada
    dynamicArgs *myArgs = (dynamicArgs *) arg;
    threadArgs args = requestG((*myArgs).chunk_size, (*myArgs).passo);

    while(!args.closeThread){
        for(int j=0; j<args.numberOfI; j++){
            f(args.i[j]);
        }

        args = requestG((*myArgs).chunk_size, (*myArgs).passo);
    }
}

void omp_for( int inicio , int passo , int final , int schedule , int chunk_size){ //Minha função omp
    executions = (final-inicio) / passo;
    cnt = inicio;
    pthread_t threads[OMP_NUM_THREADS]; //Crio minhas threads

    switch (schedule){
    case 1: //static
        threadArgs sArgs[OMP_NUM_THREADS]; //Crio meus argumentos para o static

        for(int i=0; i<OMP_NUM_THREADS; i++) sArgs[i].numberOfI = 0;

        while(executions/OMP_NUM_THREADS > chunk_size){ //Dividindo as iterações por chunk size
            for(int i=0; i<OMP_NUM_THREADS; i++){
                for(int j=0; j<chunk_size; j++){
                    sArgs[i].i[sArgs[i].numberOfI] = cnt;
                    cnt += passo;
                    sArgs[i].numberOfI++;
                }
            }

            executions -= OMP_NUM_THREADS*chunk_size;
        }

        while(executions){ //Terminando as execuções que são menores que o chunk size
            for(int i=0; i<OMP_NUM_THREADS; i++){
                for(int j=0; j<executions/4; j++){
                    sArgs[i].i[sArgs[i].numberOfI] = cnt;
                    cnt += passo;
                    sArgs[i].numberOfI++;
                }
            }

            executions /=4;
            
            if(executions < 4){
                for(int i=0; i<executions; i++){
                    sArgs[i].i[sArgs[i].numberOfI] = cnt;
                    cnt += passo;
                    sArgs[i].numberOfI++;
                }
            }
        }

        for(int i=0; i<OMP_NUM_THREADS; i++)
            pthread_create(&threads[i], NULL, ompStatic, &sArgs[i]); //Crio todas as threads

        for(int i=0; i<OMP_NUM_THREADS; i++) //Espero geral acabar
            pthread_join(threads[i], NULL); 

        break;

    case 2: //Dynamic
        dynamicArgs dArgs[OMP_NUM_THREADS]; //Crio meus argumentos para o dinâmico
        pthread_mutex_init(&lock, NULL);
        
        for(int i=0; i<OMP_NUM_THREADS; i++){

            dArgs[i].chunk_size = chunk_size;
            dArgs[i].passo = passo;

            pthread_create(&threads[i], NULL, ompDynamic, &dArgs[i]); //Crio todas as threads
        }

        for(int i=0; i<OMP_NUM_THREADS; i++) //Espero geral acabar
            pthread_join(threads[i], NULL); 
        
        pthread_mutex_destroy(&lock);
        break;
    case 3:
        dynamicArgs gArgs[OMP_NUM_THREADS]; //Crio meus argumentos para o dinâmico
        pthread_mutex_init(&lock, NULL);
        
        for(int i=0; i<OMP_NUM_THREADS; i++){
            gArgs[i].chunk_size = chunk_size;
            gArgs[i].passo = passo;

            pthread_create(&threads[i], NULL, ompGuided, &gArgs[i]); //Crio todas as threads
        }

        for(int i=0; i<OMP_NUM_THREADS; i++) //Espero geral acabar
            pthread_join(threads[i], NULL); 
        
        pthread_mutex_destroy(&lock);
        break;
    }
    
}

int main(){
    printf("Digite 1 para estático, 2 para dinâmico e 3 para guiado: ");
    int mode, inicio, fim, passo, chunkSize;
    scanf("%d", &mode);
    printf("Digite o inicio e o fim do for: ");
    scanf("%d%d", &inicio, &fim);
    printf("Digite o passo do for e o tamanho do chunk para cada thread: ");
    scanf("%d%d", &passo, &chunkSize);

    omp_for(inicio, passo, fim, mode, chunkSize);

    //for(int i=inicio; i<fim; i += passo) printf("%d ", debug[i]);
    //printf("\n");


    return 0;
}