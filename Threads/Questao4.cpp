#include <iostream>
#include <pthread.h>
#include <stack>
#include <list>
#include <algorithm>

#define N 2 //Num. Threads
using namespace std;

int BufferVisitados;
int *buffer_teste = nullptr;
 
class Grafo{
public:
	int V; // número de vértices
	list<int> *adj; // lista de adj
 
	Grafo(int V){
        this->V = V; // atribui o número de vértices
	    adj = new list<int>[V]; // aloca listas p qtde de vértices
    } // constructor

	void criar_aresta(int v1, int v2){
        adj[v1].push_back(v2); //v2 é adjacente de v1
    }
    void* dfs(int v); 
};//fim da class

void* Grafo::dfs(int v)
{
	stack<int> pilha;
	bool visitados[V]; // vetor de visitados
 
	// marca todos como não visitados
	for(int i = 0; i < V; i++)
		visitados[i] = false;
 
	while(true)
	{
		if(!visitados[v])
		{
			cout << "Visitando vertice " << v << " ...\n";
			visitados[v] = true; // marca como visitado
			pilha.push(v); // insere "v" na pilha
		}
 
		bool achou = false;
		list<int>::iterator it;
 
		// busca por um vizinho não visitado
		for(it = adj[v].begin(); it != adj[v].end(); it++)
		{
			if(!visitados[*it])
			{
				achou = true;
				break;
			}
		}
 
		if(achou)
			v = *it; // atualiza o "v"
		else
		{
			// se todos os vizinhos estão visitados ou não existem vizinhos
			// remove da pilha
			pilha.pop();
			// se a pilha ficar vazia, então terminou a busca
			if(pilha.empty())
				break;
			// se chegou aqui, é porque pode pegar elemento do topo
			v = pilha.top();
		}
	}
}
void* dfs_intermediaria(Grafo* grafo){

}

int main()
{
	int V = 8; //qtde de vertices
    pthread_t threads[N];
    pthread_mutex_t mutex;
	Grafo grafo(V);

    int connections = grafo.adj[0].size(); //pega quantas conexoes o vertice 0 possui

    if(N == connections){//se threads == num de conexoes, mandamos cada thread para 1 vertice
        for(int i = 0; i < V; i++){
            pthread_create(&threads[i], NULL, &dfs_intermediaria, &grafo);
        }
    }
 
	// adicionando as arestas
	grafo.criar_aresta(0, 1);
	grafo.criar_aresta(0, 2);
	grafo.criar_aresta(1, 3);
	grafo.criar_aresta(1, 4);
	grafo.criar_aresta(2, 5);
	grafo.criar_aresta(2, 6);
	grafo.criar_aresta(6, 7);

    for(int i = 0; i < N; i++){
        if(pthread_join(threads[i], NULL) !=0){
            std::cout << "Join falhou na thread: " << i << std::endl;
        }
    }
	
	grafo.dfs(0);//teste
 
	return 0;
}