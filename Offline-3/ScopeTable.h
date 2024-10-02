#include<iostream>
#include <bits/stdc++.h>
#include<string>
#include<fstream>
#include<ctime>
#include <algorithm>
#include "SymbolInfo.h"

using namespace std;


class ScopeTable
{
    int id; // assigning to each scope table a unique number
    int buckets; // total buckets in hash yable
    ScopeTable *parent_scope; // maintaining a list of scope tables in the symbol table
    int counter; // child scope counter
    SymbolInfo ** table; // Hash table


public:
    // constructor - initializing id instead of using getter and setter

    ScopeTable(int size,int id,ScopeTable *parent_scope)
    {
        buckets=size;
        this->id=id;
        counter=0;
        table= new SymbolInfo*[buckets];
        this->parent_scope=parent_scope;
        // initialize each table slot to nullptr
        for (int i = 0; i < buckets; i++)
        {
            table[i] = nullptr;
        }
        //generate id

        if(parent_scope!=nullptr)
        {
             
            
            cout<<"ScopeTable# "<<id<<" created"<<endl;
            id++;

        }
        else
        {
            id=1;
            //cout<<"        ";
            cout<<"ScopeTable# "<<id<<" created"<<endl;

        }
    }
    ~ScopeTable()
    {
        // Deleting table elements individually as pointers
        for(int i=0; i<buckets; i++)
        {
            if(table[i]!=nullptr)
            {
                SymbolInfo * s=table[i];
                while(s!=nullptr)
                {
                    SymbolInfo *temp=s;
                    s=s->getNext();
                    delete  temp;
                }
            }
        }
        delete []table;
    }
    // https://www.programmingalgorithms.com/algorithm/sdbm-hash/cpp/
    unsigned long SDBMHash(string str)
    {
        unsigned long hash=0;
        for(int i=0; i<str.length(); i++)
        {
            hash= str[i] + (hash << 6) + (hash << 16) - hash;
            hash%=buckets;
        }
        return hash;
    }
    bool insert(SymbolInfo *symbolInfo)
    {
        int count = 0;
    int hash_value = SDBMHash(symbolInfo->getName());
    int res = 0;
    int cnt=0;

    if(table[hash_value] == NULL){
        table[hash_value] = symbolInfo;
        res = 1;
        cout << "Inserted in ScopeTable# " << id <<endl;
    }else{
        SymbolInfo * current=table[hash_value];
            SymbolInfo *prev=nullptr; //initially null
            while(current!=nullptr)
            {
                if(current->getName()==symbolInfo->getName())
                {
                    //cout <<"'" << name << "' already exists in the current ScopeTable"<<endl<<endl;///
                    return false;
                }
                cnt++;
                prev=current;
                current=current->getNext();
            }
            prev->setNext(symbolInfo);
        /*SymbolInfo* temp = table[hash_value];
        while(temp->getNext() != NULL){
            if(temp->getName() == symbolInfo->getName()){
                res = -1;//duplicate entry
                break;
            }
            temp = temp->getNext();
            count++;
        }

        if(res == 0){
            if(temp->getName() == symbolInfo->getName()){
                res = -1;//duplicate entry
            }else{
                temp=temp->getNext(); 
                temp= symbolInfo;
                count++;
                res = 1;
            }*/
        
    }

   

    return true;
    }

    // Inserion
    bool Insert(string name,string type)
    {
        int idx= SDBMHash(name);//%buckets; // hash value of string
        int cnt=0;
        //2 cases
        // case 1 :  insertion already done once -- go to end of list and add new symbol
        if(table[idx]!=nullptr)//////////////////////////
        {
            SymbolInfo * current=table[idx];
            SymbolInfo *prev=nullptr; //initially null
            while(current!=nullptr)
            {
                if(current->getName()==name)
                {
                    //cout <<"'" << name << "' already exists in the current ScopeTable"<<endl<<endl;///
                    return false;
                }
                cnt++;
                prev=current;
                current=current->getNext();
            }
            prev->setNext(new SymbolInfo(name, type));

        }
        else
        {
            table[idx]=new SymbolInfo(name,type);
        }

        cout << "Inserted in ScopeTable# " << id << " at position " << idx+1 << ", " << cnt+1 <<endl;
        return true;
    }
    // search for symbol in scope table : calculate hash value for that particular index in hash table
    // linear search ( getters)

    SymbolInfo *LookUp(string name)
    {
        int idx=SDBMHash(name);//%buckets;
        SymbolInfo *s=table[idx];
        int cnt=0;
        while(s!=nullptr)
        {
            if(s->getName()==name)
            {
                cout <<"'"<<name << "' found in ScopeTable# " << id << " at position " << (idx+1) << ", " << (cnt+1) <<endl;
                cout<<name<<" data type: "<<s->getDataType()<<endl;
                return s;
            }
            s=s->getNext();
            cnt++;
        }
        return nullptr; // not found
    }

    bool Delete(string name)
    {
        int idx= SDBMHash(name);//%buckets; // hash value of string
        int cnt=0; // position of symbol
        SymbolInfo * current=table[idx];
        SymbolInfo *prev=nullptr; //initially null

        while(current!=nullptr )
        {
            if(current->getName()==name)
            {
                //cout <<name << " Found in ScopeTable# " << id << " at position " << (idx+1) + ", " << (cnt+1) <<endl;
                // 1st element
                if(prev==nullptr) table[idx]=current->getNext();
                else prev->setNext(current->getNext());

                delete current;
                cout<<"Deleted '" << name <<"' from ScopeTable# " <<id <<" at position " << (idx+1) << ", " << (cnt+1) <<endl;
                return true;
            }
            prev=current;
            current=current->getNext();
            cnt++;
        }
        cout<< "Not found in the current ScopeTable" <<endl;
        return false;

    }

     void Print(ofstream &logout)
    {
        logout << "        ScopeTable# " << id << endl;
        for (int i = 0; i < buckets; i++)
        {
            int k=0;
           
            SymbolInfo *current = table[i];
            while (current!= nullptr)
            {
                if(k!=1) {
                     logout<<"        ";
                     logout << i+1 << "-->";
                }
                k=1;
                logout << " <" << current->getName() << "," << current->getType() << "> ";
                current = current->getNext();
            }
            if(k==1)
            logout << endl;
        }
       // cout << endl;
    }
    

    int getId() {return id;}

    ScopeTable *getParent_Scope()
    {
        return parent_scope;
    }





};
