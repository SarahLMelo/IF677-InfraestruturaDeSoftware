#include <iostream>
#include <fstream>
#include <pthread.h>
#define N  3 //num arquivos(ate qual arquivo ler)
#define T  3 //num de threads
#define P  3 //num de produtos

int *produtos = new int[P+1];
pthread_mutex_t mutex[P+1];

void* read_file(void *arg){
    int* aux = (int*) arg;
    std::ifstream file{std::to_string(*aux) + ".txt"};
    free(arg);

    int index;
    while(file >> index){
        pthread_mutex_lock(&mutex[index]);
        //std::cout << index << std::endl;
        produtos[index]++;
        pthread_mutex_unlock(&mutex[index]);
    }
}

int main(){

    pthread_t threads[T+1];

    if(T == N){          //se o num de threads == arqs
        for(int i = 1; i <= N; i++){
            int *arg = new int;        //precisa ser alocado pra evitar que o valor de "i" seja incrementando antes da thread
            *arg = i;                                  //arg -> numero do arquivo a ser lido
            mutex[i] = PTHREAD_MUTEX_INITIALIZER;
            pthread_create(&threads[i], NULL, &read_file, arg); //cada thread lerá o um arquivo 
        }
    }else{ //vamos precisar de mais de um loop para ler todos arqs com as poucas threads disponiveis
        int resto = N % T; //se for 0, por exemplo: temos 3 threads para 9 arquivos
            int loop = N / T;
            int *arg = new int;
            *arg = 1;

            for(int i = 0; i < loop; i++){
                for(int j = 1; j <= T; j++){
                    *arg = (*arg) + 1;//arquivo a ser lido
                    pthread_create(&threads[j], NULL, &read_file, arg);
                }
            }
            if(resto != 0){//se for diferente de zero precisamos mexer no resto dos arquivos que nao foram lidos
                           //por exemplo: temos 3 threads e 11 arquivos, ao finao dos loops anteriores sobraria 2 arquivos
                for(int i = 1; i <= resto; i++){
                    *arg = (*arg) + 1;//arquivo a ser lido
                    pthread_create(&threads[i], NULL, &read_file, arg);
                }           

            }
            
        
    }
    
    for(int i = 1; i <= P; i++){
        if(pthread_join(threads[i], NULL) !=0){
            std::cout << "Join falhou na thread: " << i << std::endl;
        }
    }
    std::cout<<"-----------------------------------------------" << std::endl;
    for(int i = 1; i <= P; i++){
        std::cout << produtos[i] << std::endl;
    }
    return 0;
}
