#ifndef CACHE_H_
#define CACHE_H_

#include "block.h"
#include <cmath>
#include <bits/stdc++.h>

using namespace std;

template <class DataType>
class Cache
{
    private:
        int blockAmount;
        int setSize;
        int setAmount;
        int setCounter[1024];
        int blockSize;
        int hits;
        int misses;
        int addressBits;
        int prefetchSetting;
        int prefetchLength;
        Block<DataType>* firstBlock;
        DataType memory[1024];
        unordered_map<string, string> prefetchMap;
        string prevBlock;
        // Private Methods
        string toBinaryString(int number, int bits);
        DataType searchSet(int targetSet, string addressTag, string addressSetID,
                           string addressWordID, int address);
        Block<DataType>* checkSet(Block<DataType>* initialBlock, string addressTag, int blocksToCheck, bool& hit);
        void replaceBlock(Block<DataType>* targetBlock, string addressTag, string addressSetID,
                          string addressWordID);
        DataType fetchWord(Block<DataType>* targetBlock, string addressWordID);
        void prefetch(string addressTag, string addressSetID, string addressWordID);
        void sequentialPrefetching(string addressTag, string addressSetID, string addressWordID);
        void jumpPrefetching(string addressTag, string addressSetID, string addressWordID);
        string checkPrefetchMap(string blockString);
        void setPrefetchMap(string blockFrom, string blockTo);
        string getFirstBlockPosition(string addressTag, string addressSetID, string addressWordID);
        void nextBlock(string& addressTag, string& addressSetID);
        void separateBlockString(string blockString, string& tag, string& setID);
    public:
        // Constructor
        Cache(int _setAmount, int _setSize, int _blockSize, DataType _memory[], int _memorySize);
        // Getters
        int getBlockAmount();
        int getSetSize();
        int getSetAmount();
        int getBlockSize();
        int getHits();
        int getMisses();
        Block<DataType>* getFirstBlock();
        // Setters
        void setFirstBlock(Block<DataType>* _block);
        void setPrefetchSetting(int setting);
        void setPrefetchLength(int length);
        // Metodos
        DataType readAddress(int address);
        
};

#endif

//// CONSTRUCTOR
template <class DataType>
Cache<DataType>::Cache(int _setAmount, int _setSize, int _blockSize, 
                       DataType _memory[], int _memorySize)
{
    setAmount = _setAmount;
    setSize = _setSize;
    blockAmount = setAmount * setSize;
    blockSize = _blockSize;
    hits = 0;
    misses = 0;
    addressBits = 32;
    Block<DataType>* oldBlock = NULL;
    for(int i = 0; i < blockAmount; i++)
    {
        Block<DataType>* newBlock = new Block<DataType>(blockSize, oldBlock);
        oldBlock = newBlock;
    }
    firstBlock = oldBlock;
    for(int i = 0; i < _memorySize; i++)
    {
        memory[i] = _memory[i];
    }
    prevBlock = "";
    prefetchSetting = 0;
    prefetchLength = 1;
}

//// GETTERS
template <class DataType>
int Cache<DataType>::getBlockAmount()
{
    return blockAmount;
}
template <class DataType>
int Cache<DataType>::getSetSize()
{
    return setSize;
}
template <class DataType>
int Cache<DataType>::getSetAmount()
{
    return setAmount;
}
template <class DataType>
int Cache<DataType>::getBlockSize()
{
    return blockSize;
}
template <class DataType>
int Cache<DataType>::getHits()
{
    return hits;
}
template <class DataType>
int Cache<DataType>::getMisses()
{
    return misses;
}
template <class DataType>
Block<DataType>* Cache<DataType>::getFirstBlock()
{
    return firstBlock;
}
//// SETTERS
template <class DataType>
void Cache<DataType>::setFirstBlock(Block<DataType>* _block)
{
    firstBlock = _block;
}
template <class DataType>
void Cache<DataType>::setPrefetchSetting(int setting)
{
    prefetchSetting = setting;
}
template <class DataType>
void Cache<DataType>::setPrefetchLength(int length)
{
    prefetchLength = length;
}

//// METODOS
template <class DataType>
string Cache<DataType>::toBinaryString(int number, int bits)
{
    int quotient = number;
    int remainder = 0;
    int currentBits = 0;
    string result;
    while(quotient > 0)
    {
        remainder = quotient % 2;
        quotient = quotient / 2;
        char digit = remainder + '0';
        result += digit;
        currentBits++;
    }
    while(currentBits < bits)
    {
        result += '0';
        currentBits++;
    }

    string invertedResult = string(result.rbegin(), result.rend());
    return invertedResult;
}
template <class DataType>
DataType Cache<DataType>::readAddress(int address)
{
    // Convertir la direccion a binario
    string binaryAddress = toBinaryString(address, addressBits);
    // Obtener el tamaño del offset
    int wordIDsize = log2(blockSize);
    // Obtener el tamaño del indice
    int setIDsize = log2(setAmount);
    // Obtener el tamaño de la etiqueta
    int tagSize = (addressBits) - (setIDsize + wordIDsize);
    // Obtener indice y etiqueta
    string addressTag;
    string addressSetID;
    string addressWordID;
    // Obtener los bits de la etiqueta
    for(int i = 0; i < tagSize; i++)
    {
        addressTag += binaryAddress[i];
    }
    // Obtener los bits del indice
    for(int i = tagSize; i < tagSize+setIDsize; i++)
    {
        addressSetID += binaryAddress[i];
    }
    if(addressSetID.size() == 0)
    {
        addressSetID = '0';
    }
    // Obtener los bits del offset
    for(int i = tagSize+setIDsize; i < tagSize+setIDsize+wordIDsize; i++)
    {
        addressWordID += binaryAddress[i];
    }
    // Obtener indice en decimal
    int targetSet = stoi(addressSetID, 0, 2);
    // Revisar el conjunto al que el indice apunta
    DataType result = searchSet(targetSet, addressTag, addressSetID, addressWordID, address);
    return result;

}
template <class DataType>
DataType Cache<DataType>::searchSet(int targetSet, string addressTag, string addressSetID, 
                                    string addressWordID, int address)
{
    // Formula de conjuntos:
    // Bloque inicial = (Conjunto) * (Tamaño de los conjuntos)
    // Bloque final   = [(Conjunto) * (Tamaño de los conjuntos)] + (Tamaño de los conjuntos - 1)
    int initialBlock = targetSet * setSize;
    int lastBlock = initialBlock + setSize - 1;
    int numberOfBlocks = lastBlock-initialBlock;
    DataType result;
    // Moverse al primer bloque del conjunto
    Block<DataType>* blockPointer = firstBlock;
    for(int i = 0; i < initialBlock; i++)
    {
        blockPointer = blockPointer->getNextBlock();
    }
    // Comparar las etiquetas de los bloques para ver si hay un acierto
    bool hit = false;
    Block<DataType>* searchPointer = checkSet(blockPointer, addressTag, numberOfBlocks, hit);
    // Si hay un acierto
    if(hit)
    {
        // Buscar la palabra deseada usando el offset
        result = fetchWord(searchPointer, addressWordID);
        hits++;
    }
    // Si hay un fallo
    else
    {
        // Obtener la informacion de la memoria y reemplazarla en el cache
        int toReplace = setCounter[targetSet];
        // Mover el puntero al primer bloque del conjunto
        Block<DataType>* searchPointer = blockPointer;
        // Nos movemos al bloque menos recientemente usado
        for(int i = 0; i < toReplace; i++)
        {
            searchPointer = searchPointer->getNextBlock();
        }
        // Reemplazamos la informacion en el bloque
        replaceBlock(searchPointer, addressTag, addressSetID, addressWordID);
        // Obtener el resultado
        result = memory[address];
        misses++;
    }
    // Prefetching
    if(prefetchSetting == 1 || prefetchSetting == 3)
    {
        sequentialPrefetching(addressTag, addressSetID, addressWordID);
    }
    if(prefetchSetting == 2 || prefetchSetting == 3)
    {
        jumpPrefetching(addressTag, addressSetID, addressWordID);
    }
    return result;
}
template <class DataType>
Block<DataType>* Cache<DataType>::checkSet(Block<DataType>* initialBlock, string addressTag, int blocksToCheck, bool& hit)
{
    // Comparar las etiquetas de los bloques para ver si hay un acierto
    hit = false;
    Block<DataType>* searchPointer = initialBlock;
    int i = 0;
    while(i <= blocksToCheck && hit == false)
    {
        if(searchPointer->getValidBit())
        {
            if(searchPointer->getTag() == addressTag)
            {
                hit = true;
            }
        }
        if(!hit)
        {
            searchPointer = searchPointer->getNextBlock();
            i++;
        }
    }
    return searchPointer;
}
template <class DataType>
void Cache<DataType>::replaceBlock(Block<DataType>* targetBlock, string addressTag, string addressSetID, string addressWordID)
{
    // Usamos este arreglo para implementar el metodo de reemplazo LRU
    int targetSet = 0;
    if(setAmount > 1)
    {
        targetSet = stoi(addressSetID, 0, 2);
        setCounter[targetSet]++;
        if(setCounter[targetSet] >= setSize)
        {
            setCounter[targetSet] = 0;
        }
    }
    // Reemplazamos la informacion en el bloque
    // Obtener primera posicion del bloque y convertirla a decimal
    string firstPos = getFirstBlockPosition(addressTag, addressSetID, addressWordID);
    int firstPosInt = stoi(firstPos, 0, 2);
    // Guardar todas las palabras en el bloque
    Word<DataType>* wordPointer = targetBlock->getFirstWord();
    for(int i = firstPosInt; i < firstPosInt + blockSize; i++)
    {
        wordPointer->setData(memory[i]);
        wordPointer = wordPointer->getNextWord();
    }
    // Actualizar etiqueta 
    targetBlock->setTag(addressTag);
    // Asignar el bit de validez
    targetBlock->setValidBit(true);
}
template <class DataType>
DataType Cache<DataType>::fetchWord(Block<DataType>* targetBlock, string addressWordID)
{
    // Buscar la palabra deseada usando el offset
    Word<DataType>* wordPointer = targetBlock->getFirstWord();
    if(blockSize > 1)
    {
        int addressWordIDint = stoi(addressWordID, 0, 2);
        for(int i = 0; i < addressWordIDint; i++)
        {
            wordPointer = wordPointer->getNextWord();
        }
    }
    
    DataType result = wordPointer->getData();
    return result;
}
template <class DataType>
void Cache<DataType>::prefetch(string addressTag, string addressSetID, string addressWordID)
{
    // Obtener indice en decimal
    int targetSet = 0;
    if(setAmount > 1)
    {
        targetSet = stoi(addressSetID, 0, 2);
    }
    int initialBlock = targetSet * setSize;
    // Moverse al primer bloque del conjunto
    Block<DataType>* blockPointer = firstBlock;
    for(int i = 0; i < initialBlock; i++)
    {
        blockPointer = blockPointer->getNextBlock();
    }
    // Obtener la informacion de la memoria y reemplazarla en el cache
    int toReplace = setCounter[targetSet];
    // Nos movemos al bloque menos recientemente usado
    for(int i = 0; i < toReplace; i++)
    {
        blockPointer = blockPointer->getNextBlock();
    }
    // Reemplazamos la informacion en el bloque
    replaceBlock(blockPointer, addressTag, addressSetID, addressWordID);
}
template <class DataType>
void Cache<DataType>::sequentialPrefetching(string addressTag, string addressSetID, string addressWordID)
{
    // Realizar Prefetching de los siguientes 'n' bloques
    for(int i = 0; i < prefetchLength; i++)
    {
        // Obtener siguiente bloque
        nextBlock(addressTag, addressSetID);
        prefetch(addressTag, addressSetID, addressWordID);
    }
}
template <class DataType>
void Cache<DataType>::jumpPrefetching(string addressTag, string addressSetID, string addressWordID)
{
    string blockString = addressTag + addressSetID;
    string nextBlock = checkPrefetchMap(blockString);
    if(nextBlock != "")
    {
        string newTag = "";
        string newSetID = "";
        separateBlockString(nextBlock, newTag, newSetID);
        prefetch(newTag, newSetID, addressWordID);
    }
    if(prevBlock != "")
    {
        setPrefetchMap(prevBlock, blockString);
    }
    prevBlock = blockString;
}
template <class DataType>
string Cache<DataType>::checkPrefetchMap(string blockString)
{
    auto it = prefetchMap.find(blockString);
    if(it != prefetchMap.end())
    {
        return prefetchMap[blockString];
    }
    else
    {
        return "";
    }
}
template <class DataType>
void Cache<DataType>::setPrefetchMap(string blockFrom, string blockTo)
{
    prefetchMap[blockFrom] = blockTo;
}
template <class DataType>
string Cache<DataType>::getFirstBlockPosition(string addressTag, string addressSetID, string addressWordID)
{
    string firstPos = addressTag;
    if(setAmount > 1)
    {
        firstPos += addressSetID;
    }
    if(blockSize > 1)
    {
        for(int i = 0; i < addressWordID.size(); i++)
        {
            firstPos += '0';
        }
    }
    return firstPos;
}
template <class DataType>
void Cache<DataType>::nextBlock(string& addressTag, string& addressSetID)
{
    // Obtener cadena del bloque
    string blockString = addressTag;
    if(setAmount > 1)
    {
        blockString += addressSetID;
    }
    int stringLength = blockString.size();
    int blockInt = stoi(blockString, 0, 2);
    blockInt++;
    blockString = toBinaryString(blockInt, stringLength);
    separateBlockString(blockString, addressTag, addressSetID);
}
template <class DataType>
void Cache<DataType>::separateBlockString(string blockString, string& tag, string& setID)
{
    // Obtener el tamaño del indice y etiqueta
    int wordIDsize = log2(blockSize);
    int setIDsize = log2(setAmount);
    int tagSize = (addressBits) - (setIDsize + wordIDsize);
    // Resetear la etiqueta e indice
    tag = "";
    setID = "";
    // Obtener los bits de la etiqueta
    for(int i = 0; i < tagSize; i++)
    {
        tag += blockString[i];
    }
    // Obtener los bits del indice
    for(int i = tagSize; i < tagSize+setIDsize; i++)
    {
        setID += blockString[i];
    }
}