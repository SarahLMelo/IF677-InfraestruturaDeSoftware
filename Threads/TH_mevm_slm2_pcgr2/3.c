#include <stdio.h>
//Stack Overflow mandou colocar para reconhecer a barreira
#define _XOPEN_SOURCE 600
#define _POSIX_C_SOURCE 200112L
#include <pthread.h>

typedef struct{
    int numberOfI;
    int i[100];
    pthread_barrier_t *barrier;

} threadArgs;

#define size 2 //Tamanho da matriz

double A[size][size]; //Matriz A
double b[size]; //Matriz B
double x[size]; //Matriz X

void init(){
    //Inicializando A
    A[0][0] = 2;
    A[0][1] = 1;
    A[1][0] = 5;
    A[1][1] = 7;

    //Inicializando b
    b[0] = 11;
    b[1] = 13;
    
    //Inicializando x
    for(int i=0; i<size; i++) x[i] = 1;

    return;
}

void *solve(void *arg){ //Função que vai fazer as contas no método Jacobi, basicamente o que cada thread roda
    threadArgs *myArgs = (threadArgs *) arg;

    double xUpdate[(*myArgs).numberOfI]; //Onde estou guardando os x prontos para substituir qnd a barreira for solta

    for(int i=0; i<(*myArgs).numberOfI; i++){ //Jacobi
        int k = (*myArgs).i[i];
        double sum = 0;
        for(int j=0; j<size; j++){
            if(k==j) continue;
            sum += A[k][j]*x[j];
        }

        if(A[k][k]) xUpdate[i] = (1/A[k][k]) * (b[k] - sum);
        else xUpdate[i] = 0;
    }
    pthread_barrier_wait((*myArgs).barrier); //Colocando a thread na barreira
    for(int i=0; i<(*myArgs).numberOfI; i++) x[(*myArgs).i[i]] = xUpdate[i]; //Fazendo o update do x

}

void *vazio(void *arg){ //Função das threads desnecessárias, ela só existe para completar a barreira já que tive que criar a thread anyways
    threadArgs *myArgs = (threadArgs *) arg;
    pthread_barrier_wait((*myArgs).barrier);
}

int main(){
    init();
    int n, P; // Declarando meu N
    printf("Please insert the number of cores in your processor: ");
    scanf("%d", &n); // Lendo meu N
    printf("\nPlease insert the number of times you want the Jacobi method to be realized, more iteractions means more precision: ");
    scanf("%d", &P); // Lendo meu P
    printf("\n");

    pthread_t threads[n]; //Criando minhas N threads
    pthread_barrier_t barrier; //Criando minha barreira

    pthread_barrier_init(&barrier, NULL, n); //Inicializando a barreira

    int k = 0; //Inicializando meu contador k e a minha condição de parada
    while (k < P){ //Enquanto k for maior q P faça
        threadArgs args[n];
        for(int i=0; i<n; i++){
            args[i].numberOfI = 0;
            args[i].barrier = &barrier;

            int j = i;
            while(j<size){ //Colocando todos os i que vão ser calculados nessa thread
                args[i].i[args[i].numberOfI] = j;
                args[i].numberOfI++;

                //printf("PASSOU POR AQUI1: %d\n", j);
                //fflush(stdin);

                j += n;
            }

            if(args[i].numberOfI > 0){
                pthread_create(&threads[i], NULL, solve, &args[i]);
            }
            else{
                //printf("Chegou aqui\n");
                //fflush(stdin);
                pthread_create(&threads[i], NULL, vazio, &args[i]);
            }
            //printf("PASSOU POR AQUI2: %d %d\n", i, args[i].numberOfI);
            //fflush(stdin);
        }

        for(int i=0; i<n; i++) pthread_join(threads[i], NULL); //Esperando todo mundo acabar para começar a próxima iteração
        k++;
    }

    for(int i=0; i<size; i++) printf("%lf ", x[i]); //Printando o array x no final
    printf("\n");

    pthread_barrier_destroy(&barrier); //Destruindo a barreira que construimos pois não vamos mais precisar dela

    return 0;
}