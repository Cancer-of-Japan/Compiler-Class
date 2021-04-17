/*	Definition section */
%{
    #include "common.h" //Extern variables that communicate with lex
    // #define YYDEBUG 1
    // int yydebug = 1;
    #include <stdio.h>
#include <string.h>

    extern int yylineno;
    extern int yylex();
    extern int int_num;
    extern int len;
    extern float float_num;
    extern char id_name[100];
    extern FILE *yyin;
    int check;
    int lit_res;
    float val_for_cal[100];
    char var1[100],var2[100];
    char temp_type1[100], temp_type2[100];

    int addrs_no = 0;

    void yyerror (char const *s)
    {
        printf("error:%d: %s\n", yylineno, s);
    }

    /* Symbol table function - you can add new function if needed. */
    static void create_symbol();
    static void insert_symbol();
    static void lookup_symbol();
    static void gimme_the_val();
    static void check_for_arr();
    static void dump_symbol();
    FILE *f;
    
    
    struct symbol_table {
        char id[100];
        char type[100];
        char element[100];
        int scope_depth;
        int addrs;
        int lineno;
	};
    struct symbol_table table[100];
    int table_index =0;  
    int table_exist =0;
    int scope_index=0;
    char sym_type[100];
    char crr[100];
    char element[100];
    int test_num;
    int cmp_counter=0;
     

%}

%error-verbose

/* Use variable or self-defined structure to represent
 * nonterminal and token type
 */
%union {
    int i_val;
    float f_val;
    char *s_val;               
    char id;
}

/* Token without return */
%token  VAR
%token  INT FLOAT BOOL STRING
%token  IF ELSE FOR
%token  ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN QUO_ASSIGN REM_ASSIGN
%token  LOR LAND 
%token  NEWLINE
%token  TRUE FALSE
%token  PRINT PRINTLN
%token  INC DEC GEQ LEQ EQL NEQ 

/* Precedence Rules */
%right '='
%right MUL_ASSIGN QUO_ASSIGN REM_ASSIGN SUB_ASSIGN ADD_ASSIGN
%left LOR
%left  LAND
%left  EQL NEQ
%left '<' '>' LEQ GEQ
%left '+' '-'
%right '!'
%left '*' '/' '%'
%right UNARY
%left '(' ')' 



/* Token with return, which need to sepcify type */
%token <s_val>  INT_LIT
%token <s_val>  FLOAT_LIT
%token <s_val>  STRING_LIT
%token <s_val>  ID

/* Nonterminal with return, which need to sepcify type */
%type <i_val>   INT_Literal
%type <f_val>   Expr Terminal FLOAT_Literal  
%type <s_val>   Bool Type Literal Array
%nonassoc ELSE

/* Yacc will start at this nonterminal */
%start Program

/* Grammar section */
%%

Program
    :StatementList {dump_symbol(scope_index);}
;

StatementList
    :StatementList Statement
    |Statement
;

Statement
    :Declaration
    |AssignStmt
    |BRAC
    |Expr
    |FORStmt
    |IFStmt
    |PrintStmt
    |NEWLINE
;

AssignStmt
    :Expr '=' Expr {
        printf("ASSIGN\n");
            strcpy(var2,id_name);
            gimme_the_val(var1,var2);

            int i;
            char checker[100];
            for(i=0;i<table_index;i++){
                printf("+++++++ %s\n",sym_type);
                if(strcmp(id_name,table[i].id)==0){
                    //printf("------------------%s %s %s %d %d\n",table[i].id,table[i].type, checker, table[i].addrs,i);
                    if(strcmp(table[i].type,"int32")==0){
                        fprintf(f,"\tistore %d\n",i);;
                    }
                    else if(strcmp(table[i].type,"float32")==0 && strcmp(checker,"float32")==0){
                        fprintf(f,"\tfstore %d\n",i);
                        
                    }
                    else if(strcmp(table[i].type,"array")==0 && strcmp(checker,"array")==0){
                            fprintf(f,"\tiaload\n");
                    }
                    else if((strcmp(table[i].type,"bool")==0) && (strcmp(checker,"bool")==0)){
                            fprintf(f,"\tistore %d\n",i);
                            //fprintf(f,"\tOREEEEEEEEEEEEEEEEEE %d\n",i);
                    }
                    else if(strcmp(table[i].type,"string")==0 && strcmp(checker,"string")==0){
                                fprintf(f,"\tastore %d\n",i);
                    }
                }
            }   
        }
    |Expr ADD_ASSIGN Expr {
        printf("ADD_ASSIGN\n");
        int i;
        char checker[100];
        strcpy(checker,sym_type);
        printf("+++++++ %s\n",sym_type);
        
        for(i=0;i<table_index;i++){
            printf("+++++++ %s\n",sym_type);
            if(strcmp(id_name,table[i].id)==0){
                //printf("------------------%s %s %s %d %d\n",table[i].id,table[i].type, checker, table[i].addrs,i);
                if(strcmp(table[i].type,"int32")==0){
                    fprintf(f,"\tiadd\n");
                    fprintf(f,"\tistore %d\n",i);
                }
                else if(strcmp(table[i].type,"float32")==0 && strcmp(checker,"float32")==0){
                    fprintf(f,"\tfadd\n");
                    fprintf(f,"\tfstore %d\n",i);
                    
                }
                else if(strcmp(table[i].type,"array")==0 && strcmp(checker,"array")==0){
                        fprintf(f,"\tiaload\n");
                }
                else if((strcmp(table[i].type,"bool")==0) && (strcmp(checker,"bool")==0)){
                        fprintf(f,"\tistore %d\n",i);
                        //fprintf(f,"\tOREEEEEEEEEEEEEEEEEE %d\n",i);
                }
                else if(strcmp(table[i].type,"string")==0 && strcmp(checker,"string")==0){
                            fprintf(f,"\tastore %d\n",i);
                }
            }
        }        
        
        
        }
    |Expr SUB_ASSIGN Expr {printf("SUB_ASSIGN\n");
            int i;
            char checker[100];
            for(i=0;i<table_index;i++){
                printf("+++++++ %s\n",sym_type);
                if(strcmp(id_name,table[i].id)==0){
                    //printf("------------------%s %s %s %d %d\n",table[i].id,table[i].type, checker, table[i].addrs,i);
                    if(strcmp(table[i].type,"int32")==0){
                        fprintf(f,"\tisub\n");
                        fprintf(f,"\tistore %d\n",i);
                    }
                    else if(strcmp(table[i].type,"float32")==0 && strcmp(checker,"float32")==0){
                        fprintf(f,"\tfsub\n");
                         fprintf(f,"\tfstore %d\n",i);
                        
                    }
                    else if(strcmp(table[i].type,"array")==0 && strcmp(checker,"array")==0){
                            fprintf(f,"\tiaload\n");
                    }
                    else if((strcmp(table[i].type,"bool")==0) && (strcmp(checker,"bool")==0)){
                            fprintf(f,"\tistore %d\n",i);
                            //fprintf(f,"\tOREEEEEEEEEEEEEEEEEE %d\n",i);
                    }
                    else if(strcmp(table[i].type,"string")==0 && strcmp(checker,"string")==0){
                                fprintf(f,"\tastore %d\n",i);
                    }
                }
            }  
        }
    |Expr MUL_ASSIGN Expr {
        printf("MUL_ASSIGN\n");
            int i;
            char checker[100];
            for(i=0;i<table_index;i++){
                printf("+++++++ %s\n",sym_type);
                if(strcmp(id_name,table[i].id)==0){
                    //printf("------------------%s %s %s %d %d\n",table[i].id,table[i].type, checker, table[i].addrs,i);
                    if(strcmp(table[i].type,"int32")==0){
                        fprintf(f,"\timul\n");
                        fprintf(f,"\tistore %d\n",i);
                    }
                    else if(strcmp(table[i].type,"float32")==0 && strcmp(checker,"float32")==0){
                        fprintf(f,"\tfmul\n");
                         fprintf(f,"\tfstore %d\n",i);
                        
                    }
                    else if(strcmp(table[i].type,"array")==0 && strcmp(checker,"array")==0){
                            fprintf(f,"\tiaload\n");
                    }
                    else if((strcmp(table[i].type,"bool")==0) && (strcmp(checker,"bool")==0)){
                            fprintf(f,"\tistore %d\n",i);
                            //fprintf(f,"\tOREEEEEEEEEEEEEEEEEE %d\n",i);
                    }
                    else if(strcmp(table[i].type,"string")==0 && strcmp(checker,"string")==0){
                                fprintf(f,"\tastore %d\n",i);
                    }
                }
            }  
        }
            
    |Expr QUO_ASSIGN Expr {printf("QUO_ASSIGN\n");
            printf("MUL_ASSIGN\n");
            int i;
            char checker[100];
            for(i=0;i<table_index;i++){
                printf("+++++++ %s\n",sym_type);
                if(strcmp(id_name,table[i].id)==0){
                    //printf("------------------%s %s %s %d %d\n",table[i].id,table[i].type, checker, table[i].addrs,i);
                    if(strcmp(table[i].type,"int32")==0){
                        fprintf(f,"\tidiv\n");
                        fprintf(f,"\tistore %d\n",i);
                    }
                    else if(strcmp(table[i].type,"float32")==0 && strcmp(checker,"float32")==0){
                        fprintf(f,"\tfdiv\n");
                         fprintf(f,"\tfstore %d\n",i);
                        
                    }
                    else if(strcmp(table[i].type,"array")==0 && strcmp(checker,"array")==0){
                            fprintf(f,"\tiaload\n");
                    }
                    else if((strcmp(table[i].type,"bool")==0) && (strcmp(checker,"bool")==0)){
                            fprintf(f,"\tistore %d\n",i);
                            //fprintf(f,"\tOREEEEEEEEEEEEEEEEEE %d\n",i);
                    }
                    else if(strcmp(table[i].type,"string")==0 && strcmp(checker,"string")==0){
                                fprintf(f,"\tastore %d\n",i);
                    }
                }
            }  
        
        
        }
    |Expr REM_ASSIGN Expr {printf("REM_ASSIGN\n");
            printf("MUL_ASSIGN\n");
            int i;
            char checker[100];
            for(i=0;i<table_index;i++){
                printf("+++++++ %s\n",sym_type);
                if(strcmp(id_name,table[i].id)==0){
                    //printf("------------------%s %s %s %d %d\n",table[i].id,table[i].type, checker, table[i].addrs,i);
                    if(strcmp(table[i].type,"int32")==0){
                        fprintf(f,"\tirem\n");
                        fprintf(f,"\tistore %d\n",i);
                    }
                    else if(strcmp(table[i].type,"float32")==0 && strcmp(checker,"float32")==0){
                        fprintf(f,"\tfrem\n");
                         fprintf(f,"\tfstore %d\n",i);
                        
                    }
                    else if(strcmp(table[i].type,"array")==0 && strcmp(checker,"array")==0){
                            fprintf(f,"\tiaload\n");
                    }
                    else if((strcmp(table[i].type,"bool")==0) && (strcmp(checker,"bool")==0)){
                            fprintf(f,"\tistore %d\n",i);
                            //fprintf(f,"\tOREEEEEEEEEEEEEEEEEE %d\n",i);
                    }
                    else if(strcmp(table[i].type,"string")==0 && strcmp(checker,"string")==0){
                                fprintf(f,"\tastore %d\n",i);
                    }
                }
            }  
        
        }
;

Expr
    :CompExpr
    |'(' Expr ')'
    |Terminal
    |UniaryExpr
    |Expr INC   %prec UNARY      {printf("INC\n");
        strcpy(var2,id_name);
        gimme_the_val(var1,var2);
        ////printf("\n I called em... %s %s %d\n",var1,var2,test_num);
        //fprintf(f,"\tiadd\n");
        
        int i,check;
        for(i=0;i<table_index;i++){
                if(strcmp(var2,table[i].id)==0){
                strcpy(temp_type2,table[i].type);
                check = i;
            }
        }

        //printf("YO its me fool! %s %s \n\n",temp_type1,temp_type2);
        
        if(strcmp(temp_type2,"int32")==0){
            fprintf(f,"\tiload %d\n",check);
            fprintf(f,"\tldc 1\n");
            fprintf(f,"\tiadd\n");
            fprintf(f,"\tistore %d\n",check);
            //fprintf(f,"\tiload %d\n",check);
            fprintf(f,"\t\n \n\n");
            }
        else if(strcmp(temp_type2,"float32")==0){
			    fprintf(f,"\tfload %d\n",check);
			    fprintf(f,"\tldc 1.000000\n");
			    fprintf(f,"\tfadd\n");
			    fprintf(f,"\tfstore %d\n",check);
                //fprintf(f,"\tfload %d\n",check);
            }

        
        
        }
    |Expr DEC   %prec UNARY      {printf("DEC\n");
        strcpy(var2,id_name);
        gimme_the_val(var1,var2);
        ////printf("\n I called em... %s %s %d\n",var1,var2,test_num);
        //fprintf(f,"\tiadd\n");
        
        int i,check;
        for(i=0;i<table_index;i++){
                if(strcmp(var2,table[i].id)==0){
                strcpy(temp_type2,table[i].type);
                check = i;
            }
        }

        //printf("YO its me fool! %s %s \n\n",temp_type1,temp_type2);
        
        if(strcmp(temp_type2,"int32")==0){
            fprintf(f,"\tiload %d\n",check);
            fprintf(f,"\tldc 1\n");
            fprintf(f,"\tisub\n");
            fprintf(f,"\tistore %d\n",check);
            //fprintf(f,"\tfload %d\n",check);
            //table[i].i_data++;
            }
        else if(strcmp(temp_type2,"float32")==0){
			    fprintf(f,"\tfload %d\n",check);
			    fprintf(f,"\tldc 1.000000\n");
			    fprintf(f,"\tfsub\n");
			    fprintf(f,"\tfstore %d\n",check);
                //fprintf(f,"\tfload %d\n",check);
            }
    
    } 
;


Array
    :'[' INT_Literal ']' Type  {
            strcpy(element,sym_type); 
            strcpy(sym_type, "array");
            $$ = "array";
        }
    |'[' FLOAT_Literal ']' Type  {strcpy(element,sym_type) ; strcpy(sym_type, "array"); $$ = "array";}
;  

BRAC
    :Left_BRAC StatementList Right_BRAC
;

Left_BRAC
    :'{'{scope_index++;}
;

Right_BRAC
    : '}' {dump_symbol(scope_index);scope_index--;}
;

Declaration
    :VAR ID Type '=' Expr {
        create_symbol(id_name,sym_type,element);
        int i;
        char checker[100];
        strcpy(checker,sym_type);
        printf("+++++++ %s\n",sym_type);
        for(i=0;i<table_index;i++){
            printf("+++++++ %s\n",sym_type);
            if(strcmp(id_name,table[i].id)==0){
                //printf("------------------%s %s %s %d %d\n",table[i].id,table[i].type, checker, table[i].addrs,i);
                if(strcmp(table[i].type,"int32")==0){
                    fprintf(f,"\tistore %d\n",i);
                }
                else if(strcmp(table[i].type,"float32")==0 && strcmp(checker,"float32")==0){
                    fprintf(f,"\tfstore %d\n",i);
                    //fprintf(f,"\tNAME %s\n",id_name);
                    //fprintf(f,"\t%d %d\n",table[i].addrs, i);
                }
                else if(strcmp(table[i].type,"array")==0 && strcmp(checker,"array")==0){
                        fprintf(f,"\tiaload\n");
                }
                else if((strcmp(table[i].type,"bool")==0) && (strcmp(checker,"bool")==0)){
                        fprintf(f,"\tistore %d\n",i);
                        //fprintf(f,"\tOREEEEEEEEEEEEEEEEEE %d\n",i);
                }
                else if(strcmp(table[i].type,"string")==0 && strcmp(checker,"string")==0){
                            fprintf(f,"\tastore %d\n",i);
                }
            }
        }        
        
        
        }
    |VAR ID Type {
            create_symbol(id_name,sym_type,element);
            printf("====================  %s\n",id_name);
            int i;
            char checker[100];
             strcpy(checker,sym_type);
            for(i=0;i<table_index;i++){
                printf("------------------%s\n",table[i].id);
                if(strcmp(id_name,table[i].id)==0){
                    printf("------------------%s %s %s %d %d\n",table[i].id,table[i].type, checker, table[i].addrs,i);
                    //printf("------------------%s\n",table[i].id);
                    if(strcmp(table[i].type,"int32")==0){
                        fprintf(f,"\tldc 0\n");
                        fprintf(f,"\tistore %d\n",i);
                    }
                    else if(strcmp(table[i].type,"float32")==0 && strcmp(sym_type,"float32")==0){
                        fprintf(f,"\tldc 0.0\n");
                        fprintf(f,"\tfstore %d\n",i);
                        //fprintf(f,"\tNAME %s\n",id_name);
                    }
                    else if(strcmp(table[i].type,"array")==0 && strcmp(sym_type,"array")==0){
                            fprintf(f,"\tiaload\n");
                    }
                    else if(strcmp(table[i].type,"string")==0 && strcmp(sym_type,"string")==0){
                            fprintf(f,"\tldc \"\"\n");
                            fprintf(f,"\tastore %d\n",i);
                    }
                    else if(strcmp(table[i].type,"bool")==0 && strcmp(sym_type,"bool")==0){
                        fprintf(f,"\tistore %d\n",i);
                        //fprintf(f,"\tOREEEEEEEEEEEEEEEEEE %d\n",i);
                    }
                    
                }
            }        
        }
    |VAR ID Array {
            create_symbol(id_name,sym_type,element);
            strcpy(var2,id_name);
            gimme_the_val(var1,var2);
            //fprintf(f,"\tOREEEEEEEEEEEEEEEEEE\n");
            int i,check;
            for(i=0;i<table_index;i++){
                    if(strcmp(var2,table[i].id)==0){
                        strcpy(temp_type2,table[i].type);
                        check = i;
                }
            }

            if(strcmp(element, "int32")==0){
                fprintf(f,"\tnewarray int\n");
                fprintf(f,"\tastore %d\n\n",check+1);
            }
            else if(strcmp(element,"float32")==0 ){
                fprintf(f,"\tnewarray float\n");
                fprintf(f,"\tastore %d\n\n",check+1);
            }
        
        }
;



Literal
    :ID        {
        printf("IDENT "); lookup_symbol(id_name); strcpy(crr,"id");
        strcpy(var2,id_name);
        gimme_the_val(var1,var2);
        printf("\n OOOOOOOOOOOOOOOOOO I called em... %s %s %d\n",var1,var2,test_num);
        //fprintf(f,"\tiadd\n");
        
        int i,check;
        for(i=0;i<table_index;i++){
                if(strcmp(var2,table[i].id)==0){
                strcpy(temp_type2,table[i].type);
                check = i;
            }
        }

        printf("YO its me fool! %s %s \n\n",temp_type1,temp_type2);
        
        if(strcmp(temp_type2,"int32")==0){
            fprintf(f,"\tiload %d\n",check);
            }
        else if(strcmp(temp_type2,"float32")==0){
            fprintf(f,"\tfload %d\n",check);
            }
        else if(strcmp(temp_type2,"array")==0){
            fprintf(f,"\taload %d\n",check+1);
            }
        else if(strcmp(temp_type2,"string")==0){
            fprintf(f,"\taload %d\n",check+1);
            }
        }
    |INT_Literal 
    |FLOAT_Literal
    |'"' STRING_LIT '"'    {
            $$ = strval; 
            printf("STRING_LIT %s\n",strval);
            strcpy(crr,"string");
            fprintf(f,"\tldc \"%s\"\n",strval);
        }
    |Bool
;


CompExpr
    : Expr LOR Expr    {printf("LOR\n");
            fprintf(f,"\tior\n");
        }
    | Expr LAND Expr   {printf("LAND\n");
        fprintf(f,"\tiand\n");
        }
    | Expr EQL Expr    {printf("EQL\n");}
    | Expr NEQ Expr    {printf("NEQ\n");}
    | Expr '<' Expr    {printf("LSS\n");}
    | Expr LEQ Expr    {printf("LEQ\n");}
    | Expr '>' Expr    {printf("GTR\n");
            if(lit_res==0){
                fprintf(f,"\tisub\n");
                fprintf(f,"\tifgt L_cmp_%d\n",cmp_counter);
                fprintf(f,"\ticonst_0\n");
                cmp_counter++;
                fprintf(f,"\tgoto L_cmp_%d\n",cmp_counter);
                fprintf(f,"\tL_cmp_%d:\n",cmp_counter-1);
                fprintf(f,"\t\ticonst_1\n");
                fprintf(f,"\tL_cmp_%d:\n\t\n",cmp_counter);
                cmp_counter++;
            }
        }
    | Expr GEQ Expr    {printf("GEQ\n");}
    | Expr '+' Expr    {printf("ADD\n");

            strcpy(var2,id_name);
            gimme_the_val(var1,var2);
            //printf("\n I called em... %s %s %d\n",var1,var2,test_num);
            //fprintf(f,"\tiadd\n");
            
            int i;
            for(i=0;i<table_index;i++){
                if(strcmp(var1,table[i].id)==0){
                    strcpy(temp_type1,table[i].type);
                }
                 if(strcmp(var2,table[i].id)==0){
                    strcpy(temp_type2,table[i].type);
                }
            

            //printf("YO its me fool! %s %s \n\n",temp_type1,crr);
            
            if(strcmp(temp_type1,"int32")==0 && strcmp(temp_type2,"int32")==0){
                fprintf(f,"\tiadd\n");
                printf("Up'n here son \n\n");
                break;
                }
            else if(strcmp(temp_type1,"int32")==0 && strcmp(temp_type2,"float32")==0){
                fprintf(f,"\tfadd\n");
                break;
                }
            else if(strcmp(temp_type1,"float32")==0 && strcmp(temp_type2,"int32")==0){
                fprintf(f,"\tfadd\n");
                break;
                }
            else if(strcmp(temp_type1,"float32")==0 && strcmp(temp_type2,"float32")==0){
                fprintf(f,"\tfadd\n");
                break;
                }
            }

        }
    | Expr '-' Expr    {printf("SUB\n");
            strcpy(var2,id_name);
            gimme_the_val(var1,var2);
            //printf("\n I called em... %s %s %d\n",var1,var2,test_num);
            //fprintf(f,"\tiadd\n");
            
            int i;
            for(i=0;i<table_index;i++){
                if(strcmp(var1,table[i].id)==0){
                    strcpy(temp_type1,table[i].type);
                }
                if(strcmp(var2,table[i].id)==0){
                    strcpy(temp_type2,table[i].type);
                }
            

           

            //printf("YO its me fool! %s %s \n\n",temp_type1,temp_type2);
            
            if(strcmp(temp_type1,"int32")==0 && strcmp(temp_type2,"int32")==0){
                fprintf(f,"\tisub\n");
                printf("Up'n here son \n\n");
                break;
                }
            else if(strcmp(temp_type1,"int32")==0 && strcmp(temp_type2,"float32")==0){
                fprintf(f,"\tfsub\n");
                break;
                }
            else if(strcmp(temp_type1,"float32")==0 && strcmp(temp_type2,"int32")==0){
                fprintf(f,"\tfsub\n");
                break;
                }
            else if(strcmp(temp_type1,"float32")==0 && strcmp(temp_type2,"float32")==0){
                fprintf(f,"\tfsub\n");
                break;
                }
            }
        }
    | Expr '/' Expr    {printf("QUO\n");
            strcpy(var2,id_name);
            gimme_the_val(var1,var2);
            //printf("\n I called em... %s %s %d\n",var1,var2,test_num);
            //fprintf(f,"\tiadd\n");
            
            int i;
            for(i=0;i<table_index;i++){
                if(strcmp(var1,table[i].id)==0){
                    strcpy(temp_type1,table[i].type);
                }
                 if(strcmp(var2,table[i].id)==0){
                    strcpy(temp_type2,table[i].type);
                }
            }

            //printf("YO its me fool! %s %s \n\n",temp_type1,temp_type2);
            
            if(strcmp(temp_type1,"int32")==0 && strcmp(temp_type2,"int32")==0){
                fprintf(f,"\tidiv\n");
                printf("Up'n here son \n\n");
                break;
                }
            else if(strcmp(temp_type1,"int32")==0 && strcmp(temp_type2,"float32")==0){
                fprintf(f,"\tfdiv\n");
                break;
                }
            else if(strcmp(temp_type1,"float32")==0 && strcmp(temp_type2,"int32")==0){
                fprintf(f,"\tfdiv\n");
                break;

                }
            else if(strcmp(temp_type1,"float32")==0 && strcmp(temp_type2,"float32")==0){
                fprintf(f,"\tfdiv\n");
                break;
                }
            else if(lit_res==0){
                fprintf(f,"\tidiv\n");
                break;
            }
            else if(lit_res==1){
                fprintf(f,"\tfdiv\n");
                break;
            }
    
    
        }
    | Expr '%' Expr    {printf("REM\n");
            strcpy(var2,id_name);
            gimme_the_val(var1,var2);
            //printf("\n I called em... %s %s %d\n",var1,var2,test_num);
            //fprintf(f,"\tiadd\n");
            
            int i;
            for(i=0;i<table_index;i++){
                if(strcmp(var1,table[i].id)==0){
                    strcpy(temp_type1,table[i].type);
                }
                 if(strcmp(var2,table[i].id)==0){
                    strcpy(temp_type2,table[i].type);
                }
            }

            //printf("YO its me fool! %s %s \n\n",temp_type1,temp_type2);
            
            if(strcmp(temp_type1,"int32")==0 && strcmp(temp_type2,"int32")==0){
                fprintf(f,"\tirem\n");
                printf("Up'n here son \n\n");
                break;
                }
            else if(strcmp(temp_type1,"int32")==0 && strcmp(temp_type2,"float32")==0){
                fprintf(f,"\tirem\n");
                break;
                }
            else if(strcmp(temp_type1,"float32")==0 && strcmp(temp_type2,"int32")==0){
                fprintf(f,"\tirem\n");
                break;
                }
            else if(strcmp(temp_type1,"float32")==0 && strcmp(temp_type2,"float32")==0){
                fprintf(f,"\tirem\n");
                break;
                }
            else if(lit_res==0 || lit_res==1){
                fprintf(f,"\tirem\n");
                break;
            }

        }
    | Expr '*' Expr    {printf("MUL\n");
            strcpy(var2,id_name);
            gimme_the_val(var1,var2);
            //printf("\n I called em... %s %s %d\n",var1,var2,test_num);
            //fprintf(f,"\tiadd\n");
            
            int i;
            for(i=0;i<table_index;i++){
                if(strcmp(var1,table[i].id)==0){
                    strcpy(temp_type1,table[i].type);
                }
                 if(strcmp(var2,table[i].id)==0){
                    strcpy(temp_type2,table[i].type);
                }
            }

            //printf("YO its me fool! %s %s \n\n",temp_type1,temp_type2);
            
            if(strcmp(temp_type1,"int32")==0 && strcmp(temp_type2,"int32")==0){
                fprintf(f,"\timul\n");
                printf("Up'n here son \n\n");
                break;
                }
            else if(strcmp(temp_type1,"int32")==0 && strcmp(temp_type2,"float32")==0){
                fprintf(f,"\tfmul\n");
                break;
                }
            
            else if(strcmp(temp_type1,"float32")==0 && strcmp(temp_type2,"int32")==0){
                fprintf(f,"\tfmul\n");
                break;
                }
            else if(strcmp(temp_type1,"float32")==0 && strcmp(temp_type2,"float32")==0){
                fprintf(f,"\tfmul\n");
                break;
                }
            else if(lit_res==0){
                fprintf(f,"\timul\n");
                break;
            }
            else if(lit_res==1){
                fprintf(f,"\tfmul\n");
                break;
            }
    
    
    }
;


Terminal
    :Terminal '[' Expr ']' {$$=$1;}
    |Literal
    |'(' Terminal ')' {$$ = $2;}
;

Type
    :INT   {strcpy(sym_type, "int32");strcpy(element,"-") ;$$ = "int32";strcpy(crr,"int32");}
    |BOOL  {strcpy(sym_type, "bool"); strcpy(element,"-") ; $$ = "bool";strcpy(crr,"bool");}
    |FLOAT {strcpy(sym_type, "float32"); strcpy(element,"-") ;  $$ = "float32";strcpy(crr,"float32");}
    |STRING    {strcpy(sym_type, "string"); strcpy(element,"-") ; $$ = "string";}
;

INT_Literal
    :INT_LIT {
        $$=int_num; 
        test_num = yyval.i_val; 
        printf("ldc %d\n",int_num); 
        fprintf(f,"\tldc %d\n",test_num); 
        strcpy(crr,"int32");
        val_for_cal[addrs_no] = test_num;
        //printf("ADDRS... %f %d\n",val_for_cal[addrs_no],addrs_no);
        addrs_no++;
        lit_res=0;
    }
;

FLOAT_Literal
    :FLOAT_LIT { 
        $$=float_num; 
        printf("FLOAT_LIT %f\n",float_num);
        fprintf(f,"\tldc %f\n",float_num);
        strcpy(crr,"float32");

        val_for_cal[addrs_no] = float_num;
        //printf("ADDRS... %f %d\n",val_for_cal[addrs_no],addrs_no);
        addrs_no++;
        lit_res=1;
    }
;

Bool
    :TRUE {
            printf("TRUE\n");
            strcpy(crr,"bool");
            lit_res=2;
            fprintf(f,"\tldc 1\n");
            //fprintf(f,"\tWASAAAAAAAAAA\n");


        }
    |FALSE {
            printf("FALSE\n");
            strcpy(crr,"bool");
            lit_res=2;
            fprintf(f,"\tldc 0\n");
        }
;

UniaryExpr
    :Terminal
    |'+' UniaryExpr   %prec UNIARY     {printf("POS\n") ;}
    |'-' UniaryExpr   %prec UNIARY    {printf("NEG\n") ;
        
        //fprintf(f,"\t%s\n\n",crr);
        if(lit_res==0){
            fprintf(f,"\tineg\n");
        }
        else if(lit_res==1){
            fprintf(f,"\tfneg\n");

        }
        
        }
    |'!' UniaryExpr   %prec UNIARY    {printf("NOT\n") ;
        fprintf(f,"\tixor\n");
        
        }
    |'!' '!' UniaryExpr           {printf("NOT\nNOT\n") ;
        fprintf(f,"\tixor\n");
        fprintf(f,"\tixor\n");
        }
    |Converter
;


FORStmt
    :FOR CompExpr '{' StatementList '}' {dump_symbol(1);}
    |FOR AssignStmt ';' CompExpr ';' Expr '{' StatementList '}' {dump_symbol(1);}
;


Converter
    :Type '(' Expr ')' {
        char intake, output;
        if(strcmp(crr,"float32")==0){
            intake = 'F';
            output = 'I';
        }else if(strcmp(crr,"int32")==0){
            intake = 'I';
            output = 'F';
        }else{
            int i;
            for(i=0;i<table_index;i++){
                if(strcmp(table[i].id,id_name)==0){
                    if(strcmp(table[i].type,"int32")==0){
                        intake = 'I';
                        output = 'F';
                        fprintf(f,"\ti2f\n");
                    }
                    if(strcmp(table[i].type,"float32")==0){
                        intake = 'F';
                        output = 'I';
                        fprintf(f,"\tf2i\n");
                    }
                }
            }
        }
        printf("%c to %c\n",intake,output);
    }
;


IFStmt
    :IF '(' CompExpr ')' 
    |IF CompExpr 
    |ELSE
;

PrintStmt
    :PRINT '(' Statement ')'    {
        printf("PRINT %s\n",crr);
        
        


        }
    |PRINTLN '(' Statement ')'  {
            check_for_arr(id_name); 
            printf("PRINTLN %s\n",crr);

                    int i; 
            int var_addrs;
                char var_type[100];
                strcpy(var_type,sym_type);
            
            for(i=0;i<table_index;i++){

                if(strcmp(id_name,table[i].id)==0){
                    var_addrs = table[i].addrs;
                    strcpy(var_type,table[i].type);
                }

                if(strcmp(table[i].type,"int32")==0 && strcmp(var_type,"int32")==0){
                    //fprintf(f,"\tiload %d\n",i);
                    fprintf(f,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
                    fprintf(f,"\tswap\n");
                    fprintf(f,"\tinvokevirtual java/io/PrintStream/println(I)V\n");
                    break;
                }

                else if(strcmp(table[i].type,"bool")==0 && strcmp(var_type,"bool")==0){
                        fprintf(f,"\tiload %d\n",i);
                        fprintf(f,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
                        fprintf(f,"\tswap\n");
                        fprintf(f,"\tifgt L_bool_%d: \n",cmp_counter);
                        fprintf(f,"\tldc \"false\"\n");
                        fprintf(f,"\tgoto L_bool_%d: \n",cmp_counter+1);
                        fprintf(f,"L_bool_%d: \n",cmp_counter);
                        fprintf(f,"\tldc \"true\"\n\n");
                        fprintf(f,"L_bool_%d: :\n",cmp_counter+1);
                        cmp_counter++;
                        fprintf(f,"\tinvokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n");
                        break;
                }

                else if(strcmp(table[i].type,"string")==0 && strcmp(var_type,"string")==0){
                        fprintf(f,"\taload %d\n",i);
                        fprintf(f,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
                        fprintf(f,"\tswap\n");
                        fprintf(f,"\tinvokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n");
                        fprintf(f,"\n");
                        break;

                }

                else if(strcmp(table[i].type,"float32")==0 && strcmp(var_type,"float32")==0){
                    //fprintf(f,"\tfload %d\n",i);
                    fprintf(f,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
                    fprintf(f,"\tswap\n");
                    fprintf(f,"\tinvokevirtual java/io/PrintStream/println(F)V\n");
                    fprintf(f,"\n");
                    break;
                }


                else if(strcmp(table[i].type,"array")==0 && strcmp(var_type,"array")==0){
                        if(strcmp(table[i].element,"int32")==0){
                            fprintf(f,"\tiaload\n");
                            fprintf(f,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
                            fprintf(f,"\tswap\n");
                            fprintf(f,"\tinvokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n");
                        }
                        else if(strcmp(table[i].element,"float32")==0){
                            fprintf(f,"\tfaload %d\n",i);
                            fprintf(f,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
                            fprintf(f,"\tswap\n");
                            fprintf(f,"\tinvokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n");
                        }

                }



                fprintf(f,"\n");

            }
        }


        
        
        
            
    
    |PRINT '(' ID ')' {printf("IDENT " );lookup_symbol(id_name);printf("PRINT %s\n",sym_type);}
    |PRINTLN '(' ID ')' {
        printf("IDENT " );
        lookup_symbol(id_name);

        int i; 
        int var_addrs;
        char var_type[100];
                strcpy(var_type,sym_type);

        printf(">>>>>>PRINTLN %s %s %s\n\n\n",sym_type,id_name,var_type);
        printf("\t~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");

        for(i=0;i<table_index;i++){

            if(strcmp(id_name,table[i].id)==0){
                var_addrs = table[i].addrs;
                strcpy(var_type,table[i].type);

            

            if(strcmp(table[i].type,"int32")==0 && strcmp(var_type,"int32")==0){
                fprintf(f,"\tiload %d\n",i);
                fprintf(f,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
                fprintf(f,"\tswap\n");
                fprintf(f,"\tinvokevirtual java/io/PrintStream/println(I)V\n");
                fprintf(f,"\n");
                break;
            }
            
            else if(strcmp(table[i].type,"bool")==0 && strcmp(var_type,"bool")==0){
                    fprintf(f,"\tiload %d\n",i);
                    fprintf(f,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
                    fprintf(f,"\tswap\n");
                    fprintf(f,"\tifgt L_bool_%d \n",cmp_counter);
                    fprintf(f,"\tldc \"false\"\n");
                    fprintf(f,"\tgoto L_bool_%d \n",cmp_counter+1);
                    fprintf(f,"L_bool_%d: \n",cmp_counter);
                    fprintf(f,"\tldc \"true\"\n\n");
                    fprintf(f,"L_bool_%d:\n",cmp_counter+1);
                    cmp_counter++;
                    cmp_counter++;
                    fprintf(f,"\tinvokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n");
                    break;
            }
                        else if(strcmp(table[i].type,"string")==0 && strcmp(var_type,"string")==0){
                    fprintf(f,"\taload %d\n",i);
                    fprintf(f,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
                    fprintf(f,"\tswap\n");
                    fprintf(f,"\tinvokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n");
                    fprintf(f,"\n");
                    break;
            }
            else if(strcmp(table[i].type,"float32")==0 && strcmp(var_type,"float32")==0){
                fprintf(f,"\tfload %d\n",i);
                fprintf(f,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
                fprintf(f,"\tswap\n");
                fprintf(f,"\tinvokevirtual java/io/PrintStream/println(F)V\n");
                fprintf(f,"\n");
                break;
                
            }


            else if(strcmp(table[i].type,"array")==0 && strcmp(var_type,"array")==0){
                    if(strcmp(table[i].element,"int32")==0){
                        fprintf(f,"\tiaload\n");
                        fprintf(f,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
                        fprintf(f,"\tswap\n");
                        fprintf(f,"\tinvokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n");
                        fprintf(f,"\n");
                        
                        
                    }
                    else if(strcmp(table[i].element,"float32")==0){
                        fprintf(f,"\tfaload\n");
                        fprintf(f,"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
                        fprintf(f,"\tswap\n");
                        fprintf(f,"\tinvokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n");
                        fprintf(f,"\n");
                        
                    }
                    
            }


            }
        }


        
        

        
        
        
        
        }
;


%%

/* C code section */
int main(int argc, char *argv[]){
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }

    yylineno = 0;
    f=fopen("hw3.j","w");
	fprintf(f,".class public Main\n");
	fprintf(f,".super java/lang/Object\n");
	fprintf(f,".method public static main([Ljava/lang/String;)V\n");
	fprintf(f,".limit stack 100\n");
	fprintf(f,".limit locals 100\n");
    yyparse();
    fprintf(f,"return\n");
 	fprintf(f,".end method\n");
 	fclose(f);
 	// if(error==1)
    // remove("Output.j");
printf("Total lines: %d\n", yylineno);
    fclose(yyin);
    return 0;
}

static void create_symbol(char name[100], char  str_type[100], char elemt[100]) {
        // char id[100];
        // char type[100];
        // char element[100]
        // int scope_depth;
        // int addrs;
        // int lineno;
        char compsamp[5] = "array";
    strcpy(table[table_index].id, name);
    strcpy(table[table_index].type, str_type);
    table[table_index].scope_depth = scope_index;
    table[table_index].addrs = table_index;
    table[table_index].lineno = yylineno;
        if(strcmp(compsamp,str_type)==0){
            table[table_index].lineno = yylineno+1;
        
        }
    strcpy(table[table_index].element,elemt);
    insert_symbol(table[table_index].id,table[table_index].scope_depth);
    table_index++;
    

}

static void insert_symbol(char name[100], int scope) {
    printf("> Insert {%s} into symbol table (scope level: %d)\n", name,scope);
}

static void lookup_symbol(char varble[100]) {
    int i = 0;
    //char compsamp[5] = "array";
    for(i = 0;i<table_index;i++){
        if(strcmp(varble,table[i].id) == 0 && (table[i].scope_depth == scope_index)){
            printf("(name=%s, address=%i)\n",table[i].id,table[i].addrs);
            strcpy(sym_type,table[i].type);
        }
    }
}

static void gimme_the_val(char var1[100],char var2[100]){
    int i = 0;
    //char compsamp[5] = "array";
    for(i = 0;i<table_index;i++){
        if(strcmp(var2,table[i].id) == 0 && (table[i].scope_depth == scope_index)){
            strcpy(var1,table[i-1].id);
        }
    } 
}

static void check_for_arr(char temp[100]){
    int i = 0;
    char compsamp[5] = "array";
    for(i = 0;i<table_index;i++){
        if(strcmp(temp,table[i].id) == 0 && (table[i].scope_depth == scope_index)){
            if(strcmp(compsamp,sym_type)==0){
            strcpy(crr,table[i].element);
            }
        }
    }
}

static void dump_symbol(int scope_index) {
    int i;
    int j = 0;
    printf("> Dump symbol table (scope level: %d)\n", scope_index);
    printf("%-10s%-10s%-10s%-10s%-10s%s\n",
           "Index", "Name", "Type", "Address", "Lineno", "Element type");

    for(i=0;i<table_index;i++){
        if(scope_index == table[i].scope_depth){
        printf("%-10d%-10s%-10s%-10d%-10d%s\n",
                j, table[i].id, table[i].type, table[i].addrs, table[i].lineno,table[i].element);
                j++;
                table[i].scope_depth = 5;
        }      
    }
}
