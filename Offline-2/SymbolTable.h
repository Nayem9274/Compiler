#include<iostream>
#include <bits/stdc++.h>
#include<string>
#include<ctime>
#include<stack>
#include<fstream>
#include <algorithm>
#include "ScopeTable.h"

using namespace std;

class SymbolTable
{
    // list of scopetables. top of the list is current
    ScopeTable *curr;
    int buckets;
    int curr_id;

public:
    SymbolTable(int buckets)
    {
        curr_id=1;
        this->buckets=buckets;
        curr=new ScopeTable(buckets,curr_id,nullptr); // no parent scope initially-so null
        curr_id++;
    }

    ~SymbolTable()
    {
        ScopeTable * s=curr;
        while(s!=nullptr)
        {
            curr=curr->getParent_Scope(); // similar to pop of stack. delete current and gradually it's parent
            delete s;
            s=curr;
        }
    }

    //Creating a new scope table and make it the current one. Also, making
    //the previous �current� scope table as its parent_scope table.
    void EnterScope()
    {
        curr=new ScopeTable(buckets,curr_id,curr);// can directly be used in constructor MAYBE
        curr_id++;
    }

    // Removing the current scope table.
    void ExitScope()
    {
        if(this->curr==nullptr)
        {
            cout<<"No such scope exists"<<endl;
            return;
        }
        ScopeTable *s=this->curr;
        //curr=curr->getParent_Scope();
       // ScopeTable *gp=curr->getParent_Scope();
        /*if(curr!=nullptr)
        {

            cout<<"ScopeTable# " <<s->getId()<<" removed"<<endl;
            delete s;
        }
        else cout<<"ScopeTable# "<<s->getId()<<" cannot be removed"<<endl;
        */
        if(curr->getParent_Scope()==nullptr)  {
                cout<<"ScopeTable# 1 cannot be removed"<<endl;
                 return;
        }
        curr=curr->getParent_Scope();
        cout<<"ScopeTable# " <<s->getId()<<" removed"<<endl;
        delete s;


    }

    void Q()
    {
        if(this->curr==nullptr)
        {
            cout<<"No such scope exists"<<endl;
            return;
        }
        ScopeTable *s=this->curr;
        curr=curr->getParent_Scope();
       // ScopeTable *gp=curr->getParent_Scope();


            cout<<"ScopeTable# " <<s->getId()<<" removed"<<endl;
            delete s;


    }


    bool Insert(string name,string type)
    {
        return curr->Insert(name,type);
    }

    bool Remove(string name)
    {
        return curr->Delete(name);
    }

    SymbolInfo *LookUp(string name)
    {
        ScopeTable *s=curr;
        while(s!=nullptr)
        {
            SymbolInfo * i=s->LookUp(name);
            if (i) return i; // Found
            // If not found chcek search parent scope and so on
            s=s->getParent_Scope();
        }
        cout<<"'"<<name<< "' Not found in the current ScopeTable" <<endl;
        return nullptr;

    }

   /* void PrintCurrentScopeTable()
    {
        curr->Print();
    }*/

   /** void PrintAllScopeTable()
    {
        ScopeTable *s=curr;
        cout<<"        ";
        while(s!=nullptr)
        {
            s->Print();
            cout<<endl;
            s=s->getParent_Scope();
        }
    }*/
    void PrintAllScopeTable(ofstream &logout)
    {
          if(this->curr==nullptr)
        {
            logout<<"No such scope exists"<<endl;
            return;
        }
        ScopeTable *s=curr;
       // logout<<"       ";
        while (s!=nullptr)
        {
            s->Print(logout);
            //logout<<"      ";
            s=s->getParent_Scope();
        }
        
    }

    ScopeTable *getCurrentScopeTable()
    {
        return curr;
    }




};
