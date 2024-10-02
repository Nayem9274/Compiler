%option noyywrap

%x STRING
%x SINGLE_COMMENT
%x MULTILINE_COMMENT

%{
#include<iostream>
#include<stdlib.h>
#include <bits/stdc++.h>
#include<string.h>
#include <fstream>
#include <string>
#include <cstring>
#include <algorithm>

#include "SymbolInfo.h"
//#include "1905034_SymbolTable.cpp"
#include "y.tab.h"


using namespace std;

extern YYSTYPE yylval;
//extern SymbolTable *table;
//extern SymbolInfo *info;
extern ofstream logout;
extern ofstream errorout;
extern ofstream tokenout;

void yyerror(char *);

int line_count=1;
int comment_line_count;
int error_count=0;
int counter=0;
string s1,s2,comment;

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
KEYWORD "if"|"else"|"for"|"while"|"do"|"break"|"int"|"char"|"float"|"double"|"void"|"return"|"switch"|"case"|"default"|"continue"|"printf"|"println"
NEWLINE \n|\r\n
ADDOP [+-] 
MULOP [*/%]


%%
{WHITESPACE} {} // Skip

{NEWLINE} {line_count++;}

{KEYWORD} {
           string s= UPPER(yytext);
           logout<<"Line# "<<line_count<<": Token <"<<UPPER(yytext)<<"> Lexeme "<<yytext<<" found\n";
   if(s == "IF") return IF;
   else if(s == "ELSE") return ELSE;
   else if(s == "FOR") return FOR;
   else if(s == "WHILE") return WHILE;
   else if(s == "INT") return INT;
   else if(s == "FLOAT") return FLOAT;
   else if(s == "DOUBLE") return DOUBLE;
   else if(s == "CHAR") return CHAR;
   else if(s == "VOID") return VOID;
   else if(s == "RETURN") return RETURN;
   else if(s == "PRINTF") return PRINTLN; 
   else if(s == "PRINTLN") return PRINTLN;

}




{ADDOP} { 
			logout<<"Line# "<<line_count<<": Token <ADDOP> Lexeme "<<yytext<<" found\n";
            SymbolInfo *info= new  SymbolInfo(yytext, (char *)"ADDOP");
			yylval.si = info;
			return ADDOP;
		}



{MULOP}	{
			 logout<<"Line# "<<line_count<<": Token <MULOP> Lexeme "<<yytext<<" found\n";
             yylval.si = new SymbolInfo(yytext, "MULOP");
             return MULOP;
		}


"=" 	{logout<<"Line# "<<line_count<<": Token <ASSIGNOP> Lexeme "<<yytext<<" found\n"; return ASSIGNOP;}

">" |
"<" |
">=" |
"<=" |
"==" |
"!=" {
		logout<<"Line# "<<line_count<<": Token <RELOP> Lexeme "<<yytext<<" found\n";
        yylval.si= new  SymbolInfo(yytext, (char *)"RELOP");
		return RELOP;
	}

"&&"	|
"||"	{
			logout<<"Line# "<<line_count<<": Token <LOGICOP> Lexeme "<<yytext<<" found\n";
            yylval.si= new  SymbolInfo(yytext, (char *)"LOGICOP");
			return LOGICOP;
		}
"!"		{logout<<"Line# "<<line_count<<": Token <NOT> Lexeme "<<yytext<<" found\n";	return NOT; }


";" 	{ logout<<"Line# "<<line_count<<": Token <SEMICOLON> Lexeme "<<yytext<<" found\n";return SEMICOLON;}
"," 	{logout<<"Line# "<<line_count<<": Token <COMMA> Lexeme "<<yytext<<" found\n";return COMMA;}
"(" 	{logout<<"Line# "<<line_count<<": Token <LPAREN> Lexeme "<<yytext<<" found\n";return LPAREN;}
")" 	{logout<<"Line# "<<line_count<<": Token <RPAREN> Lexeme "<<yytext<<" found\n";return RPAREN;}
"{" 	{logout<<"Line# "<<line_count<<": Token <LCURL> Lexeme "<<yytext<<" found\n";return LCURL;}
"}" 	{logout<<"Line# "<<line_count<<": Token <RCURL> Lexeme "<<yytext<<" found\n";return RCURL;}
"[" 	{logout<<"Line# "<<line_count<<": Token <LTHIRD> Lexeme "<<yytext<<" found\n";return LTHIRD;}
"]" 	{logout<<"Line# "<<line_count<<": Token <RTHIRD> Lexeme "<<yytext<<" found\n";return RTHIRD;}
"++" 	{logout<<"Line# "<<line_count<<": Token <INCOP> Lexeme "<<yytext<<" found\n";return INCOP;}
"--" 	{logout<<"Line# "<<line_count<<": Token <DECOP> Lexeme "<<yytext<<" found\n";return DECOP;}


{DIGIT}+ {
			    logout<<"Line# "<<line_count<<": Token <CONST_INT> Lexeme "<<yytext<<" found\n";
               string s = yytext;
               yylval.si = new SymbolInfo(s, "CONST_INT");
               return CONST_INT;		
}

{DIGIT}*"."{DIGIT}+ {
              logout<<"Line# "<<line_count<<": Token <CONST_FLOAT> Lexeme "<<yytext<<" found\n";	
	          yylval.si=new SymbolInfo(yytext,"CONST_FLOAT");
			  return CONST_FLOAT;	
}  

{DIGIT}*"."?{DIGIT}+[E][-]?{DIGIT}+ {
              logout<<"Line# "<<line_count<<": Token <CONST_FLOAT> Lexeme "<<yytext<<" found\n";	
              yylval.si=new SymbolInfo(yytext,"CONST_FLOAT");
			  return CONST_FLOAT;
}

{DIGIT}*"."{DIGIT}+([E][-]?{DIGIT}+)?("."{DIGIT}*|"."{DIGIT}*[E][-]?{DIGIT}+) {
               error_count++;
              // logout<<"Error at line# "<<line_count<<": TOO_MANY_DECIMAL_POINTS "<<yytext<<endl;
}

{DIGIT}*[E][-]?{DIGIT}*("."{DIGIT}*)+ {
               error_count++;
               //logout<<"Error at line# "<<line_count<<": ILLFORMED_NUMBER "<<yytext<<endl;

}

({LETTER}|{UNDERSCORE})({LETTER}|{UNDERSCORE}|{DIGIT})* {
              //info= table->LookUp(yytext);
              logout<<"Line# "<<line_count<<": Token <ID> Lexeme "<<yytext<<" found\n";
                SymbolInfo *info= new SymbolInfo(yytext, (char *)"ID");
				yylval.si=info;
							
				return ID;
}

{DIGIT}+({LETTER}|{UNDERSCORE})({LETTER}|{UNDERSCORE}|{DIGIT})* {
              error_count++;
              //logout<<"Error at line# "<<line_count<<": INVALID_ID_SUFFIX_NUM_PREFIX "<<yytext<<endl;
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

                        //tokenout<<"<CONST_CHAR, "<<c<<">\n";
                        logout<<"Line# "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found\n";	
						yylval.si = new SymbolInfo(yytext, "CONST_CHAR");
                        return CONST_CHAR;

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
                    ///tokenout<<"<SINGLE LINE STRING, "<<s2<<">\n";
                    logout<<"Line# "<<line_count<<": Token <SINGLE LINE STRING> Lexeme "<<s1<<" found\n";
                    }
                    else {
                    //tokenout<<"<MULTI LINE STRING, "<<s2<<">\n";
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
                //symbolTable.PrintAllScopeTable(logout);
                logout << "Total lines: " << line_count << endl;
                logout << "Total errors: " << error_count << endl;
               return 0;

              //symbolTable.PrintAllScopeTable(logout);
}
<MULTILINE_COMMENT>. {
               comment+= yytext;
}

 <<EOF>> {
              //symbolTable.PrintAllScopeTable(logout);
              //logout << "Total lines: " << line_count << endl;
              //logout << "Total errors: " << error_count << endl;
               return 0;
}

. {
              error_count++;
              logout<<"Error at line# "<<line_count<<": UNRECOGNIZED_CHAR "<<yytext<<"\n";     
}







%%








