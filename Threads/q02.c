#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define size 10

typedef struct{
    int l;
    int r;
    int* array;
} contexto_threads;

void swap(int* a, int* b){
    int temp = *a;
    *a = *b;
    *b = temp;
}

//considerando o elemento do meio p ser o pivot
int partition(int A[], int l, int r){
    int q = l - (l - r)/2;
    swap(&A[l], &A[q]);
    int i = l;
    int j = r;

    while(i < j){
        while(i <= r && A[i] <= A[l]) i++;
        while(A[j] > A[l]) j--;
        if(i < j) swap(&A[i], &A[j]);
    }

    swap(&A[l], &A[j]);

    return j;
}


void* t_quicksort(void *data){
    //recebendo os parametros (nao posso passar direto na funcao!)
    contexto_threads *contexto1 = (contexto_threads*) malloc(sizeof(contexto_threads));
    contexto1 = (contexto_threads*) data;
    
    pthread_t thread_id1;
    
    int l = contexto1->l, r = contexto1->r;

    //como n passo contexto2 como argumento ele n precisa ser ponteiro!
    contexto_threads contexto2; //nao posso setar como data pq as threads n podem ter o msm contexto

    if(l < r){
        int p = partition(contexto1->array, l, r);
    
        //parte da direita:
        contexto2.l = p + 1;
        contexto2.r = r;
        contexto2.array = contexto1->array;

        //a cada chamada de quick sort uma thread esta sendo criada!
        if(pthread_create(&thread_id1, NULL, t_quicksort, &contexto2)){
            printf("ERRO");
            return NULL;
        }

        //ajeitando o contexto p prox chamada do quick sort:
        contexto1->l = l;
        contexto1->r = p - 1;
        //nao preciso atualizar o array pq sempre uso o msm e ja atualizei quando setei como data
        
        t_quicksort(contexto1);

        //agora tenho q esperar a primeira thread terminar!
        pthread_join(thread_id1, NULL);

    } 

    return NULL;
    
}


int main(){

    int vet[size];
    //setando o array p facilitar!
    for(int i=0; i<size; i++)
        vet[i] = i;


    //setando o contexto da thread:
    contexto_threads *contexto_init = (contexto_threads*) malloc(sizeof(contexto_threads));
    contexto_init->array = (int*) malloc(sizeof(int)*size);
    contexto_init->array = vet;
    contexto_init->l = 0;
    contexto_init->r = size - 1;


    //chamando a primeira vez
    t_quicksort(contexto_init);


    //printando o array ORDENADO:
    printf("array ordenado:\n");
    for(int i=0; i<size; i++)
        printf("%d ", vet[i]);
    printf("\n");

    pthread_exit(NULL);

    return 0;
}
