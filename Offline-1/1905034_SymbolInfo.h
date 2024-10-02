#include<iostream>
#include <bits/stdc++.h>
#include<string>
#include<ctime>
#include <algorithm>

using namespace std;

class SymbolInfo
{
    string name,type; // name of the symbol and type of the symbol
    SymbolInfo *next; // pointer to an object of the SymbolInfo class as we need to implement a chaining mechanism to resolve collisions in the hash table

public:
    // Default constructor
    SymbolInfo()
    {
        next=nullptr;
    }
    //parameterized constructor
    SymbolInfo(string name,string type)
    {
        this->name=name;
        this->type=type;
        next=nullptr;
    }
    //Destructor
    ~SymbolInfo()
    {
        next=nullptr;
    }
    //getters & setters
    string getName()
    {
        return name;
    }
    string getType()
    {
        return type;
    }
    SymbolInfo *getNext()
    {
        return next;
    }
    void setName(string name)
    {
        this->name=name;
    }
    void setType(string type)
    {
        this->type=type;
    }
    void setNext(SymbolInfo *next)
    {
        this->next=next;
    }




};
