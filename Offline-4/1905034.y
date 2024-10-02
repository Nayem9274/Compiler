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
ofstream outputcode;
ofstream optcode;
SymbolTable symbolTable(BUCKETS);




void yyerror(char *s)
{
	//write your code
	error_count++;
	logout<<"Error at line no "<<line_count<<" : syntax error"<<endl;
	errorout<<"Error at line no "<<line_count<<" : syntax error"<<endl;
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


string current_type;
vector<SymbolInfo> param_list;
set<string> func_processed;
vector <SymbolInfo> assem_var_param_list;
vector <string> available_param_list;
set <string> available_assem_var_param_list;
string assemCode, optimized_assemCode;
int label= 0;
vector<vector<string>> var_assem_arguments;
set<string> temps_for_efficient_code;
string scoped_func;

set<string> dataSegment;
set<pair<string, string>> arraySegment;

string newLabel() {
    label++;
    return "L_" + to_string(label);
}

// The purpose of this function is to generate a unique temporary variable name each time it is called. It uses a set temps_for_efficient_code to keep track of the names that have already been used to ensure uniqueness.
string newTemp() {
    int tempCount = 1;
    while (true) {
        string temp = "TMP_" + to_string(tempCount);
        if(temps_for_efficient_code.find(temp) == temps_for_efficient_code.end()) {
            temps_for_efficient_code.insert(temp);
            available_assem_var_param_list.insert(temp);
            dataSegment.insert(temp);
            return temp;
        }
        tempCount++;
    }
}
//The function takes a variable number of arguments of any type, and all arguments are expected to be strings.
//The ellipsis ... in the parameter list indicates that the function accepts a variable number of arguments. The Strings parameter pack is used to capture the types of the arguments.
//This function is used to delete temporary variables or parameters for  assembly code generation and optimization process.

template<typename ...Strings>
void delete_temp_for_efficient_code(Strings... strings) {
    string args[] { strings... };
    for(auto &temp: args) {
        temps_for_efficient_code.erase(temp);
        available_assem_var_param_list.erase(temp);
    }
}

string printDataSegment() {
    string segment = "";
    for (auto data : dataSegment) {
        segment += data + " DW '?'\n";
    }
    return segment;
}

string printArraySegment() {
    string segment = "";
    for (auto arr : arraySegment) {
        segment += arr.first + " DW DUP " + arr.second + "(?)\n";
    }
    return segment;
}

/*
Print.asm- Implementation of a subroutine called PRINTLN that prints an integer to the console followed by a newline character.
The procedure starts by saving the registers AX, BX, CX, DX, and BP onto the stack, which is a common practice in x86 assembly language programming. Then it sets up the stack frame by moving the stack pointer into the base pointer register BP. The input argument is stored in the memory location [BP + 12], which is 2 words (4 bytes) away from the base pointer. The value is loaded into register AX.
The next block(TEST AX,8000H) checks if the input value is negative. It does this by testing the most significant bit (bit 15) of the value in AX. If the bit is set (i.e., the value is negative), the program branches to PRINTLN_HELPER. Otherwise, it continues to the next block of code.
If the value is negative, the program first stores the original value in CX and then prints a minus sign using the DOS interrupt INT 21H with the function code 2 in the AH register and the ASCII code for the minus sign (45) in the DL register. Finally, it restores the original value in AX.
The PRINTLN_HELPER label is used to jump to this block of code if the input value is negative. Here, the CX register is initialized to 0, which will be used to count the number of digits in the absolute value of the input value.
This block (while) of code calculates the absolute value of the input value and pushes each digit onto the stack. It does this by repeatedly dividing the input value by 10 (using the DIVIDE_HELPER subroutine) and taking the remainder (which is a single digit). The ABS_HELPER subroutine is called to convert the remainder to its absolute value (in case it's negative) before pushing it onto the stack. The loop continues until the input value is reduced to zero.
This block(GO) of code pops each digit off the stack and prints it to the console using the DOS interrupt INT 21H with the function code 2 in the AH register and the ASCII code for the digit (which is calculated by adding the digit to 48) in the DL register. The loop continues until all digits have been printed.

Why mov BP,SP ?
When a function is called, the stack is used to allocate space for local variables and to preserve the current state of the CPU (registers) before executing the function code. The base pointer (BP) is typically used as a frame pointer to reference these local variables relative to the current stack frame.
By loading the current stack pointer (SP) into the base pointer (BP), the programmer is establishing a reference point for local variables within the current function's stack frame. This allows for easy access to local variables and parameters within the function, as they can be referenced as offsets from the base pointer (BP).
Overall, using the base pointer (BP) as a frame pointer helps to organize and manage the stack memory for function calls, making it easier to read and write assembly code.

*/
string procedure_PRINTLN() {
    string print = "";
    ifstream p("Print.asm");
    string str;
    while(getline(p, str)) {
        print += str;
    }
    p.close();
    return print;
}

void printAssemblyCode(string code) {
    string str = ".MODEL SMALL\n.STACK 1000H\n\n.DATA\n";
    str += printDataSegment() + "\n" + printArraySegment() + "\n.CODE\n" + code;
    str += procedure_PRINTLN() + "\n\n\nEND MAIN\n";
    outputcode << str;
}

string annotateAssembly(string comment, string assembly) {
    for(auto &com: comment) {
        if(com == '\n' || com == ';') {
            com = ' ';
        }
    }
    return "\n;" + comment + "\n" + assembly;
}
/*
In this code, the first optimization(1) is used to identify the redundant operations, and the second optimization(2) is used to remove the redundant operations. 
The redundant operations are stored in a set of integers called "unoptimized_lines". The line numbers to be deleted are inserted into the set.
*/
void PeepholeOptimization(string fileName) {
    ifstream optimization_1(fileName);
    string prev_line, current_line;
    int lineCount = 0;
    set<int> unoptimized_lines;// Track of unoptimized lines to be deleted

    while(getline(optimization_1, current_line)) {
        if(current_line == "\n" || current_line == "" || current_line.find(";") == 0) {
            ;
        } else {
            lineCount++;
        }

        if(current_line.find("MOV") != string::npos && prev_line.find("MOV") != string::npos) {
            string operands_prev = prev_line.substr(prev_line.find(" ") + 1);
            string operands_curr = current_line.substr(current_line.find(" ") + 1);
            if(operands_prev.find(",") != string::npos && operands_curr.find(",") != string::npos) {
                string prev_operand1 = operands_prev.substr(0, operands_prev.find(","));
                string prev_operand2 = operands_prev.substr(operands_prev.find(",") + 2);  //  space here
                string curr_operand1 = operands_curr.substr(0, operands_curr.find(","));
                string curr_operand2 = operands_curr.substr(operands_curr.find(",") + 2);  //  space here
                if((prev_operand1 == curr_operand1 && prev_operand2 == curr_operand2)
                  || (prev_operand1 == curr_operand2 && prev_operand2 == curr_operand1)) {
                    unoptimized_lines.insert(lineCount);
                }
            }
        } else if(current_line.find("POP") != string::npos && prev_line.find("PUSH") != string::npos) {
            string prev_operand = prev_line.substr(prev_line.find(" ") + 1);
            string curr_operand = current_line.substr(current_line.find(" ") + 1);
            if(prev_operand == curr_operand) {
                unoptimized_lines.insert(lineCount - 1);
                unoptimized_lines.insert(lineCount);
            }
        }

        if(current_line == "\n" || current_line == "" || current_line.find(";") == 0) {
            ;
        } else {
            prev_line = current_line;
        }
    }
    optimization_1.close();

	/*
	In the second optimization(2), the code iterates through the assembly code, and if the line number is not present in the "unoptimized_lines" set,
	then that line is added to the "optimized_asmCode". If the line number is present in the set, then that line is added to the 
	"optimized_asmCode" with a "peephole" comment[that is, it is an unoptimized line].
	*/

    ifstream optimization_2(fileName);
    lineCount = 0;

    while(getline(optimization_2, current_line)) {
        if(current_line == "\n" || current_line == "" || current_line.find(";") == 0) {
            ;
        } else {
            lineCount++;
        }
        if(unoptimized_lines.find(lineCount) == unoptimized_lines.end()) {
            optimized_assemCode += current_line + "\n";
        } else {
            optimized_assemCode += "; " + current_line + "\tPEEPHOLE_OPTIMIZATION\n";
        }
    }
    optimization_2.close();

    optcode << optimized_assemCode;
}

void ExtraOptimization(string file_name){


}

void gen(string assemblycode)
{
	cout<< assemblycode << "\t";

}

void genln(string assemblycode)
{
	gen(assemblycode);
	cout<<endl;
}


void printOptimizedAssemblyCode() {
    
    PeepholeOptimization("code.asm");
    //ExtraOptimization("optimized_code.asm");
}


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
		 $$ -> setAssemCode($$ -> getAssemCode() + $1 -> getAssemCode());
		 printAssemblyCode($$ -> getAssemCode());
		 printOptimizedAssemblyCode();
		 logout  << "start: program "  << endl; 
		 symbolTable.PrintAllScopeTable(logout);
	}
	;

program : program unit 
    {
		$$ = new SymbolInfo($1->getName()+""+$2->getName(), "NON-TERMINAL");
        $$ -> setAssemCode($$ -> getAssemCode() + $1 -> getAssemCode() + $2 -> getAssemCode());
		logout  << "program: program unit "  << endl;


    }
	| unit {
		$$ = new SymbolInfo($1->getName(), "NON-TERMINAL");
		$$ -> setAssemCode($$ -> getAssemCode() + $1 -> getAssemCode());
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
		 $$ -> setAssemCode($$ -> getAssemCode() + $1 -> getAssemCode());

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
		 scoped_func=funcname; // @@##
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
			int offset = $1 -> getName() == "void" ? 14 : 16;
			string funcName = $2 -> getName();
            assemCode = $$ -> getAssemCode() + funcName + " PROC\n";
			assemCode += "PUSH AX\nPUSH BX\nPUSH CX\nPUSH DX\nPUSH BP\nPUSH SI\nMOV BP, SP\n";

			int no_of_parameters = available_param_list.size() - 1;
			int c = 0;
			for(int i = no_of_parameters; i >= 0; i--) {
				string p = available_param_list[i];
                assemCode += "MOV AX, WORD PTR[BP + " + to_string(offset + c*2) + "]\nMOV " + p + ", AX\n";
			    c++;
            }

			assemCode += $7 -> getAssemCode();

            if($1 -> getName() == "void") {
				assemCode += "POP SI\nPOP BP\nPOP DX\nPOP CX\nPOP BX\nPOP AX\nRET 0\n\n";
			}

			assemCode += funcName + " ENDP\n\n";
			gen(assemCode);
			$$ -> setAssemCode(assemCode);
			available_param_list.clear();
			available_assem_var_param_list.clear();

        }
		| type_specifier ID LPAREN RPAREN{
         string funcname = $2 -> getName();
		 string datatype = $1 -> getName();
		 scoped_func=funcname;//@@##
         if(symbolTable.LookUp(funcname) == NULL){
			SymbolInfo* temp = new SymbolInfo(funcname, "ID");
			temp->setSpeciesType("FUNCTION");
			temp->setDataType($1->getName());
			
			//symbolTable.Insert(funcname,"ID");
            symbolTable.InsertSymbol(temp);//4
			available_param_list.clear(); //@@##
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
			string funcName = $2 -> getName();
			assemCode = funcName + " PROC\n";

            if(funcName == "main") {
				assemCode += "\nMOV AX, @DATA\nMOV DS, AX\n";
			} else {
				assemCode += "PUSH AX\nPUSH BX\nPUSH CX\nPUSH DX\nPUSH BP\nPUSH SI\nMOV BP, SP\n";
			}

			int no_of_parameters = available_param_list.size() - 1;
			int c = 0;
			for(int i = no_of_parameters; i >= 0; i--) {
				string p = available_param_list[i];
                assemCode += "MOV AX, WORD PTR[BP + " + to_string(14 + c*2) + "]\nMOV " + p + ", AX\n";
			    c++;
            }

			assemCode += $6 -> getAssemCode();

            if(funcName == "main") {
				assemCode += "\nMOV AH, 4CH\nINT 21H\n";
			} else if($1 -> getName() == "void") {
				assemCode += "POP SI\nPOP BP\nPOP DX\nPOP CX\nPOP BX\nPOP AX\nRET 0\n";
			}

			assemCode += funcName + " ENDP\n\n";    
			gen(assemCode);
			$$ -> setAssemCode(assemCode);
			available_param_list.clear();
			available_assem_var_param_list.clear();

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
			 $$ -> setAssemCode($$ -> getAssemCode() + $3 -> getAssemCode());
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
								string k=to_string(symbolTable.getId());//@@##
								available_param_list.push_back(i.getName()+""+k);//@@##
								dataSegment.insert(temp->getVarAssem());//@@##
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
			else {
                    for(auto i :assem_var_param_list)
					{
						string k=to_string(symbolTable.getId());//@@##
						available_assem_var_param_list.insert(i.getName()+""+k);//@@##
					}

			}		
			assem_var_param_list.clear();
			
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
				else {
					SymbolInfo* p= new SymbolInfo($3->getName(), $3->getType());//@@##
					assem_var_param_list.push_back(*p);//@@##
				}
			if(current_type != "void"){
								//symbolTable.Insert($3->getName(), $3->getType());
								symbolTable.InsertSymbol(temp);//6
								dataSegment.insert(temp->getVarAssem());//@@##
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
				else {
					SymbolInfo* p= new SymbolInfo($3->getName(), $3->getType());//@@##
					assem_var_param_list.push_back(*p);//@@##
				}
			    if(current_type != "void"){
								//symbolTable.Insert($3->getName(), $3->getType());
								symbolTable.InsertSymbol(temp);//7
								dataSegment.insert(temp->getVarAssem());//@@##
				}
				arraySegment.insert(make_pair($3 -> getName(), $5 -> getName()));


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
			else {
					SymbolInfo* p= new SymbolInfo($1->getName(), $1->getType());//@@##
					assem_var_param_list.push_back(*p);//@@##
				}	
			if(current_type != "void"){
								//symbolTable.Insert($1->getName(), $1->getType());
								symbolTable.InsertSymbol(temp);//8
								dataSegment.insert(temp->getVarAssem());//@@##
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
			else {
					SymbolInfo* p= new SymbolInfo($1->getName(), $1->getType());//@@##
					assem_var_param_list.push_back(*p);//@@##
				}	
			if(current_type != "void"){
								//symbolTable.Insert($1->getName(), $1->getType());
								symbolTable.InsertSymbol(temp);//9
								dataSegment.insert(temp->getVarAssem());//@@##
				}

			arraySegment.insert(make_pair($1 -> getName(), $3 -> getName()));//@@##	
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
			   $$ -> setAssemCode($$ -> getAssemCode() + $1 -> getAssemCode());
			} else {
               $$ = new SymbolInfo("", "");
			}

    }
	   | statements statement{
		    string name = $1 -> getName() + "" + $2 -> getName();
		    logout << "statements : statements statement" << endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
			$$ -> setAssemCode($$ -> getAssemCode() + $1 -> getAssemCode() + $2 -> getAssemCode());
	   }
	   ;
	   
statement : var_declaration {
		    string name = $1 -> getName() ;
		    logout << "statement : var_declaration" << endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
			assemCode = $$ -> getAssemCode() + $1 -> getAssemCode();
			$$ -> setAssemCode(annotateAssembly(name, assemCode));
	   }
	  | expression_statement{
		    string name = $1 -> getName() ;
		    logout << "statement : expression_statement" << endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
			assemCode = $$ -> getAssemCode() + $1 -> getAssemCode();
			$$ -> setAssemCode(annotateAssembly(name, assemCode));
	   } 
	  | compound_statement{
		    string name = $1 -> getName() ;
		    logout << "statement : compound_statement" << endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
			$$ -> setAssemCode($$ -> getAssemCode() + $1 -> getAssemCode());
	   }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement{
		    string name = "for(" + $3->getName() + "" + $4->getName() + "" + $5 -> getName() + ")" + $7 -> getName(); ;
		    logout << "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement" << endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
			string label1 = newLabel();
			string label2 = newLabel();

			assemCode = $$ -> getAssemCode() + $3 -> getAssemCode() + label1 + ":\n";
			assemCode += $4 -> getAssemCode() + "CMP " + $4 -> getTempAssem() + ", 0\nJE " + label2 + "\n";
			assemCode += $7 -> getAssemCode() + $5 -> getAssemCode() + "JMP " + label1 + "\n" + label2 + ":\n";
			gen(assemCode);
			$$ -> setAssemCode(annotateAssembly(name, assemCode));
	   }
	  | IF LPAREN expression RPAREN statement  %prec LOWER_THAN_ELSE{
		    string name = "if (" + $3 -> getName() + ")" + $5 -> getName() ;
		    logout << "statement : IF LPAREN expression RPAREN statement" << endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
			string label = newLabel();

			assemCode = $$ -> getAssemCode() + $3 -> getAssemCode() + "CMP " + $3 -> getTempAssem() + ", 0\nJE " + label + "\n";
			assemCode += $5 -> getAssemCode() + label + ":\n";
			gen(assemCode);
			$$ -> setAssemCode(annotateAssembly(name, assemCode));
	   }
	  | IF LPAREN expression RPAREN statement ELSE statement{
		    string name = "if (" + $3 -> getName() + ")" + $5 -> getName() + "else\n" + $7 -> getName() ;
		    logout << "statement : IF LPAREN expression RPAREN statement ELSE statement" << endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
			string label1 = newLabel();
			string label2 = newLabel();

			assemCode = $$ -> getAssemCode() + $3 -> getAssemCode() + "CMP " + $3 -> getTempAssem() + ", 0\nJE " + label2 + "\n";
			assemCode += $5 -> getAssemCode() + "JMP " + label1 + "\n" + label2 + ":\n" + $7 -> getAssemCode() + label1 + ":\n";
			gen(assemCode);
			$$ -> setAssemCode(annotateAssembly(name, assemCode));
	   }
	  | WHILE LPAREN expression RPAREN statement{
		    string name =  "while (" + $3 -> getName() + ")" + $5 -> getName();
		    logout << "statement : WHILE LPAREN expression RPAREN statement" << endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
			string label1 = newLabel();
			string label2 = newLabel();

			assemCode = $$ -> getAssemCode() + label1 + ":\n" + $3 -> getAssemCode();
			assemCode += "CMP " + $3 -> getTempAssem() + ", 0\nJE " + label2 + "\n";
			assemCode += $5 -> getAssemCode() + "JMP " + label1 + "\n" + label2 + ":\n";
			gen(assemCode);
			$$ -> setAssemCode(annotateAssembly(name, assemCode));
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
			assemCode = $$ -> getAssemCode() + var -> getAssemCode() + "PUSH " + var -> getVarAssem() + "\nCALL PRINTLN\nPOP " + var -> getVarAssem() + "\n";
            logout <<  "statement: PRINTLN LPAREN ID RPAREN SEMICOLON"<<endl;
        }
			$$ = new SymbolInfo(name, "NON-TERMINAL");
			$$ -> setAssemCode(annotateAssembly(name, assemCode));
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
			 assemCode = $$ -> getAssemCode() + $2 -> getAssemCode();
			if(scoped_func != "main") {
				assemCode += "MOV BP, SP\nMOV AX, " + $2 -> getTempAssem() + "\nMOV WORD PTR[BP + 14], AX\n";
				assemCode += "POP SI\nPOP BP\nPOP DX\nPOP CX\nPOP BX\nPOP AX\nRET 0\n";
			}
			$$ -> setAssemCode(assemCode);
			gen(assemCode);
			delete_temp_for_efficient_code($2 -> getTempAssem());
	   }
	  ;
	  //11/02/2023-11:00am
	  
expression_statement 	: SEMICOLON	{
        $$ = new SymbolInfo(";\n", "NON-TERMINAL");
        logout  << "expression_statement : SEMICOLON"<<endl;
    }		
			| expression SEMICOLON {
        $$ = new SymbolInfo( $1 -> getName() + ";\n", "expression_statement");
        logout  << "expression_statement : expression SEMICOLON"<<endl;
		$$ -> setAssemCode($$ -> getAssemCode() + $1 -> getAssemCode());//@@##
		$$ -> setTempAssem($1 -> getTempAssem());//@@##
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
		$$->setTempAssem(var->getVarAssem());
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
		
            string data = newTemp();
			assemCode = $$ -> getAssemCode() + $1 -> getAssemCode() + $3 -> getAssemCode();
			assemCode += "LEA SI, " + var -> getVarAssem() + "\nADD SI, " + $3 -> getTempAssem() + "\nADD SI, " + $3 -> getTempAssem() + "\n";
			assemCode += "MOV AX, [SI]\nMOV " + data + ", AX\n";
			$$ -> setTempAssem(data);
			$$ -> setAssemCode(assemCode);
			gen(assemCode);
			delete_temp_for_efficient_code($3 -> getTempAssem());
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
			assemCode = $$ -> getAssemCode() + $1 -> getAssemCode() + $3 -> getAssemCode();//@@##
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
			SymbolInfo *var = symbolTable.LookUp($1 -> getName());

			if(var) {
               if($1 -> getSpeciesType() == "ARRAY") {
                 assemCode += "LEA SI, " + var -> getVarAssem() + "\nADD SI, " + $1 -> getTempAssem() + "\nADD SI, " + $1 -> getTempAssem();
			     assemCode += "\nMOV CX, " + $3 -> getTempAssem() + "\nMOV [SI], CX\n";
			     $$ -> setTempAssem("[SI]");
			   } else if($1 -> getSpeciesType() == "VAR") {
                 assemCode += "MOV DX, " + $3 -> getTempAssem() + "\nMOV " + var -> getVarAssem() + ", DX\n";
			     $$ -> setTempAssem(var -> getVarAssem());
			   }

			   $$ -> setAssemCode(assemCode);
			   gen(assemCode);
			   delete_temp_for_efficient_code($3 -> getTempAssem());
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
			string data = newTemp();
            string label = newLabel();

			assemCode = $$ -> getAssemCode() + $1 -> getAssemCode() + $3 -> getAssemCode();
			
			if($2 -> getName() == "&&") {
                assemCode += "MOV " + data + ", 0\n" + "CMP " + $1 -> getTempAssem() + ", 0\n" + "JE " + label + "\n";
				assemCode += "CMP " + $3 -> getTempAssem() + ", 0\n" + "JE " + label + "\n";
				assemCode += "MOV " + data + ", 1\n" + label + ":\n";
			} else if($2 -> getName() == "||") {
				assemCode += "MOV " + data + ", 1\n" + "CMP " + $1 -> getTempAssem() + ", 0\n" + "JNE " + label + "\n";
				assemCode += "CMP " + $3 -> getTempAssem() + ", 0\n" + "JNE " + label + "\n";
				assemCode += "MOV " + data + ", 0\n" + label + ":\n";
			}

			$$ -> setTempAssem(data);
			$$ -> setAssemCode(assemCode);
			gen(assemCode);
			delete_temp_for_efficient_code($1 -> getTempAssem(), $3 -> getTempAssem());
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
			string data = newTemp();
            string label = newLabel();

			assemCode = $$ -> getAssemCode() + $1 -> getAssemCode() + $3 -> getAssemCode() + "MOV " + data + ", 1\nMOV AX, " 
			        + $3 ->getTempAssem() + "\nCMP "+ $1 ->getTempAssem() +", AX\n";

			string remaining = "\nMOV " + data + ", 0\n" + label + ":\n";

			if($2 -> getName() == "<") {
				assemCode += "JL " + label + remaining;
			} else if($2 -> getName() == "<=") {
				assemCode += "JLE " + label + remaining;
			} else if($2 -> getName() == ">") {
				assemCode += "JG " + label + remaining;
			} else if($2 -> getName() == ">=") {
				assemCode += "JGE " + label + remaining;
			} else if($2 -> getName() == "==") {
				assemCode += "JE " + label + remaining;
			} else if($2 -> getName() == "!=") {
				assemCode += "JNE " + label + remaining;
			}

			$$ -> setTempAssem(data);
			$$ -> setAssemCode(assemCode);
			gen(assemCode);
			delete_temp_for_efficient_code($1 -> getTempAssem(), $3 -> getTempAssem());
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
		
            string data = newTemp();
			assemCode = $$ -> getAssemCode() + $1 -> getAssemCode() + $3 -> getAssemCode();
			assemCode +=  "MOV AX, " + $1 -> getTempAssem() + "\nMOV " + data + ", AX\n" + "MOV AX, " + $3 -> getTempAssem();

			if($2 -> getName() == "+") {
				assemCode += "\nADD " + data + ", AX\n";
			} else if($2 -> getName() == "-") {
				assemCode += "\nSUB " + data + ", AX\n";
			}

			$$ -> setTempAssem(data);
			$$ -> setAssemCode(assemCode);
			gen(assemCode);
			delete_temp_for_efficient_code($1 -> getTempAssem(), $3 -> getTempAssem());
           
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
		string data = newTemp();	
			assemCode = $$ -> getAssemCode() + $1 -> getAssemCode() + $3 -> getAssemCode();

			if($2 -> getName() == "*") {
				assemCode += "MOV AX, " + $3 -> getTempAssem() + "\nIMUL " + $1 -> getTempAssem() + "\nMOV " + data + ", AX\n";
			} else if($2 -> getName() == "/") {
				assemCode += "MOV AX, " + $1 -> getTempAssem() + "\nCWD\nIDIV " + $3 -> getTempAssem() + "\nMOV " + data + ", AX\n";
			} else if($2 -> getName() == "%") {
				assemCode += "MOV AX, " + $1 -> getTempAssem() + "\nCWD\nIDIV " + $3 -> getTempAssem() + "\nMOV " + data + ", DX\n";
			}

			

			$$ -> setTempAssem(data);
			$$ -> setAssemCode(assemCode);
			gen(assemCode);
			delete_temp_for_efficient_code($1 -> getTempAssem(), $3 -> getTempAssem());

		  }
     ;
// 28th JANUARY 8:00 PM//////////////////////////////////////////////////
unary_expression : ADDOP unary_expression  {
	        string name =$1 -> getName() + "" + $2 -> getName();
			logout <<  "unary_expression : ADDOP unary_expression"<<endl;
			$$ = new SymbolInfo(name,"NON-TERMINAL",$2 -> getDataType(),"");
            $$ -> setDataType($2 -> getDataType());
			assemCode = $$ -> getAssemCode() + $2 -> getAssemCode();
			string data = newTemp();

			if($1 -> getName() == "+") {
                assemCode += "MOV AX, " + $2 -> getTempAssem() + "\nMOV " + data + ", AX\n";
			} else if($1 -> getName() == "-") {
                assemCode += "MOV AX, " + $2 -> getTempAssem() + "\nMOV " + data + ", AX\nNEG " + data + "\n";
			}

			$$ -> setAssemCode(assemCode);
			gen(assemCode);
			$$ -> setTempAssem(data);
			delete_temp_for_efficient_code($2 -> getTempAssem());
}
		 | NOT unary_expression {
	        string name ="!" + $2 -> getName();
			logout <<  "unary_expression : NOT unary_expression"<<endl;
			$$ = new SymbolInfo(name,"NON-TERMINAL",$2 -> getDataType(),"");
            $$ -> setDataType($2 -> getDataType());
			string data = newTemp();
			string label = newLabel();
			assemCode = $$ -> getAssemCode() + $2 -> getAssemCode() + "\nCMP " + $2 -> getTempAssem() + ", 0\nMOV "
			        + data + ", 0\nJNE " + label + "\nMOV " + data + ", 1\n" + label + ":\n";
		    $$ -> setAssemCode(assemCode);
			gen(assemCode);
			$$ -> setTempAssem(data);
			delete_temp_for_efficient_code($2 -> getTempAssem());
}
		 | factor  {
	        string name = $1 -> getName();
			logout <<  "unary_expression : factor"<<endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL",$1 -> getDataType(),"VAL");
			$$ = $1;
}
		 ;
		 // 12/02/2023: 7:01 PM
	
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
		string datatype;
       
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
				  datatype=var->getDataType();
        }
		datatype=var->getDataType();;
		assemCode = $$ -> getAssemCode() + $3 -> getAssemCode();
			if(datatype != "") {
				$$ -> setDataType(datatype);

			    for(string p:available_param_list) {
                  assemCode += "PUSH " + p + "\n";
                } 	
              
			    for(string p:available_assem_var_param_list) {
                  assemCode += "PUSH " + p + "\n";
                } 

				for(auto argument:var_assem_arguments.back()) {
					assemCode += "PUSH " + argument + "\n";
				}

				if(datatype != "void") {
					assemCode += "PUSH 0\n";
				}

				assemCode += "CALL " + $1 -> getName() + "\n";
				string data;
				if(datatype != "void") {
					data = newTemp();
					assemCode += "POP " + data + "\n";
					$$ -> setTempAssem(data);
				}

				assemCode += "ADD SP, " + to_string(var_assem_arguments.back().size() * 2) + "\n";

				for(auto p=available_assem_var_param_list.rbegin();p!=available_assem_var_param_list.rend();p++) {
					if(*p == data) continue;
					assemCode += "POP " + *p + "\n";
				}

				int no_of_parameters = available_param_list.size() - 1;
			    for(int i = no_of_parameters; i >= 0; i--) {
				   string p = available_param_list[i];
                   assemCode += "POP " + p + "\n";
                }

                param_list.clear();
				var_assem_arguments.pop_back();
			}

			$$ -> setAssemCode(assemCode);
			gen(assemCode);

	}

	
	| LPAREN expression RPAREN
	{
		    string name = "(" + $2 -> getName() + ")";
			logout << "factor : LPAREN expression RPAREN"<<endl; 
			$$ = new SymbolInfo(name, "NON-TERMINAL",$2 -> getDataType(),"");
			$$ -> setDataType($2 -> getDataType());
			$$ -> setAssemCode($$-> getAssemCode() + $2 -> getAssemCode());
		    $$ -> setTempAssem($2 -> getTempAssem());
	}
	| CONST_INT 
	{
		    string  name = $1 -> getName();
			logout << "factor : CONST_INT"<<endl; 
			$$ = new SymbolInfo(name, "NON-TERMINAL","int","VAL");
			//$$ -> setDataType("int");
			//$$->setSpeciesType("VAL");//value
			string data = newTemp();
			assemCode = $$ -> getAssemCode() + "MOV " + data + ", "+ $1 -> getName() + "\n";
			$$ -> setAssemCode(assemCode);
			gen(assemCode);
			$$ -> setTempAssem(data);
		
	}
	| CONST_FLOAT
	{
        string  name = $1 -> getName();
			logout << "factor : CONST_FLOAT"<<endl; 
			$$ = new SymbolInfo(name, "NON-TERMINAL","float","VAL");
			//$$ -> setDataType("float");
			//$$->setSpeciesType("VAL");//value
			$$ -> setTempAssem(name);
	}
	| variable INCOP 
	{
        $$ = new SymbolInfo($1->getName()+"++", "NON-TERMINAL");
		logout << "factor : variable INCOP"<<endl; 
		string data = newTemp();
			assemCode = $$ -> getAssemCode() + "MOV AX, " + $1 -> getTempAssem() 
			        + "\nMOV " + data + ", AX\nINC " + $1 -> getTempAssem() + "\n";
			$$ -> setAssemCode(assemCode);
			gen(assemCode);
			$$ -> setTempAssem(data);
			/*  int a = 5;int b = a++;
			MOV AX, [a]
            MOV TEMP_1, AX
            INC [a]

			*/
	}
	| variable DECOP
	{
        $$ = new SymbolInfo($1->getName()+"--", $1->getType());
		logout << "factor : variable DECOP"<<endl;
		string data = newTemp();
			assemCode = $$ -> getAssemCode() + "MOV AX, " + $1 -> getTempAssem() 
			        + "\nMOV " + data + ", AX\nDEC " + $1 -> getTempAssem() + "\n";
			$$ -> setAssemCode(assemCode);
			gen(assemCode);
			$$ -> setTempAssem(data); 
		
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
			var_assem_arguments.emplace_back();
			// there are no arguments in the argument list, so we need to add an empty vector to var_assem_arguments. This is because we still need to generate assembly code for the function call, even if there are no arguments to pass. By adding an empty vector, we ensure that we allocate the correct amount of space on the stack for the function call, and we can then clean up the stack after the call is complete.
}
			  ;
	
arguments : arguments COMMA logic_expression {
	        string name =  $1 -> getName() + "," + $3 -> getName();
			logout <<  "arguments : arguments COMMA logic_expression"<<endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");
			param_list.push_back(*$3);
			var_assem_arguments.back().push_back($3 -> getTempAssem());
			$$ -> setAssemCode($$ -> getAssemCode() + $1 -> getAssemCode() + $3 -> getAssemCode());
}
	      | logic_expression  {
			string name = $1 -> getName();
			logout <<  "arguments : logic_expression"<<endl;
			$$ = new SymbolInfo(name, "NON-TERMINAL");//////
			$$ = $1;
			param_list.push_back(*$1);
			var_assem_arguments.emplace_back();
			var_assem_arguments.back().push_back($1 -> getTempAssem());
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
	outputcode.open("code.asm");
	optcode.open("optimized_code.asm");
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

