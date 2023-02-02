/*
%{..}%裡的東西只會include到y.tab.c, y.tab.h則沒有,所以union裡無法使用string
*/
%{
#define Trace(t)        printf(t)
#include <cstdio>
#include <iostream>
#include <typeinfo>
#include <string.h>
#include "symtab.h"
//#include "gen.h"

extern FILE *yyin;
extern char *yytext;

extern int yylex(void);
static void  yyerror(const char *msg);
Symtab_list symtab_list = Symtab_list();
//Generator gen;

int if_else = 0;
bool global_flag = true;
bool operation_flag = false;
int in_if_else_cout = 0;
int count = 0;
int L_count = 0;
string class_name;
//----------------------------------------- new add
vector<Node*> var_vector; 
vector<Node*> var_assign_vector;

vector<Node*> para_vector;
vector<ValueType> argu_vector;
ValueType ret_type = type_void;
//-----------------------------------------
vector<ValueType> vt;
vector<ValueType> vt2;
%}

%code requires{
   #include<string>
   #include "symtab.h"
}

%union{
	int int_dataType;
	double double_dataType;
	bool bool_dataType;
	char* string_dataType;
        Node* compound_dataType;
        ValueType dataType;
}



/* tokens */
%token ADD ADDEQ SUB SUBEQ MULEQ DIVEQ EQ NEQ LEQ GEQ AND OR
%token SEMI SEMICOLON DD
%token BOOL BREAK CHAR CASE CONST CONTINUE DO DOUBLE DEFAULT ELSE EXTERN FLOAT FOR FOREACH IF INT PRINT PRINTLN READ RETURN STRING SWITCH VOID WHILE
%type expression
%type<dataType> data_type
%type<dataType> function_variation

%token <int_dataType> INT_CONST
%token <double_dataType> REAL_CONST
%token <bool_dataType> BOOL_CONST
%token <string_dataType> STR_CONST
%token <string_dataType> ID


%type <compound_dataType> identifier_list constant_values expression call_function logical_expression relational_expression bool_expression calculation_expression variable_choice constant_choice print_choice 



	          
%left OR
%left AND
%left '!'
%left '<' LEQ EQ GEQ '>' NEQ
%left ADD '+' SUB '-'
%left '*' '/'
%nonassoc UMINUS



%%
program:        program function_choice
                {
	//	Trace("Reducing to program\n");
		} 
              | program variable_choice 
		{
	//	Trace("Reducing to program\n");
		}
              | program constant_choice
		{
	//	Trace("Reducing to program\n");
		}
              | {
	//	Trace("Reducing to program\n");
                };
                                

function_choice:   data_type ID
	           {
			Node *data = new Node($2, Function, $1);
			symtab_list.insert_token(data);
			symtab_list.push();
                   }
	           function_variation
                   {
			Node *data = symtab_list.lookup_token($2);
			for(int i=0; i<para_vector.size(); i++){
				data->func_para.push_back(para_vector[i]->getvType());
				symtab_list.insert_token(para_vector[i]);
			}
			para_vector.clear();
                   }
                   '{' inside_function '}'
	           {
			
			if($1 != ret_type){
				yyerror("Function return type mismatch");
			}
			symtab_list.pop();
			ret_type = type_void;
		   };


function_variation: '(' mul_args  ')'
		    {
	//		Trace("Reducing to fun_var\n");
                    } 
                  | '('  ')'    
                    {
	//		Trace("Reducing to fun_var\n");
		    };
                  


mul_args:   mul_args ',' sgl_args | sgl_args
            {
	//	Trace("Reducing to mul_args\n");
            };	


sgl_args:   data_type ID 
	    {
		Node *data = new Node($2, Argument, $1);
		para_vector.push_back(data);
            }; 


inside_function:   inside_function variable_choice
	           {
	//	 	Trace("Reducing to inside_function\n");
	           }
                 |
	           inside_function constant_choice
		   {
	//	 	Trace("Reducing to inside_function\n");
		   }
  		 |
                   inside_function statement_choice
		   {
	//	 	Trace("Reducing to inside_function\n");
		   } 
                 |
		   {
	//	 	Trace("Reducing to inside_function\n");
		   };

variable_choice: data_type identifier_list ';' 
	         {	
			
			for(int i=0, j=0; i<var_vector.size(); i++){
				var_vector[i]->setvType($1);
				symtab_list.insert_token(var_vector[i]);
				if(var_vector[i]->getAssign())
				{
					if(var_vector[i]->getvType() != var_assign_vector[j++]->getvType()){
					yyerror("LHS and RHS datatype mismatch");
			    }
				}
			}
			var_assign_vector.clear();
			var_vector.clear();
	//	 	Trace("Reducing to var_ch\n");
		 };

identifier_list: identifier_list ',' identifier_decl 
	         {
	//	 	Trace("Reducing to iden_list\n");
                 }
               | identifier_decl
                 {
	//	 	Trace("Reducing to iden_list\n");
                 };

identifier_decl: ID 
	         {
			Node *data = new Node($1, Variable, type_void);
			var_vector.push_back(data);
                 }
 		| ID '=' expression 
                 {
			Node *data = new Node($1, Variable, type_void);
			data->setAssign(true);
			var_vector.push_back(data);
			var_assign_vector.push_back($3);
                 }
                | ID '['INT_CONST']' 
                 {
			Node *data = new Node($1, Variable, type_void);
			var_vector.push_back(data);
                 }  
                | ID '['ID']' 
                 {
			Node* n = symtab_list.lookup_token($3);
			if(n == NULL){
				yyerror("This id isn't exist");	
			}
			if(n->getvType() != type_integer){
				yyerror("Array index isn't integer");
			}
			Node *data = new Node($1, Variable, type_void);
			var_vector.push_back(data);
                 }; 

                    
constant_choice:   CONST data_type ID '=' expression ';'
                   {
			if($2 != $5->getvType()){
				yyerror("LHS and RHS mismatch");
			}
			Node *data = new Node($3, Constant, $2);
			symtab_list.insert_token(data);
                   }  
                   
statement_choice:    simple_statement 
		     {
          //              Trace("Reducing to statement_choice\n");
                     }
                   | conditional_statement 
                     {
            //            Trace("Reducing to statement_choice\n");
		     }
 		   | loop_statement  
		     {
              //          Trace("Reducing to statement_choice\n");
                     };

simple_statement:    call_function ';'
		     {
		     }
		   | no_semi_statement ';' 
                     {
                     }
                   | PRINT
                     {
                     }  
                     print_choice
                     {
                     } 
	           | PRINTLN
                     {
                     }
                     print_choice
                     {
                     }
		   | READ ID ';' 
                     {
                     }
                   | RETURN expression ';'
                     {
			ret_type = $2->getvType();
                     }
                   | RETURN ';'
                     {
			ret_type = type_void;
                     };

no_semi_statement: no_semi_assign | no_semi_ADD_SUB;
no_semi_assign: ID '=' expression 
	        {
			Node *data = symtab_list.lookup_token($1);
			if(data == NULL){yyerror("Identifier Not Found");}
			if(data->geteType() == Constant){
				yyerror("Constant can't reassign");
			}
			if(data->getvType() != $3->getvType()){
				yyerror("LHS and RHS mismatch");
			}
		};  
no_semi_ADD_SUB: expression ADD %prec UMINUS | expression SUB %prec UMINUS | ADD expression %prec UMINUS | SUB expression %prec UMINUS;


print_choice:        expression 
                     {

                     }	';';
	             
                         
                           
                         


conditional_statement:  IF '(' bool_expression ')'
		        {  
				symtab_list.push();
                        }
                        block_or_simple_conditional
                        {
				symtab_list.pop();
                        }
		        else_choice
		        {
                           /* Trace("Reducing to conditional_statement\n");*/		               };


else_choice:         ELSE
	             {
				symtab_list.push();
                     }
	             block_or_simple_conditional
                     {
				symtab_list.pop();
                     }
                     | 
	             {
		     };


block_or_simple_conditional: '{' inside_block_conditional '}'
			     {
                             }
			   | statement_choice
                             {
                             };


inside_block_conditional:    inside_block_conditional statement_choice |                                    inside_block_conditional constant_choice  |		                           inside_block_conditional variable_choice  | 
			     {
                             //Trace("Reducing to inside_block_conditional\n");
                             };

loop_statement:      WHILE
	             {
				symtab_list.push();
                     } 
                     '(' bool_expression  ')'
	             {
                     }
                     block_or_simple_loop 
                     {
				symtab_list.pop();
                     }
                   | FOR'(' no_semi_statement ';' bool_expression ';' no_semi_statement ')' 
                     {
				symtab_list.push();
                     }
                     block_or_simple_loop                    
                     {
				symtab_list.pop();
			 //Trace("Reducing to loop_statement\n");
		     }
		   | FOREACH '(' ID ':' ID DD ID ')'
                     {
				symtab_list.push();
 		     }
		     block_or_simple_loop
		     {
				symtab_list.pop();
		     }
		   | FOREACH '(' ID ':' INT_CONST DD ID ')'
		     {
				symtab_list.push();
		     }
 		     block_or_simple_loop
		     {
				symtab_list.pop();
		     }
		   | FOREACH '(' ID ':' ID DD INT_CONST ')'
		     {
				symtab_list.push();
		     }
		     block_or_simple_loop
		     {
				symtab_list.pop();
		     }
		   | FOREACH '(' ID ':'  INT_CONST DD INT_CONST ')'
		     {
				symtab_list.push();
		     }
		     block_or_simple_loop
		     {
				symtab_list.pop();
 		     };


block_or_simple_loop: '{' inside_block_loop  '}'
		      {
 		      }
                     | statement_choice |
		       BREAK | CONTINUE
                      {
                      };


inside_block_loop:  inside_block_loop statement_choice |
                    inside_block_loop variable_choice  |
                    inside_block_loop constant_choice  |
	       	    inside_block_loop BREAK            | 
	       	    inside_block_loop CONTINUE         |
                    {/*Trace("Reducing to inside_block_loop\n");*/};


call_function:      ID '(' check_call_function_argument ')'
	            {
                        Node *data = symtab_list.lookup_token($1);
			if(data->func_para.size() != argu_vector.size()){
				yyerror("parameter and argument mismatch");
			}
			for(int i=0; i<argu_vector.size(); i++){
				if(data->func_para[i] != argu_vector[i]){
				    yyerror("parameter and argument mismatch");
				}
			}
			argu_vector.clear();
			$$ = data;
                    };


check_call_function_argument: comma_seperated_arguments | ;


comma_seperated_arguments: comma_seperated_arguments ',' call_function_parameter | call_function_parameter ;


call_function_parameter: expression
		         {
				argu_vector.push_back($1->getvType());
                         };


expression: call_function
	    {
                $$ = $1;
            }
	  | ID
            {
		Node* data = symtab_list.lookup_token($1);
		if(data == NULL) {yyerror("Identifier Not Found");}
		$$ = data;
            }
	  | '(' expression  ')' | calculation_expression
	  | constant_values
            {
	         $$ = $1;	
	    } 
	  | ID '[' INT_CONST ']'
            {
		Node* data = symtab_list.lookup_token($1);
		if(data == NULL) {yyerror("Identifier Not Found");}
		$$ = data;
	    }
	  | ID '[' ID ']'
            {
		Node* data2 = symtab_list.lookup_token($3);
		if(data2->getvType() != type_integer){
			yyerror("Array Argument isn't integer");
		}
		Node* data = symtab_list.lookup_token($1);
		if(data == NULL) {yyerror("Identifier Not Found");}
		$$ = data;
	    };

calculation_expression: '-' expression %prec UMINUS
		        {
                        }
                        | no_semi_ADD_SUB
                        | expression '*' expression
                        {
                            if($1->getvType() != $3->getvType()){
                                yyerror("Operand datatype mismatch");
                            } 
                        }   
		        | expression '/' expression
                        {
                            if($1->getvType() != $3->getvType()){
                                yyerror("Operand datatype mismatch");
                            } 
                        }
                        | expression '%' expression       
                        {
                            if($1->getvType() != $3->getvType()){
                                yyerror("Operand datatype mismatch");
                            } 
                        }
          		| expression '+' expression
		        {
                            if($1->getvType() != $3->getvType()){
                                yyerror("Operand datatype mismatch");
                            } 
                        }
		        | expression '-' expression        
         	        {
                            if($1->getvType() != $3->getvType()){
                                yyerror("Operand datatype mismatch");
                            } 
                        };


bool_expression: relational_expression | logical_expression;


relational_expression:  expression '<' expression 
		     {
                     }
		     | expression LEQ expression 
                     {
                     }
                     | expression '>' expression
                     {
                     }
                     | expression GEQ expression 
                     {
                     }
                     | expression EQ expression 
                     {
                     }
                     | expression NEQ expression
                     {
                     };


logical_expression:  expression
                     {
			if($1->getvType() != type_bool){
				yyerror("exp type isn't boolean");
			}
		     }
                     |'!' expression 
                     {
			if($2->getvType() != type_bool){
				yyerror("exp type isn't boolean");
			}
                     }
                     | expression AND expression
                     {
                     }
		     | expression OR expression
                     {
                     }
                     | bool_expression OR bool_expression
		     {
		     }
                     | bool_expression AND bool_expression
		     {
		     }; 


constant_values:         INT_CONST
	                 {
			       Node* data = new Node("",Constant,type_integer);
			       $$ = data;
                         }
                       | REAL_CONST
			 {
			       Node* data = new Node("",Constant,type_real);
			       $$ = data;
 			 }
                       | BOOL_CONST
                         {
			       Node* data = new Node("",Constant,type_bool);
			       $$ = data;
                         }
                       | STR_CONST
                         {
			       Node* data = new Node("",Constant,type_string);
			       $$ = data;
                         };
                           
	                


data_type:  INT    {$$ = type_integer;}
         |  FLOAT  {$$ = type_real;}
         |  BOOL   {$$ = type_bool;}
         |  STRING {$$ = type_string;}
         |  VOID   {$$ = type_void;};
	   



                
%%

void yyerror(const char *msg)
{
   printf("[ERROR]: %s\n", msg);
   exit(0);
}

int main(int argc, char **argv)
{
    /* open the source program file */
    if (argc != 2) {
        printf ("Usage: sc filename\n");
        exit(1);
    }
    yyin = fopen(argv[1], "r");         /* open input file */

    /*
    gen.file.open("test.txt",ios::out);
    if(gen.file.fail())
       cout << "File Fail\n";
    */
    if (yyparse() == 1){                
        yyerror("Parsing error !");
    }

    Node* n = symtab_list.lookup_token("main");
    if(n == NULL){yyerror("Don't have main function");}
    symtab_list.dump_all();
    


}
