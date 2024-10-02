
#include <iostream>
#include <bits/stdc++.h>
#include <fstream>
#include <string>
#include <cstring>
#include <algorithm>

#include "1905034_SymbolTable.h"
using namespace std;
/*
#include<iostream>
#include <bits/stdc++.h>
#include<string>
#include<ctime>
#include <algorithm>
#include "SymbolTable.h"

using namespace std;


int main()
{
    freopen("sample_input.txt","r",stdin);
    freopen("sample_output.txt","w",stdout);
    int buckets;
    string code;
    int k=1;
    cin>>buckets;
    SymbolTable symbolTable(buckets);
    while (cin >> code)
    {
        if (code == "I")
        {
            string symbolName, symbolType;
            cin >> symbolName >> symbolType;
            cout<<"Cmd "<<k<<": "<<code<<" "<<symbolName<<" "<<symbolType<<endl;
            cout<<"        ";
            symbolTable.Insert(symbolName, symbolType);
        }
        else if (code == "L")
        {
            string symbolName,symbolName1;
            //cin>>symbolName>>symbolName1;

            //cout<<symbolName1<<"?"<<endl;
*/

int main()
{
    fstream Input_File;
    Input_File.open("sample_input.txt", ios::in);
    fstream Output_File;
   // Output_File.open("S_output.txt", ios::out|ios::trunc);
    int buckets; // number of buckets
    Input_File>>buckets;
    Input_File.ignore();
    freopen("1905034_output.txt","w",stdout);
     cout<<"        ";

    SymbolTable symbolTable(buckets);


    if(Input_File.is_open())
    {
        string line, code;
        string tokens[20];
        int x, k = 1;
        char single_line[100];
        char *delimiter;
        while(getline(Input_File, line))
        {
            x = 0;
            strcpy(single_line, line.c_str());
            delimiter = strtok(single_line, " ");
            while(delimiter != nullptr)
            {
                tokens[x] = delimiter;
                delimiter = strtok(nullptr, " ");
                x++;
            }
            if(x == 0)
            {
                continue;
            }
            cout<<"Cmd "<<k<<": "<<line<<endl;
            cout<<"        ";
            code = tokens[0];
            if(code == "I") // Insertion
            {
                if(x != 3)
                {
                    cout<<"Number of parameters mismatch for the command I"<<endl;
                    k++;
                    continue;
                }
                string symbolName;
                symbolName = tokens[1];
                string symbolType;
                symbolType= tokens[2];


                symbolTable.Insert(symbolName, symbolType);
            }
            else if(code == "L")   // LookUp
            {
                if(x != 2)
                {
                    cout<<"Number of parameters mismatch for the command L"<<endl;
                    k++;
                    continue;
                }
                string symbolName;
                symbolName = tokens[1];
                symbolTable.LookUp(symbolName);
            }
            else if(code == "D")   // Delete
            {
                if(x != 2)
                {
                    cout<<"Number of parameters mismatch for the command D"<<endl;
                    k++;
                    continue;
                }
                string symbolName;
                symbolName = tokens[1];
                symbolTable.Remove(symbolName);
            }
            else if(code == "P")   // Print
            {
                if(x != 2)
                {
                    cout<<"Number of parameters mismatch for the command P"<<endl;
                    k++;
                    continue;
                }
                string second;
                second = tokens[1];
                if(second == "A") // Print all scope table
                {
                    symbolTable.PrintAllScopeTable();

                }
                else if(second == "C")   // Print current scope table
                {
                    symbolTable.PrintCurrentScopeTable();
                }

            }
            else if(code == "S")
            {
                if(x != 1)
                {
                    cout<<"Number of parameters mismatch for the command S"<<endl;
                    k++;
                    continue;
                }
                symbolTable.EnterScope();
            }
            else if(code == "E")
            {
                if(x != 1)
                {
                    cout<<"Number of parameters mismatch for the command E"<<endl;
                    k++;
                    continue;
                }
                 symbolTable.ExitScope();
            }
            else if(code == "Q")
            {
                if(x != 1)
                {
                    cout<<"Number of parameters mismatch for the command Q"<<endl;
                    k++;
                    continue;
                }
                symbolTable.Q();
                Input_File.close();
                break;
            }
            k++;
        }
        Input_File.close();
        Output_File.close();
    }
    else
    {
        cout<<"Cannot open the input file"<<endl;
    }
    return 0;
}
