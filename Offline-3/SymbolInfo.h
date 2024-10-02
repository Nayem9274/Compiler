#include<iostream>
#include <bits/stdc++.h>
#include<string>
#include<ctime>
#include<vector>
#include <algorithm>

using namespace std;

class SymbolInfo
{
    string name;
    string type;
    string datatype;
    string speciestype;
    string length; // name of the symbol and type of the symbol
    bool is_function,is_array;
    vector<SymbolInfo>  parameters;
    SymbolInfo *next; // pointer to an object of the SymbolInfo class as we need to implement a chaining mechanism to resolve collisions in the hash table

public:
    // Default constructor
  
    //parameterized constructor
    SymbolInfo(string name,string type)
    {
        this->name=name;
        this->type=type;
        datatype="SORRY";
        speciestype="none";
        next=nullptr;
    }
    SymbolInfo(string name,string type,string datatype,string speciestype)
    {
        this->name=name;
        this->type=type;
        this->datatype=datatype;
        this->speciestype=speciestype;
        next=nullptr;
    }
    //Destructor
   /* ~SymbolInfo()
    {
        next=nullptr;
    }*/
    //getters & setters
    string getName()
    {
        return name;
    }
    string getType()
    {
        return type;
    }
     string getArrayLength() 
     {
         return length; 
     }
    string getDataType() 
    { 
            return datatype;
    }
    string getSpeciesType() 
    { 
            return speciestype;
    }
    bool getIsFunction() 
    { 
            return this->is_function;
    }
     bool getIsArray() 
    { 
            return this->is_array;
    }
    vector<SymbolInfo> getFuncParameters() 
    { 
            return this->parameters;
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
    void setArrayLength(string length)
    {
         this->length = length;
    }
    void setDataType(string datatype)
    {
         this->datatype = datatype; 
    }
    void setIsFunction(bool b)
    {
         this->is_function = b; 
    }
     void setIsArray(bool b)
    {
         this->is_array = b; 
    }
    void setSpeciesType(string r)
    {
         speciestype = r; 
    }
    void addFuncParameters(SymbolInfo si){
        parameters.push_back(si);
    }
     void clearFuncParameters() {
        parameters.clear();
    }




};
