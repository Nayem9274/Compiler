%{
#include<iostream>
#include <bits/stdc++.h>
#include<cstdlib>
#include <fstream>
#include<cstring>
#include<string>
#include<cmath>
#include<vector>
#include "SymbolTable.h"
//#include "1905034_SymbolTable.cpp"
//#define YYSTYPE SymbolInfo*

using namespace std;

extern FILE *yyin;

int yyparse(void);
int yylex(void);

extern int line_count;
extern int error_count;
// Bucket size defined
#define BUCKETS 7

ofstream logout;
ofstream errorout;
SymbolTable symbolTable(BUCKETS);


void yyerror(char *s)
{
	//write your code
	//error_count++;
	//logout<<"Error at line no "<<line_count<<" : syntax error"<<endl;
	//errorout<<"Error at line no "<<line_count<<" : syntax error"<<endl;
}


//https://www.geeksforgeeks.org/cpp-string-to-vector-using-delimiter/
//3. Using getline() and stringstream. It works for single-character delimiters.
vector<string> splitString (string str, char delimiter)  
 {  
    vector<string> res;
    stringstream ss(str);
    string token;

    while (getline(ss, token, delimiter)) {
        res.push_back(token);
    }

    return res;
 }

 string getArrayName(string s) {
    int i = 0;
    while (i < s.length() && s[i] != '[') i++;
    return s.substr(0, i);
}

string getArrayLength(string s){
    regex regexp("[0-9]+");
    smatch m;
    regex_search(s, m, regexp);
    return m[0];
 }

 bool isArray(string s){
    regex arr_var("[_A-Za-z][A-Za-z0-9_]*\[[0-9]+\]");
    if(regex_match(s, arr_var)) return true;

    return false;
 }
string current_type;
vector<SymbolInfo> param_list;
set<string> func_processed;



%}

%union{
    SymbolInfo* si;
	 
}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN
%token INCOP DECOP ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON 
%token<si> ADDOP ID MULOP CONST_INT CONST_FLOAT CONST_CHAR RELOP LOGICOP

%type <si> start program unit var_declaration func_declaration func_definition
%type <si> type_specifier parameter_list compound_statement statements statement declaration_list 
%type <si> variable expression_statement expression logic_expression rel_expression simple_expression 
%type <si> factor term unary_expression argument_list arguments


%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program
	{
		//write your code in this block in all the similar blocks below
		// $$ = $1;
         $$ = new SymbolInfo($1 -> getName(), "NON-TERMINAL");
		 logout  << "start: program "  << endl; 
		 symbolTable.PrintAllScopeTable(logout);
	}
	;

program : program unit 
    {
		$$ = new SymbolInfo($1->getName()+""+$2->getName(), "NON-TERMINAL");
        logout  << "program: program unit "  << endl;

    }
	| unit {
		$$ = new SymbolInfo($1->getName(), "NON-TERMINAL");
		logout  << "program: unit " << endl;
	}
	;
	
unit : var_declaration{
	    $$ = new SymbolInfo($1->getName(), "NON-TERMINAL");
		logout << "unit: var_declaration "  << endl;

    }
     | func_declaration{
		 $$ = new SymbolInfo($1->getName(), "FUNC-DECLARE");
         logout<< "unit: func_declaration "  << endl;
	 }
     | func_definition{
		 $$ = new SymbolInfo($1->getName(), "FUNC-DEFINE");
         logout<< "unit: func_definition " << endl;

	 }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN {
         string funcname = $2 -> getName();
		 string datatype = $1 -> getName();
         if(symbolTable.LookUp(funcname) == NULL){
			SymbolInfo* temp = new SymbolInfo(funcname, "ID");
			for(auto i : param_list){
				temp->addFuncParameters(i);
			}
			temp->setSpeciesType("FUNCTION");
			temp->setDataType($1->getName());
			param_list.clear();
			//symbolTable.Insert(funcname,"ID");
			symbolTable.InsertSymbol(temp);//1
		}
        else{
            error_count++;
            //type = "error";
            errorout << "Line# " << line_count << ":  Conflicting types for " << funcname << endl;
            //logout << "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl;
            logout << "Error at line " << line_count << " :  Conflicting types for " << funcname << endl;

        }
}

     SEMICOLON{
           string str = $1 -> getName() + " " + $2 -> getName() + "(" + $4 -> getName() +  ");\n";
           logout << "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl;
		   $$ = new SymbolInfo(str, "FUNCTION");
	       //$$ -> setSpeciesType("FUNCTION");
        
    }
		| type_specifier ID LPAREN RPAREN {
         string funcname = $2 -> getName();
		 string datatype = $1 -> getName();
         if(symbolTable.LookUp(funcname) == NULL){
			SymbolInfo* temp = new SymbolInfo(funcname, "ID");
			temp->setSpeciesType("FUNCTION");
			temp->setDataType($1->getName());
			//symbolTable.Insert(funcname,"ID");
			symbolTable.InsertSymbol(temp);//2
		}
        else{
            error_count++;
            //type = "error";
            errorout << "Line# " << line_count << ":  Conflicting types for " << funcname << endl;
            //logout << "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl;
            logout << "Error at line " << line_count << " :  Conflicting types for " << funcname << endl;

        }
}
 SEMICOLON{
		   string str = $1 -> getName() + " " + $2 -> getName() + "();\n";
           logout << "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl;
		   $$ = new SymbolInfo(str, "FUNCTION");
           //$$ -> setSpeciesType("FUNCTION");
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {
         string funcname = $2 -> getName();
		 string datatype = $1 -> getName();
         if(symbolTable.LookUp(funcname) == NULL){
			SymbolInfo* temp = new SymbolInfo(funcname, "ID");
			for(auto i : param_list){
				temp->addFuncParameters(i);
			}
			temp->setSpeciesType("FUNCTION");
			temp->setDataType($1->getName());
			
			//symbolTable.Insert(funcname,"ID");
			symbolTable.InsertSymbol(temp);//3
		}
        else{
            SymbolInfo* temp = symbolTable.LookUp(funcname);
			cout<<temp->getSpeciesType()<<"[[[[[[[[[[[["<<endl;
            for(auto i : func_processed){
			if(i == funcname){
				error_count++;
				errorout << "Line# " << line_count << ":  Conflicting types for " << funcname << endl;
               logout << "Error at line " << line_count << " :  Conflicting types for " << funcname << endl;
			}
		}
        if(temp->getSpeciesType() != "FUNCTION"){
			cout<<temp->getSpeciesType()<<"[[[[[[[[[[[[]]]]]]]]]]]]]]"<<endl;
			error_count++;
			errorout << "Line# " << line_count << ":  Conflicting types for " << funcname << endl;
            logout << "Error at line " << line_count << " :  Conflicting types for " << funcname << endl;	
		}
        else{
            vector<SymbolInfo> v = temp->getFuncParameters();
			if($1->getName() != temp->getDataType()){
				
                error_count++;
                errorout << "Line " << line_count << ": Return type mismatch with function declaration in function " << $2->getName() << endl;
                //logout << "func_definition: type_specifier ID LPAREN parameter_list RPAREN\n";
                logout << "Error at line no " << line_count << " : Return type mismatch with function declaration in function " << $2->getName() << endl;
                    
				
			}
			if(v.size() != param_list.size()){
                 error_count++;
                 errorout << "Line# " << line_count << ": Total number of arguments mismatch with declaration in function " << $2->getName()<< endl;
                // logout <<  "func_definition: type_specifier ID LPAREN parameter_list RPAREN\n";
                 logout << "Error at line no " << line_count << " : Total number of arguments mismatch with declaration in function " << $2->getName() << endl;
			}

			int size = v.size();
			if(param_list.size() < size){
				size = param_list.size();
			}

			for(int i=0; i<size; i++){
				if(param_list[i].getDataType() != v[i].getDataType()){
                    error_count++;
                    errorout << "Line# " << line_count << ":  Redefinition of parameter " << $2->getName() << endl;
                    //logout << "func_definition: type_specifier ID LPAREN parameter_list RPAREN"<<endl;
                    logout << "Error at line no " << line_count << " :  Redefinition of parameter " << $2->getName()  << endl;
				}
                // th error-> do later
			}
        }

        }
            

    }

     compound_statement{
            logout <<  "func_definition: type_specifier ID LPAREN RPAREN compound_statement"  << endl;
			string str = $1 -> getName() + " " + $2 -> getName() + "()" + $7 -> getName();
			$$ = new SymbolInfo(str, "FUNCTION");
			//$$ -> setSpeciesType("FUNCTION");
            func_processed.insert($2 -> getName());

        }
		| type_specifier ID LPAREN RPAREN{
         string funcname = $2 -> getName();
		 string datatype = $1 -> getName();
         if(symbolTable.LookUp(funcname) == NULL){
			SymbolInfo* temp = new SymbolInfo(funcname, "ID");
			temp->setSpeciesType("FUNCTION");
			temp->setDataType($1->getName());
			
			//symbolTable.Insert(funcname,"ID");
            symbolTable.InsertSymbol(temp);//4
		}
        else{
            SymbolInfo* temp = symbolTable.LookUp(funcname);
			if(temp->getSpeciesType()!="FUNCTION"){
				error_count++;
				errorout << "Line# " << line_count << ":  Conflicting types for " << funcname << endl;
               logout << "Error at line " << line_count << " :  Conflicting types for " << funcname << endl;
			}
		
        }
		
		} compound_statement{
            logout <<  "func_definition: type_specifier ID LPAREN RPAREN compound_statement" << endl;
            string str = $1 -> getName() + " " + $2 -> getName() + "()" + $6 -> getName();
			$$ = new SymbolInfo(str, "FUNCTION");
			//$$ -> setSpeciesType("FUNCTION");
            func_processed.insert($2 -> getName());
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID{
             $$ = new SymbolInfo($1->getName()+","+$3->getName()+" "+$4->getName(), "NON-TERMINAL");
             logout  << "parameter_list: parameter_list COMMA type_specifier ID " << endl;
			 
			 SymbolInfo* temp = new SymbolInfo($4->getName(), $4->getType(),$3 -> getName(),"VAR");
				temp->setSpeciesType("VAR");
				temp->setDataType($3->getName());
				bool found = false;
				for(auto i:param_list){
						if(i.getName() == temp->getName()){
							error_count++;
							       errorout << "Line# " << line_count << ":  Multiple declaration of " << i.getName() <<" in parameter"<< endl;
                                   logout << "Error at line " << line_count << " :  Multiple declaration of " << i.getName()<<" in parameter" << endl;
									found = true;
									break;
								}
						}
				if(found == false){
							param_list.push_back(*temp);
							//symbolTable.InsertSymbol(temp);/////?
					}
							
        }
		| parameter_list COMMA type_specifier{
			 $$ = new SymbolInfo($1->getName()+","+$3->getName(), "NON-TERMINAL");
             logout  << "parameter_list: parameter_list COMMA type_specifier" << endl;
			 SymbolInfo* temp = new SymbolInfo($3->getName(), $3->getType(),$3 -> getName(),"VAR");
			temp->setSpeciesType("VAR");
			temp->setDataType($3->getName());
			param_list.push_back(*temp);
			//symbolTable.InsertSymbol(temp);
		}
 		| type_specifier ID{
			$$ = new SymbolInfo($1->getName()+" "+$2->getName(), "NON-TERMINAL");
            logout  << "parameter_list: type_specifier ID" << endl;
			
			SymbolInfo* temp = new SymbolInfo($2->getName(), $2->getType(),$1 -> getName(),"VAR");
			cout<<temp->getName()<<"wwwwwwwwwwww"<<temp->getDataType()<<endl;
			temp->setSpeciesType("VAR");
			temp->setDataType($1->getName());
			param_list.push_back(*temp);
			//symbolTable.InsertSymbol(temp);
		}
		| type_specifier{
			$$ = new SymbolInfo($1->getName(), "NONTERMINAL");
            logout  << "parameter_list: type_specifier" << endl;
			SymbolInfo* temp = new SymbolInfo($1->getName(), $1->getType(),$1 -> getName(),"VAR");
			temp->setSpeciesType("VAR");
			temp->setDataType($1->getName());
			param_list.push_back(*temp);
		}
		| type_specifier error{
			// In Bison, the yyclearin macro is used to clear the lookahead token. This means that the parser will discard the current token and request a new one the next time it calls the lexer. This is typically used in error recovery scenarios, where the parser needs to discard one or more tokens in order to return to a valid parsing state.
			// The yyerrok macro is used to indicate that an error recovery has been successful, and that the parser should continue parsing normally. 
			yyclearin;
			yyerrok;
			$$ = new SymbolInfo($1->getName(), "error");
            logout << "parameter_list: type_specifier " << endl;
            logout << "Error at line no " << line_count << ": syntax error"  << endl;
			errorout<< "Line# " << line_count <<": Syntax error at parameter list of function definition"<<endl;
		}
 		;

 		
compound_statement : LCURL scope statements RCURL{
             string str = "{\n" + $3 -> getName() + "}\n";
			 $$ = new SymbolInfo(str, "NON-TERMINAL");
			 logout<<"compound_statement: LCURL statements RCURL"<<endl;
			 symbolTable.PrintAllScopeTable(logout);
			 symbolTable.ExitScope();
        }
 		    | LCURL scope RCURL{
			 string str = "{}\n";
			 $$ = new SymbolInfo(str, "NONTERMINAL");
			 logout<<"compound_statement: LCURL RCURL"<<endl;
			 symbolTable.PrintAllScopeTable(logout);
			 symbolTable.ExitScope();
			}
 		    ;
scope:   {
	        symbolTable.EnterScope();
			if(param_list.size() != 0){
						for(auto i : param_list){
								//symbolTable.Insert(i.getName(),i.getType());
								//SymbolInfo *temp=&i;
								SymbolInfo * temp=new SymbolInfo(i.getName(),i.getType(),i.getDataType(),i.getSpeciesType());
								symbolTable.InsertSymbol(temp);//5//sp
						}
					}
						param_list.clear();

}	;		
 		    
var_declaration : type_specifier declaration_list SEMICOLON{
            string str = $1 -> getName() + " " + $2 -> getName() + ";\n"; 
			logout<<"var_declaration : type_specifier declaration_list SEMICOLON"<<endl;
			//vector<string> splitted = splitString($2->getName(), ',');
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			if($1->getName() == "void"){
							error_count++;
				         logout << "Error at line no " << line_count << ":  Variable declared void"  << endl;
			             errorout<< "Line# " << line_count <<":  Variable declared void"<<endl;
					}
			
        }
        |	 error SEMICOLON   {
			//allowing the parser to continue processing the input, while also indicating that an error has occurred.
              yyclearin;
              yyerrok;
              $$ = new SymbolInfo("", "error");
    }
 		 ;
 		 
type_specifier	: INT  { 
            $$ = new SymbolInfo("int", "NON-TERMINAL");
            logout << "type_specifier : INT"<<endl; 
			current_type="int";
    }
 		| FLOAT{ 
            $$ = new SymbolInfo("float", "NON-TERMINAL");
            logout << "type_specifier : FLOAT"<<endl; 
			current_type="float";
    } 
 		| VOID{ 
            $$ = new SymbolInfo("void", "NON-TERMINAL");
            logout << "type_specifier : VOID"<<endl; 
			current_type="void";
    }
 		;
 		
declaration_list : declaration_list COMMA ID{

	        logout<<"declaration_list : declaration_list COMMA ID"<<endl;
			string name = $1 -> getName() + "," + $3 -> getName();
			$$ = new SymbolInfo(name, "NON-TERMINAL");
			SymbolInfo* temp = new SymbolInfo($3->getName(), $3->getType(),current_type,"VAR");// not needes maybe as symbolTABLE INSERTION
			temp->setSpeciesType("VAR");
			temp->setDataType(current_type);
			if(symbolTable.LookUpCurrentScope($3->getName())){
								
								error_count++;
							    errorout << "Line# " << line_count << ":  Multiple declaration of " << $3->getName() << endl;
                                logout << "Error at line " << line_count << " :  Multiple declaration of " << $3->getName() << endl;
				}
			if(current_type != "void"){
								//symbolTable.Insert($3->getName(), $3->getType());
								symbolTable.InsertSymbol(temp);//6
				}
			/*if(symbolTable.LookUp($3 -> getName())){
				    string s= $3-> getName();
					error_count++;			
				    errorout<< "Line# " << line_count << ": Redefinition of parameter " << s << endl;
                   // logout  << "var_declaration : type_specifier declaration_list SEMICOLON";
                    logout << "Error at line " << line_count << ": Redefinition of parameter " << s << endl;
			}*/
				

    }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD{
			   string name = $1 -> getName() + "," + $3 -> getName() + "[" + $5 -> getName() +  "]";
			   $$ = new SymbolInfo(name, "NON-TERMINAL");
			   logout<<"declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD"<<endl;
			   SymbolInfo* temp = new SymbolInfo($3->getName(), $3->getType());
			   temp->setSpeciesType("ARRAY");
			   cout<<"----------------------"<<temp->getSpeciesType()<<endl;
			   temp->setDataType(current_type);
			   if(symbolTable.LookUpCurrentScope($3->getName())){
								
								error_count++;
							    errorout << "Line# " << line_count << ":  Multiple declaration of " << $3->getName() << endl;
                                logout << "Error at line " << line_count << " :  Multiple declaration of " << $3->getName() << endl;
				}
			    if(current_type != "void"){
								//symbolTable.Insert($3->getName(), $3->getType());
								symbolTable.InsertSymbol(temp);//7
				}
			   /*if(!symbolTable.Insert($3 -> getName() , $3->getType())){
				    string s= $3-> getName();
					error_count++;			
				    errorout<< "Line# " << line_count << ": Redefinition of parameter " << s << endl;
                   // logout  << "var_declaration : type_specifier declaration_list SEMICOLON";
                    logout << "Error at line " << line_count << ": Redefinition of parameter " << s << endl;
			}	*/

		  }
 		  | ID{
			string name = $1 -> getName();
			$$ = new SymbolInfo(name, "NON-TERMINAL");
			logout<<"declaration_list : ID"<<endl;
			SymbolInfo* temp = new SymbolInfo($1->getName(), $1->getType());
			temp->setSpeciesType("VAR");
			temp->setDataType(current_type);
			if(symbolTable.LookUpCurrentScope($1->getName())){
								
								error_count++;
							    errorout << "Line# " << line_count << ":  Multiple declaration of " << $1->getName() << endl;
                                logout << "Error at line " << line_count << " :  Multiple declaration of " << $1->getName() << endl;
				}
			if(current_type != "void"){
								//symbolTable.Insert($1->getName(), $1->getType());
								symbolTable.InsertSymbol(temp);//8
				}
			   /*if(symbolTable.LookUp($1 -> getName())){
				    string s= $1-> getName();
					error_count++;			
				    errorout<< "Line# " << line_count << ": Redefinition of parameter " << s << endl;
                   // logout  << "var_declaration : type_specifier declaration_list SEMICOLON";
                    logout << "Error at line " << line_count << ": Redefinition of parameter " << s << endl;
			}	*/

		  }
 		  | ID LTHIRD CONST_INT RTHIRD{
			string name = $1 -> getName() + "[" +  $3 -> getName()  + "]";
			$$ = new SymbolInfo(name, "NON-TERMINAL");
			logout<<"declaration_list : ID LTHIRD CONST_INT RTHIRD"<<endl;
			SymbolInfo* temp = new SymbolInfo($1->getName(), $1->getType());
			temp->setSpeciesType("ARRAY");
			temp->setDataType(current_type);
			if(symbolTable.LookUpCurrentScope($1->getName())){
								
								error_count++;
							    errorout << "Line# " << line_count << ":  Multiple declaration of " << $1->getName() << endl;
                                logout << "Error at line " << line_count << " :  Multiple declaration of " << $1->getName() << endl;
				}
			if(current_type != "void"){
								//symbolTable.Insert($1->getName(), $1->getType());
								symbolTable.InsertSymbol(temp);//9
				}
			cout<<temp->getSpeciesType()<<"----------------"<<endl;	
			   /*if(!symbolTable.Insert($1 -> getName() , $1->getType())){
				    string s= $3-> getName();
					error_count++;			
				    errorout<< "Line# " << line_count << ": Redefinition of parameter " << s << endl;
                   // logout  << "var_declaration : type_specifier declaration_list SEMICOLON";
                    logout << "Error at line " << line_count << ": Redefinition of parameter " << s << endl;
			}	*/
		  }
		 |declaration_list error {
                yyclearin;
				/////////////////////////////////////////////////////yyerrok hobe naki sure na? pore dekhbo
			    yyerrok;
			    $$ = new SymbolInfo($1->getName(), "error");
				///////////////////////////////????
                logout << "declaration_list: ID " << endl;
                logout << "Error at line no " << line_count << ": syntax error"  << endl;
			    errorout<< "Line# " << line_count <<": Syntax error at at declaration list of variable declaration"<<endl;
                 
    }
 		  ;
 		  
statements : statement{
	      if($1 -> getName() != "") {
			   string name = $1 -> getName();
		       logout << "statements : statement" << endl;
			   $$ = new SymbolInfo(name, "NON-TERMINAL");
			} else {
               $$ = new SymbolInfo("", "");
			}

    }
	   | statements statement{
		    string name = $1 -> getName() + "" + $2 -> getName();
		    logout << "statements : statements statement" << endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
	   }
	   ;
	   
statement : var_declaration {
		    string name = $1 -> getName() ;
		    logout << "statement : var_declaration" << endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
	   }
	  | expression_statement{
		    string name = $1 -> getName() ;
		    logout << "statement : expression_statement" << endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
	   } 
	  | compound_statement{
		    string name = $1 -> getName() ;
		    logout << "statement : compound_statement" << endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
	   }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement{
		    string name = "for(" + $3->getName() + "" + $4->getName() + "" + $5 -> getName() + ")" + $7 -> getName(); ;
		    logout << "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement" << endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
	   }
	  | IF LPAREN expression RPAREN statement  %prec LOWER_THAN_ELSE{
		    string name = "if (" + $3 -> getName() + ")" + $5 -> getName() ;
		    logout << "statement : IF LPAREN expression RPAREN statement" << endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
	   }
	  | IF LPAREN expression RPAREN statement ELSE statement{
		    string name = "if (" + $3 -> getName() + ")" + $5 -> getName() + "else\n" + $7 -> getName() ;
		    logout << "statement : IF LPAREN expression RPAREN statement ELSE statement" << endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
	   }
	  | WHILE LPAREN expression RPAREN statement{
		    string name =  "while (" + $3 -> getName() + ")" + $5 -> getName();
		    logout << "statement : WHILE LPAREN expression RPAREN statement" << endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
	   }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON{
		    string name =  "printf(" + $3 -> getName() + ");\n" ;
		    SymbolInfo* var  = symbolTable.LookUp($3->getName());
           if(var == NULL){
            error_count++;
            errorout<< "Line# " << line_count << ": Undeclared variable " << $3->getName() << endl;
            logout << "statement: PRINTLN LPAREN ID RPAREN SEMICOLON"<<endl;
            logout << "Error at line no " << line_count << " : Undeclared variable " << $3->getName() << endl;
        }  else{
            logout <<  "statement: PRINTLN LPAREN ID RPAREN SEMICOLON"<<endl;
        }
			$$ = new SymbolInfo(name, "NON-TERMINAL");
	   }
	  | RETURN expression SEMICOLON{
		    string name =  "return " + $2 -> getName() + ";\n" ;
		    logout << "statement : RETURN expression SEMICOLON" << endl;
			$$ = new SymbolInfo(name,"NON-TERMINAL" );
			if($2->getDataType()=="void")
			{
				error_count++;
            errorout<< "Line# " << line_count << ": Return type void "  << endl;
            //logout << "statement: PRINTLN LPAREN ID RPAREN SEMICOLON"<<endl;
            logout << "Error at line no " << line_count << " : Return type void"  << endl;
			}
			////// should i catch return "void " error? will see later ///////////////
	   }
	  ;
	  
expression_statement 	: SEMICOLON	{
        $$ = new SymbolInfo(";\n", "NON-TERMINAL");
        logout  << "expression_statement : SEMICOLON"<<endl;
    }		
			| expression SEMICOLON {
        $$ = new SymbolInfo( $1 -> getName() + ";\n", "expression_statement");
        logout  << "expression_statement : expression SEMICOLON"<<endl;
    }		
	| expression error  {
        yyclearin;
        $$ = new SymbolInfo("", "error");
    }
			;
	  
variable : ID {
        SymbolInfo* var = symbolTable.LookUp($1->getName());

        if(var == NULL){
            error_count++;
            errorout << "Line# " << line_count << ": Undeclared variable " << $1->getName() << endl;
            logout << "variable : ID"<<endl;
            logout << "Error at line no " << line_count << " : Undeclared variable " << $1->getName() << endl;
            $$ = new SymbolInfo($1->getName(), "NON-TERMINAL","none","VAR");
			$$->setSpeciesType("VAR");
			$$->setDataType("none");
        }else{
			if(var->getSpeciesType()=="ARRAY")
			{
			error_count++;
            errorout << "Line# " << line_count << ": Type mismatch, " << $1->getName() << " is an array" << endl;
            logout<< "variable : ID"<<endl; 
            logout << "Error at line no " << line_count << ":  Type mismatch, " << $1->getName() << " is an array" << endl;

			}
            logout <<"variable : ID" << endl;
			cout<<var->getName()<<"ooooooooooooo"<<var->getDataType()<<endl;
            //$$ = var;///////////////// 
			$$=new SymbolInfo($1->getName(),"NON-TERMINAL",$1->getDataType(),$1->getSpeciesType());
			$$ = var;
        }
    }		
	 | ID LTHIRD expression RTHIRD { 
		string str = $1 -> getName() + "[" + $3 -> getName() + "]";
        SymbolInfo* var = symbolTable.LookUp($1->getName());//$1->getName()
		cout<<var->getSpeciesType()<<"///////////////////////"<<var->getName()<<var->getType()<<"/////////////////////////////"<<var->getDataType()<<endl;
        if(var == NULL){
            error_count++;
            errorout << "Line# " << line_count << ": Undeclared variable " << $1->getName() << endl;
            logout << "variable : ID LTHIRD expression RTHIRD"<<endl; 
            logout << "Error at line no " << line_count << " : Undeclared variable " << $1->getName() << endl;
            $$ = new SymbolInfo($1 -> getName(), "ARRAY","none","ARRAY");
			$$->setSpeciesType("ARRAY");
			$$->setDataType("none");
        }else{
			cout<<var->getSpeciesType()<<"////////////////////////////////////////////////////"<<var->getDataType()<<endl;
            if(var->getSpeciesType() != "ARRAY"){
                error_count++;
                errorout << "Line# " << line_count << ": " << $1->getName() << " is not an array"<<endl;
                logout << "variable : ID LTHIRD expression RTHIRD"<<endl; 
                logout << "Error at line no " << line_count << " : " << $1->getName() << " is not an array"<<endl;  
            }
			 $$ = new SymbolInfo(str, "NON-TERMINAL",var->getDataType(),"ARRAY");
			 $$->setSpeciesType("ARRAY");
			 $$->setDataType(var->getDataType());
			if($3->getType()== "float"){
                error_count++;
                errorout << "Line# " << line_count << ": Expression inside third brackets not an integer" << endl;
                logout <<  "variable : ID LTHIRD expression RTHIRD"<<endl; 
                logout << "Error at line no " << line_count << " : Expression inside third brackets not an integer" << endl;
            }
        }
    }
	 ;
	 
 expression : logic_expression	{
	        string name = $1 -> getName();
			logout <<  "expression : logic_expression"<<endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL",$1 -> getDataType(),"VAL");
			$$ = $1;
 }
	   | variable ASSIGNOP logic_expression {
	        string name =  $1 -> getName() + "=" + $3 -> getName();
			//SymbolInfo* var = symbolTable.LookUp($1->getName());
			logout <<  "variable ASSIGNOP logic_expression"<<endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
			cout<<$1->getDataType()<<"kkkkkkkkkkkkkkk"<<$3->getDataType()<<endl;
			if($1->getDataType()=="none" || $3->getDataType()=="none") {}
			if($1->getDataType()=="void" || $3->getDataType()=="void")
			{
				    error_count++;
                   errorout << "line# " << line_count << ": Void function used in expression\n";
                   //logout <<  "expression : variable ASSIGNOP logic_expression"<<endl;
                   logout << "Error at line no " << line_count << " : Void function used in expression\n";
			}
			else if(($1->getDataType()!= $3->getDataType()) && $1->getDataType()!="float")
			{
				error_count++;
                errorout << "Line# " << line_count << ": Type mismatch"<<endl;
                //logout <<  "expression : variable ASSIGNOP logic_expression\n";
                logout << "Error at line no " << line_count << " : Type mismatch\n";

			}

 }	
	   ;
			
logic_expression : rel_expression 	{
	        string name = $1 -> getName();
			logout <<  "logic_expression : rel_expression"<<endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL",$1 -> getDataType(),"VAL");
			$$ = $1;
}
		 | rel_expression LOGICOP rel_expression{
			$$ = new SymbolInfo($1 -> getName() + "" + $2 -> getName() + "" + $3 -> getName(), "NON-TERMINAL","int","");
			logout <<  "logic_expression : rel_expression LOGICOP rel_expression"<<endl;
			$$ -> setDataType("int");
			if($1->getDataType()=="void" || $3->getDataType()=="void")
			{
				    error_count++;
                   errorout << "line# " << line_count << ": Void function used in expression\n";
                   logout << "Error at line no " << line_count << " : Void function used in expression\n";
			}
		 } 	
		 ;
			
rel_expression	: simple_expression {
	        string name = $1 -> getName();
			logout <<  "rel_expression	: simple_expression"<<endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL",$1 -> getDataType(),"VAL");
			$$ = $1;
}
		| simple_expression RELOP simple_expression	{

			 logout <<  "rel_expression : simple_expression RELOP simple_expression"<<endl;
			 $$ = new SymbolInfo($1->getName()+""+$2->getName()+""+$3->getName(), "NON-TERMINAL","int","");
			 $$ -> setDataType("int");
			 if($1->getDataType()=="void" || $3->getDataType()=="void")
			{
				    error_count++;
                   errorout << "line# " << line_count << ": Void function used in expression\n";
                   //logout <<  "expression : variable ASSIGNOP logic_expression"<<endl;
                   logout << "Error at line no " << line_count << " : Void function used in expression\n";
			}
		}
		;
				
simple_expression : term  {
	        string name = $1 -> getName();
			logout <<  "simple_expression : term"<<endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL",$1 -> getDataType(),"VAL");
			$$ = $1;
}
		  | simple_expression ADDOP term {
			 //$$ = new SymbolInfo($1 -> getName() + "" + $2 -> getName() + "" + $3 -> getName(), "NON-TERMINAL");
			 logout <<"simple_expression : simple_expression ADDOP term" <<endl;

			 if($1->getDataType()=="void" || $3->getDataType()=="void")
			{
				    $$ = new SymbolInfo($1 -> getName() + "" + $2 -> getName() + "" + $3 -> getName(), "NON-TERMINAL");
				    error_count++;
                   errorout << "line# " << line_count << ": Void function used in expression\n";
                   //logout <<  "expression : variable ASSIGNOP logic_expression"<<endl;
                   logout << "Error at line no " << line_count << " : Void function used in expression\n";
			}

            else if($1->getDataType()=="float" || $3->getDataType()=="float")
		{ 
			$$ = new SymbolInfo($1 -> getName() + "" + $2 -> getName() + "" + $3 -> getName(), "NON-TERMINAL","float","");
			$$ -> setDataType("float");

		}
		 else if($1->getDataType()=="int" || $3->getDataType()=="int")
		{ 
			$$ = new SymbolInfo($1 -> getName() + "" + $2 -> getName() + "" + $3 -> getName(), "NON-TERMINAL","int","");
			$$ -> setDataType("int");

		}
           
		  }
		  ;
					
term :	unary_expression {
	        string name = $1 -> getName();
			logout <<  "term : unary_expression"<<endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL",$1 -> getDataType(),"VAL");
			$$ = $1;
}
     |  term MULOP unary_expression {
		logout <<"term : term MULOP unary_expression" <<endl;
		 //$$ = new SymbolInfo($1->getName()+""+$2->getName()+""+$3->getName(), "NON-TERMINAL");

		 if($1->getDataType()=="void" || $3->getDataType()=="void")
			{
				   $$ = new SymbolInfo($1->getName()+""+$2->getName()+""+$3->getName(), "NON-TERMINAL");
				    error_count++;
                   errorout << "line# " << line_count << ": Void function used in expression\n";
                   //logout <<  "expression : variable ASSIGNOP logic_expression"<<endl;
                   logout << "Error at line no " << line_count << " : Void function used in expression\n";
			}
		if($2->getName() == "%")	
		{
			if($1->getDataType()!="int" || $3->getDataType()!="int")
			{
				 error_count++; 
			    //$$ = new SymbolInfo($1->getName()+""+$2->getName()+""+$3->getName(), "error");
                errorout << "Line# " << line_count << ": Non-Integer operand on modulus operator" << endl;
            //logout << "term : term MULOP unary_expression"<<endl;
               logout << "Error at line no " << line_count << " : Non-Integer operand on modulus operator" << endl;
			}
			if( $3 ->getName()=="0")
		    {
			    error_count++;
               errorout << "line# " << line_count << ": Warning: division by zero i=0f=1Const=0\n";
               logout << "Error at line no " << line_count << " : Warning: division by zero i=0f=1Const=0\n";
			}
			$$ = new SymbolInfo($1->getName()+""+$2->getName()+""+$3->getName(), "NON-TERMINAL","int","");	
			$$->setDataType("int");
		}
		else{
			cout<<$1->getDataType()<<",,,,,,,,,,,,,,,,,,,,,,,"<<$3->getDataType()<<endl;
			if($1->getDataType()=="int" || $3->getDataType()=="int") {
				$$ = new SymbolInfo($1->getName()+""+$2->getName()+""+$3->getName(), "NON-TERMINAL","int","");
				$$->setDataType("int");}
			else {
				$$ = new SymbolInfo($1->getName()+""+$2->getName()+""+$3->getName(), "NON-TERMINAL","float","");
				$$->setDataType("float");
			}
		}  
		  }
     ;
// 28th JANUARY 8:00 PM//////////////////////////////////////////////////
unary_expression : ADDOP unary_expression  {
	        string name =$1 -> getName() + "" + $2 -> getName();
			logout <<  "unary_expression : ADDOP unary_expression"<<endl;
			$$ = new SymbolInfo(name,"NON-TERMINAL",$2 -> getDataType(),"");
            $$ -> setDataType($2 -> getDataType());
}
		 | NOT unary_expression {
	        string name ="!" + $2 -> getName();
			logout <<  "unary_expression : NOT unary_expression"<<endl;
			$$ = new SymbolInfo(name,"NON-TERMINAL",$2 -> getDataType(),"");
            $$ -> setDataType($2 -> getDataType());
}
		 | factor  {
	        string name = $1 -> getName();
			logout <<  "unary_expression : factor"<<endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL",$1 -> getDataType(),"VAL");
			$$ = $1;
}
		 ;
	
factor	: variable {
	        string name = $1 -> getName();
			logout <<  "factor : variable "<<endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL",$1 -> getDataType(),"VAL");
			$$ = $1;
			cout<<$1->getName()<<">>"<<$1 -> getDataType()<<endl;
}
	| ID LPAREN argument_list RPAREN {
		logout <<  "factor : ID LPAREN argument_list RPAREN"<<endl;
		//$$ = new SymbolInfo($1->getName()+"("+$3->getName()+")", "NON-TERMINAL");
        SymbolInfo* var = symbolTable.LookUp($1->getName());
       
		 if(var == NULL){
			$$ = new SymbolInfo($1->getName()+"("+$3->getName()+")", "NON-TERMINAL");
            error_count++;
            errorout << "Line# " << line_count << ": Undeclared function " << $1->getName() << endl;
           // logout << "factor : ID LPAREN argument_list RPAREN"<<endl; 
            logout << "Error at line no " << line_count << " : Undeclared function " << $1->getName() << endl;
			param_list.clear();
           
        }
		
		else{
			vector<SymbolInfo> parameters = var->getFuncParameters();
			// Comapre for mismatch of arguments
			 if(parameters.size() != param_list.size())
			 {
                error_count++;
                errorout << "Line# " << line_count << ": Total number of arguments mismatch in function " << $1->getName() << endl; 
               logout << "Error at line no " << line_count << " : Total number of arguments mismatch in function " << $1->getName() << endl;
			 }

			/* for (int i = 0; i < min(parameters.size(), param_list.size()); i++) {
                       if ((parameters[i].getDataType()!= param_list[i].getDataType()) &&
                    (parameters[i].getDataType() != "float" || param_list[i].getDataType() != "int")) {
						        error_count++;
                                errorout << "Line# " << line_count << ": " << (i+1) << "th argument mismatch in function " << $1->getName() << endl;
                               logout << "Error at line  no " << line_count << ": " << (i+1) << "th argument mismatch in function " << $1->getName() << endl;
                               break;
                        }
                  } */
				  for (int i = 0; i < min(parameters.size(), param_list.size()); i++) {
                       if (parameters[i].getDataType()!= param_list[i].getDataType())
					   {
						 cout<<parameters[i].getDataType()<<"/?????"<<param_list[i].getDataType()<<endl;
						  if(parameters[i].getDataType() == "float" && param_list[i].getDataType() == "int") {;}
						  else {
							error_count++;
                                errorout << "Line# " << line_count << ": " << (i+1) << "th argument mismatch in function " << $1->getName() << endl;
                               logout << "Error at line  no " << line_count << ": " << (i+1) << "th argument mismatch in function " << $1->getName() << endl;
                               break;
						  }

					   }

				  }
				  param_list.clear();
				  $$ = new SymbolInfo($1->getName()+"("+$3->getName()+")", "NON-TERMINAL",var->getDataType(),"");
				  $$->setDataType(var->getDataType());
        }

	}

	
	| LPAREN expression RPAREN
	{
		    string name = "(" + $2 -> getName() + ")";
			logout << "factor : LPAREN expression RPAREN"<<endl; 
			$$ = new SymbolInfo(name, "NON-TERMINAL",$2 -> getDataType(),"");
			$$ -> setDataType($2 -> getDataType());
	}
	| CONST_INT 
	{
		    string  name = $1 -> getName();
			logout << "factor : CONST_INT"<<endl; 
			$$ = new SymbolInfo(name, "NON-TERMINAL","int","VAL");
			//$$ -> setDataType("int");
			//$$->setSpeciesType("VAL");//value
		
	}
	| CONST_FLOAT
	{
        string  name = $1 -> getName();
			logout << "factor : CONST_FLOAT"<<endl; 
			$$ = new SymbolInfo(name, "NON-TERMINAL","float","VAL");
			//$$ -> setDataType("float");
			//$$->setSpeciesType("VAL");//value
	}
	| variable INCOP 
	{
        $$ = new SymbolInfo($1->getName()+"++", "NON-TERMINAL");
		logout << "factor : variable INCOP"<<endl; 
	}
	| variable DECOP
	{
        $$ = new SymbolInfo($1->getName()+"--", $1->getType());
		logout << "factor : variable DECOP"<<endl; 
	}
	;
	
argument_list : arguments {
	        string name = $1 -> getName();
			logout <<  "argument_list : arguments"<<endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
			$$ = $1;
}
			  | {
	        string name = " ";
			logout <<  "argument_list : "<<endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
}
			  ;
	
arguments : arguments COMMA logic_expression {
	        string name =  $1 -> getName() + "," + $3 -> getName();
			logout <<  "arguments : arguments COMMA logic_expression"<<endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
			param_list.push_back(*$3);
}
	      | logic_expression  {
			string name = $1 -> getName();
			logout <<  "arguments : logic_expression"<<endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");//////
			$$ = $1;
			param_list.push_back(*$1);
}
		  
	      ;
 

%%
int main(int argc,char *argv[])
{

     if (argc != 2) {
        cout << "Please provide the  input file name and try again" << endl;
        return 0;
    }

	FILE* f = fopen(argv[1], "r");

	if (f == NULL) {
        cout << "Cannot open given file" << endl;
        return 0;
    }


    logout.open("1905034_log.txt");
    errorout.open("1905034_error.txt");
	//logout.open("1905034_log_no.txt");
    //errorout.open("1905034_error_no.txt");
	yyin=f;
	yyparse();
	fclose(yyin);
    symbolTable.PrintAllScopeTable(logout);
    logout << endl;
    logout << "Total lines: " << line_count << endl;
    logout << "Total errors: " << error_count << endl;

	
     logout.close();
     errorout.close();
	
	return 0;
}

