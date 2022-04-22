#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define threads_C 2
#define threads_P 2
#define BUFFER_SIZE 10


pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t empty = PTHREAD_COND_INITIALIZER;
pthread_cond_t full = PTHREAD_COND_INITIALIZER;


typedef struct elem {
    int value;
    struct elem *prox;
} Elem;

typedef struct blockingQueue {
    unsigned sizeBuffer, statusBuffer;
    Elem *head, *last;
} BlockingQueue;


//cria uma fila de tamanho definido
BlockingQueue* newBlockingQueue(unsigned inSizeBuffer){
    BlockingQueue *Queue = (BlockingQueue*) malloc(sizeof(BlockingQueue)*inSizeBuffer);

    //setando a fila vazia
    Queue->head = NULL; 
    Queue->last = NULL; 
    Queue->sizeBuffer = inSizeBuffer;
    Queue->statusBuffer = 0; 

    return Queue;
}

void putBlockingQueue(BlockingQueue* Q, int newValue){
    pthread_mutex_lock(&mutex);

    //se a fila estiver cheia, coloco os produtores p dormir e libero o mutex
    while(Q->statusBuffer == Q->sizeBuffer){
        printf("A fila esta cheia!\n");
        pthread_cond_wait(&empty, &mutex); 
    }

    //criando o novo no
    Elem* novo = (Elem*) malloc(sizeof(Elem));
    novo->value = newValue;
    novo->prox = NULL;

    if(Q->head == NULL){
        //se nao tenho nenhum elemento adiciono no head e no last
        Q->head = novo;
        Q->last = novo; 
        Q->statusBuffer++; 
        printf("produzi %d\n", newValue);
    }

    else{
        Q->last = novo; //se ja tiver alguem so preciso adicionar no final
        Q->statusBuffer++;
        printf("produzi %d\n", newValue);
    }  

    //se tenho espaço na fila, posso liberar os consumidores
    if(Q->statusBuffer == 1)
        pthread_cond_broadcast(&full);

    pthread_mutex_unlock(&mutex);

}

int takeBlockingQueue(BlockingQueue* Q){
    int item_retirado;
    //bloqueando o mutex
    pthread_mutex_lock(&mutex);

    //se a fila estiver vazia, coloco os consumidores p dormir e libero o mutex
    while(Q->statusBuffer == 0 && Q->head==NULL){
        printf("A fila esta vazia!\n");
        pthread_cond_wait(&full, &mutex); //bloqueando os consumidores e liberando o mutex
    }

    //consumindo o item
    if(Q->statusBuffer == 1 && Q->head->prox == NULL){
        //se so tenho um item, a fila ficara vazia
        item_retirado = Q->head->value;
        Q->head = NULL;
        Q->last = NULL;
        Q->statusBuffer --;
        printf("consumi %d\n", item_retirado);
    }
    else if(Q->head != NULL){
        //tenho mais de um item
        item_retirado = Q->head->value;
        Q->head = Q->head->prox;
        Q->statusBuffer --;
        printf("consumi %d\n", item_retirado);
    }

    //se tenho espaço na fila, posso liberar 1 produtor
    if(Q->statusBuffer == Q->sizeBuffer - 1) 
        pthread_cond_signal(&empty);

    pthread_mutex_unlock(&mutex);

    return item_retirado;
}

void *producer(void *queue){
    BlockingQueue* Q = (BlockingQueue*) queue;
    
    int valor = 0;
    while(1){  
        //as threads devem rodar em loops infinitos 
        putBlockingQueue(Q, valor);
        valor++;
    }

    pthread_exit(NULL);
    
}

void *consumer(void *queue){
    BlockingQueue* Q = (BlockingQueue*) queue; 
    
    int v;
    while(1){
        //as threads devem rodar em loop infinito
        v = takeBlockingQueue(Q);

    }
    pthread_exit(NULL);
}


int main(){
    pthread_t producer_threads[threads_P];
    pthread_t consumer_threads[threads_C];

    BlockingQueue* Queue = (BlockingQueue*) malloc(sizeof(BlockingQueue));
    Queue = newBlockingQueue(BUFFER_SIZE);
    

    for(int i=0; i < threads_C; i++)  
        pthread_create(&consumer_threads[i], NULL, consumer, (void *) Queue);    

    for(int i=0; i < threads_C; i++)
        pthread_create(&producer_threads[i], NULL, producer, (void*) Queue);
    

    pthread_exit(NULL);

    return 0;

}

