#include <iostream>
#include <string>
#include <list>
#include "cache.h"

using namespace std;

void testCache(int setAmount, int setSize, int blockSize, int prefetchLength, int prefetchSetting, list<int>& addressList)
{
    // Crear la memoria (de caracteres ascii)
    const int addressSize = 32;
    char memory[1024];
    for(int i = 0; i < 1024; i++)
    {
        memory[i] = static_cast<char>(i);
    }
    // Crear un cache
    Cache<char> myCache(setAmount, setSize, blockSize, memory, 1024);
    myCache.setPrefetchSetting(prefetchSetting);
    myCache.setPrefetchLength(prefetchLength);
    auto it = addressList.begin();
    while(it != addressList.end())
    {
        myCache.readAddress(*it);
        it++;
    }
    
    int hits = myCache.getHits();
    int misses = myCache.getMisses();
    int ratio = hits/misses;
    cout << "Aciertos: " << hits << endl;
    cout << "Fallos: " << misses << endl;
}


int main()
{
    // Entrada Inicial
    int setAmount, setSize, blockSize, prefetchLength;
    cin >> setAmount;
    cin >> setSize;
    cin >> blockSize;
    cin >> prefetchLength;
    // Lista de direcciones
    list<int> addressList;
    int input;
    while(cin >> input)
    {
        addressList.push_back(input);
    }
    cout << "Prueba de Cache sin prefetching" << endl;
    testCache(setAmount, setSize, blockSize, prefetchLength, 0, addressList);
    cout << "Prueba de Cache con prefetching secuencial" << endl;
    testCache(setAmount, setSize, blockSize, prefetchLength, 1, addressList);
    cout << "Prueba de Cache con prefetching de salto" << endl;
    testCache(setAmount, setSize, blockSize, prefetchLength, 2, addressList);
    cout << "Prueba de Cache con ambos tipos de prefetching" << endl;
    testCache(setAmount, setSize, blockSize, prefetchLength, 3, addressList);
    return 0;
}