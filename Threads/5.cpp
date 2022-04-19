#include <stdio.h>
#include <pthread.h>

typedef struct Elem{
    int value;
    struct Elem *prox;
}Elem;

typedef struct blockingQueue{
    unsigned sizeBuffer, statusBuffer;
    Elem *head, *last;
}BlockingQueue;

BlockingQueue* newBlockingQueue(unsigned inSizeBuffer){ //Inicializando uma fila de bloqueio
    blockingQueue *queue;
    Elem *sentinela;
    (*sentinela).prox = NULL;

    (*queue).sizeBuffer = inSizeBuffer;
    (*queue).statusBuffer = 0;
    (*queue).head = sentinela;
    (*queue).last = sentinela;

    return queue;
}

void putBlockingQueue(BlockingQueue* Q, int newValue){

    if((*Q).statusBuffer < (*Q).sizeBuffer){ //Se puder adicionar, adiciona
        Elem *temp;
        (*temp).value = newValue;
        (*temp).prox = NULL;

        (*Q).last = temp;
        (*Q).statusBuffer++;
    }

    else{ //Se não puder, trava a thread
        //TRAVAR
    }

    return;
}
int takeBlockingQueue(BlockingQueue* Q){
    int quemSai;
    if((*Q).statusBuffer == 0){ //Trava a thread
        //TRAVAR
    }

    else if((*Q).statusBuffer == 1){ //Tira o único elemento, deixando só o sentinela
        (*Q).statusBuffer--;
        quemSai = (*(*(*Q).head).prox).value;
        (*(*Q).head).prox = NULL;
    }

    else{ //Tira o primeiro elemento da fila, conectando o sentinela ao elemento que vem depois do atual primeiro da fila
        (*Q).statusBuffer--;
        quemSai = (*(*(*Q).head).prox).value;
        (*(*Q).head).prox = (*(*(*Q).head).prox).prox;
    }

    return quemSai;
}
