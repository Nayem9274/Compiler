%option noyywrap

%x STRING
%x SINGLE_COMMENT
%x MULTILINE_COMMENT

%{

#include <iostream>
#include <bits/stdc++.h>
#include <fstream>
#include <string>
#include <cstring>
#include <algorithm>

#include "SymbolTable.h"
// Bucket size defined
#define BUCKETS 10

using namespace std;

int line_count=1;
int comment_line_count;
int error_count=0; // no. of errors
int counter=0;
string s1,s2,comment;
ofstream logout;
ofstream tokenout;
SymbolTable symbolTable(BUCKETS);

string UPPER(string s)
{
	for(auto &character:s) character = toupper(character);
	return s;
}



%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
ALPHANUMERIC [a-zA-Z0-9]
UNDERSCORE _
KEYWORD "if"|"else"|"for"|"while"|"do"|"break"|"int"|"char"|"float"|"double"|"void"|"return"|"switch"|"case"|"default"|"continue"
NEWLINE \n|\r\n


%%

{WHITESPACE} {} // Skip

{NEWLINE} {line_count++;} 

{KEYWORD} {
              tokenout<<"<"<<UPPER(yytext)<<", "<<yytext <<">\n";
              logout<<"Line# "<<line_count<<": Token <"<<UPPER(yytext)<<"> Lexeme "<<yytext<<" found\n";
}
		
{DIGIT}+ {
			  tokenout<<"<CONST_INT, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <CONST_INT> Lexeme "<<yytext<<" found\n";				
}

{DIGIT}*"."{DIGIT}+ {
	          tokenout<<"<CONST_FLOAT, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <CONST_FLOAT> Lexeme "<<yytext<<" found\n";	
}  

{DIGIT}*"."?{DIGIT}+[E][-]?{DIGIT}+ {
              tokenout<<"<CONST_FLOAT, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <CONST_FLOAT> Lexeme "<<yytext<<" found\n";	
}

{DIGIT}*"."{DIGIT}+([E][-]?{DIGIT}+)?("."{DIGIT}*|"."{DIGIT}*[E][-]?{DIGIT}+) {
               error_count++;
               logout<<"Error at line# "<<line_count<<": TOO_MANY_DECIMAL_POINTS "<<yytext<<endl;
}

{DIGIT}*[E][-]?{DIGIT}*("."{DIGIT}*)+ {
               error_count++;
               logout<<"Error at line# "<<line_count<<": ILLFORMED_NUMBER "<<yytext<<endl;

}



\'((\\n)|(\\t)|(\\\\)|(\\\')|(\\\")|(\\a)|(\\f)|(\\r)|(\\b)|(\\v)|(\\0)|{ALPHANUMERIC})\' {
                char temp = yytext[2];
                        char c;
                        if(yytext[1]=='\\'){
                            if(temp=='n'){c='\n';}
                            else if(temp=='t'){c='\t';}
                            else if(temp=='a'){c='\a';}
                            else if(temp=='f'){c='\f';}
                            else if(temp=='b'){c='\b';}
                            else if(temp=='v'){c='\v';}
                            else if(temp=='r'){c='\r';}
                            else if(temp=='0'){c='\0';}
                            else if(temp=='\\'){c='\\';}
                            else if(temp=='\''){c='\'';}
                            else if(temp=='\"'){c='\"';}
                        }
                        else {c=yytext[1];}

                        tokenout<<"<CONST_CHAR, "<<c<<">\n";
                        logout<<"Line# "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found\n";	

}

\'\' {
              error_count++;
              logout<<"Error at line# "<<line_count<<": EMPTY_CONST_CHAR "<<yytext<<endl;
 }

\'.[^\'\r\n]+\' {
              error_count++;
              logout<<"Error at line# "<<line_count<<": MULTICHAR_CONST_CHAR "<<yytext<<endl;     
}



\'((\\n)|(\\t)|(\\\\)|(\\\')|(\\a)|(\\f)|(\\r)|(\\b)|(\\v)|(\\0)|(\\)|{ALPHANUMERIC})* {
              error_count++;
              logout<<"Error at line# "<<line_count<<": UNFINISHED_CONST_CHAR "<<yytext<<endl; 
}



"+"|"-" {
              tokenout<<"<ADDOP, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <ADDOP> Lexeme "<<yytext<<" found\n";
}

"*"|"/"|"%" {
              tokenout<<"<MULOP, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <MULOP> Lexeme "<<yytext<<" found\n";
}

"++"|"--" {
              tokenout<<"<INCOP, "<<yytext<<">\n";
               logout<<"Line# "<<line_count<<": Token <INCOP> Lexeme "<<yytext<<" found\n";
}

"<"|"<="|">"|">="|"=="|"!=" {
              tokenout<<"<RELOP, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <RELOP> Lexeme "<<yytext<<" found\n";
}

"=" {
              tokenout<<"<ASSIGNOP, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <ASSIGNOP> Lexeme "<<yytext<<" found\n";
}

"&&"|"||" {
              tokenout<<"<LOGICOP, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <LOGICOP> Lexeme "<<yytext<<" found\n";
}

"&"|"|"|"^"|"<<"|">>" {
              tokenout<<"<BITOP, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <BITOP> Lexeme "<<yytext<<" found\n";
}

"!" {
              tokenout<<"<NOT, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <NOT> Lexeme "<<yytext<<" found\n";
}

"(" {
              tokenout<<"<LPAREN, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <LPAREN> Lexeme "<<yytext<<" found\n";
}
")" {
              tokenout<<"<RPAREN, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <RPAREN> Lexeme "<<yytext<<" found\n";
}

"{" {
              tokenout<<"<LCURL, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <LCURL> Lexeme "<<yytext<<" found\n";
              symbolTable.EnterScope();
}
"}" {
              tokenout<<"<RCURL, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <RCURL> Lexeme "<<yytext<<" found\n";
              symbolTable.ExitScope();
}

"[" {
              tokenout<<"<LSQUARE, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <LSQUARE> Lexeme "<<yytext<<" found\n";
}
"]" {
              tokenout<<"<RSQUARE, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <RSQUARE> Lexeme "<<yytext<<" found\n";
}

"," {
              tokenout<<"<COMMA, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <COMMA> Lexeme "<<yytext<<" found\n";
}
";" {
              tokenout<<"<SEMICOLON, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <SEMICOLON> Lexeme "<<yytext<<" found\n";
}


({LETTER}|{UNDERSCORE})({LETTER}|{UNDERSCORE}|{DIGIT})* {
              tokenout<<"<ID, "<<yytext<<">\n";
              logout<<"Line# "<<line_count<<": Token <ID> Lexeme "<<yytext<<" found\n";
              string s(yytext);
              if(symbolTable.Insert(s, "ID")) symbolTable.PrintAllScopeTable(logout);
              else logout <<"        " <<s << " already exists in the current ScopeTable\n";
}

{DIGIT}+({LETTER}|{UNDERSCORE})({LETTER}|{UNDERSCORE}|{DIGIT})* {
              error_count++;
              logout<<"Error at line# "<<line_count<<": INVALID_ID_SUFFIX_NUM_PREFIX "<<yytext<<endl;
}

\"		{
				s1.clear();
				s2.clear();
				counter= 0;
				s1 += yytext;
				//s2 += "\"";
				BEGIN STRING;
		}

<STRING>\\n	{ 
    s1 += yytext; 
    s2 += "\n";  
}        

<STRING>\\t {
     s1 +=yytext ; 
     s2 += "\t" ; 
}

<STRING>\\\\	{ 
     s1 += yytext;
     s2 += "\\" ;
 }
<STRING>\\\'	{ 
     s1 += yytext;
     s2 += "\'";  
}
<STRING>\\\"	{
     s1 += yytext;
     s2 += "\""; 
}
<STRING>\\a	{ 
     s1 += yytext;
     s2 += "\a";
}
<STRING>\\f	{ 
     s1 +=yytext;
     s2 += "\f"; 
}
<STRING>\\r	{ 
    s1 += yytext; 
    s2 += "\r";  
}
<STRING>\\b	{ 
    s1 += yytext; 
    s2 += "\b";  
}
<STRING>\\v	{
     s1 += yytext; 
     s2 += "\v"; 
}
<STRING>\\0	{ 
    s1 += yytext; 
    s2 += "\0";
}
<STRING>\\{NEWLINE} {
				  counter++;
				  s1 += yytext; 
}
<STRING>\" {
                  
					s1 += yytext;
					s2 = "\""+s2+"\"";
                    if (counter==0){
                    tokenout<<"<SINGLE LINE STRING, "<<s2<<">\n";
                    logout<<"Line# "<<line_count<<": Token <SINGLE LINE STRING> Lexeme "<<s1<<" found\n";
                    }
                    else {
                    tokenout<<"<MULTI LINE STRING, "<<s2<<">\n";
                    logout<<"Line# "<<line_count<<": Token <MULTI LINE STRING> Lexeme "<<s1<<" found\n";
                    }
                    line_count+=counter;
                    counter=0;
                    s1.clear();
                    s2.clear();
                    BEGIN INITIAL;
}


<STRING>{NEWLINE} {
				  error_count++;
                  logout<<"Error at line# "<<line_count<<": UNFINISHED_STRING "<<s1.c_str()<<endl; 
                  counter++;
                  line_count+=counter;
                  counter=0;
                  BEGIN INITIAL;
}
<STRING><<EOF>> {
				  error_count++;
                  logout<<"Error at line# "<<line_count<<": UNFINISHED_STRING "<<s1.c_str()<<endl; 
                  line_count+=counter;
                  counter=0;
                  BEGIN INITIAL;
}
<STRING>.	{
               s1 += yytext[0];
               s2 += yytext[0];
}


\/\/ {
              comment_line_count = line_count;
              comment = yytext;
              BEGIN SINGLE_COMMENT;
}

<SINGLE_COMMENT>{NEWLINE} {
               line_count++;
               logout<<"Line# "<<comment_line_count<<": Token <SINGLE LINE COMMENT> Lexeme "<<comment<<" found\n";
               BEGIN INITIAL;
}

<SINGLE_COMMENT>\\{NEWLINE} {
              line_count++;
              comment+= yytext;
}

<SINGLE_COMMENT>. {
               comment+= yytext;
}
\/\* {
              comment_line_count = line_count;
              comment = yytext;
              BEGIN MULTILINE_COMMENT;
}
<MULTILINE_COMMENT>\*\/ {
               comment+=yytext;
               logout<<"Line# "<<comment_line_count<<": Token <MULTI LINE COMMENT> Lexeme "<<comment<<" found\n";
               BEGIN INITIAL;
}
<MULTILINE_COMMENT>{NEWLINE} {
               line_count++;
               comment+= yytext;
}
<MULTILINE_COMMENT><<EOF>> {
                error_count++;
                logout<<"Error at line# "<<comment_line_count+1<<": UNFINISHED_COMMENT "<<comment<<endl;
                symbolTable.PrintAllScopeTable(logout);
                logout << "Total lines: " << line_count << endl;
                logout << "Total errors: " << error_count << endl;
               return 0;

              //symbolTable.PrintAllScopeTable(logout);
}
<MULTILINE_COMMENT>. {
               comment+= yytext;
}

 <<EOF>> {
              symbolTable.PrintAllScopeTable(logout);
              logout << "Total lines: " << line_count << endl;
              logout << "Total errors: " << error_count << endl;
               return 0;
}


		
. {
              error_count++;
              logout<<"Error at line# "<<line_count<<": UNRECOGNIZED_CHAR "<<yytext<<"\n";     
}
%%

int main(int argc, char** argv) {
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	//logout= fopen("log.txt","w");
	//tokenout= fopen("token.txt","w");
    logout.open("1905034_log.txt");
    tokenout.open("1905034_token.txt");

	yyin= fin;
    yylineno=1;
	yylex();
	//st.print();
	fclose(yyin);
    /*symbolTable.PrintAllScopeTable(logout);
    logout << "Total lines: " << line_count << endl;
    logout << "Total errors: " << error_count << endl;*/

     logout.close();
     tokenout.close();
   	//fclose(tokenout);
	//fclose(logout);
	return 0;
}
