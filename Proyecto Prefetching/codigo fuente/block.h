#ifndef BLOCK_H_
#define BLOCK_H_

#include <iostream>
#include <string>

using namespace std;

template <class DataType>
class Word
{
    private:
        DataType storedData;
        Word<DataType>* nextWord;
    public:
        // Constructor
        Word(Word<DataType>* _nextWord);
        // Getters
        DataType getData();
        Word<DataType>* getNextWord();
        // Setters
        void setData(DataType _data);
        void setNextWord(Word<DataType>* _nextWord);
};

template <class DataType>
class Block
{
    private:
        int wordAmount;
        Word<DataType>* firstWord;
        Block<DataType>* nextBlock;
        string tag;
        bool validBit;
    public:
        // Constructor
        Block(int _wordAmount, Block<DataType>* _nextBlock);
        // Getters
        int getWordNumber();
        Word<DataType>* getFirstWord();
        Block<DataType>* getNextBlock();
        string getTag();
        bool getValidBit();
        // Setters
        void setWordNumber(int _amount);
        void setFirstWord(Word<DataType>* _word);
        void setNextBlock(Block<DataType>* _block);
        void setTag(string _tag);
        void setValidBit(bool _validBit);

};

#endif

//// CONSTRUCTORES

template <class DataType>
Word<DataType>::Word(Word<DataType>* _nextWord)
{
    nextWord = _nextWord;
}

template <class DataType>
Block<DataType>::Block(int _wordAmount, Block<DataType>* _nextBlock)
{
    wordAmount = _wordAmount;
    validBit = false;
    Word<DataType>* prevWord = NULL;
    // Crear el numero deseado de palabras en cadena
    for(int i = 0; i < _wordAmount; i++)
    {
        Word<DataType>* newWord = new Word<DataType>(prevWord);
        prevWord = newWord;
    }
    firstWord = prevWord;
    nextBlock = _nextBlock;
}

//// GETTERS

template <class DataType>
DataType Word<DataType>::getData()
{
    return storedData;
}
template <class DataType>
Word<DataType>* Word<DataType>::getNextWord()
{
    return nextWord;
}

template <class DataType>
int Block<DataType>::getWordNumber()
{
    return wordAmount;
}
template <class DataType>
Word<DataType>* Block<DataType>::getFirstWord()
{
    return firstWord;
}
template <class DataType>
Block<DataType>* Block<DataType>::getNextBlock()
{
    return nextBlock;
}
template <class DataType>
string Block<DataType>::getTag()
{
    return tag;
}
template <class DataType>
bool Block<DataType>::getValidBit()
{
    return validBit;
}

//// SETTERS
template <class DataType>
void Word<DataType>::setData(DataType _data)
{
    storedData = _data;
}
template <class DataType>
void Word<DataType>::setNextWord(Word<DataType>* _nextWord)
{
    nextWord = _nextWord;
}

template <class DataType>
void Block<DataType>::setWordNumber(int _amount)
{
    wordAmount = _amount;
}
template <class DataType>
void Block<DataType>::setFirstWord(Word<DataType>* _word)
{
    firstWord = _word;
}
template <class DataType>
void Block<DataType>::setNextBlock(Block<DataType>* _block)
{
    nextBlock = _block;
}
template <class DataType>
void Block<DataType>::setTag(string _tag)
{
    tag = _tag;
}
template <class DataType>
void Block<DataType>::setValidBit(bool _validBit)
{
    validBit = _validBit;
}