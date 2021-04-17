/*	Definition section */
%{
    #include "common.h" //Extern variables that communicate with lex
    // #define YYDEBUG 1
    // int yydebug = 1;

    extern int yylineno;
    extern int yylex();
    extern int int_num;
    extern int len;
    extern float float_num;
    extern char id_name[100];
    extern FILE *yyin;
    int check;

    void yyerror (char const *s)
    {
        printf("error:%d: %s\n", yylineno, s);
    }

    /* Symbol table function - you can add new function if needed. */
    static void create_symbol();
    static void insert_symbol();
    static void lookup_symbol();
    static void dump_symbol();
    
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




/* Token with return, which need to sepcify type */
%token <s_val>  INT_LIT
%token <s_val>  FLOAT_LIT
%token <s_val>  STRING_LIT
%token <s_val>  ID

/* Nonterminal with return, which need to sepcify type */
%type <i_val>   INT_Literal
%type <f_val>   Add_Expr Terminal FLOAT_Literal  Mul_Expr Samp_Expr
%type <s_val>   Bool Type Factor Array
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
    |Add_Expr
    |FORStmt
    |IFStmt
    |PrintStmt
    |NEWLINE
;

AssignStmt
    :Add_Expr '=' Add_Expr {printf("ASSIGN\n");}
    |Add_Expr ADD_ASSIGN Add_Expr {printf("ADD_ASSIGN\n");}
    |Add_Expr SUB_ASSIGN Add_Expr {printf("SUB_ASSIGN\n");}
    |Add_Expr MUL_ASSIGN Add_Expr {printf("MUL_ASSIGN\n");}
    |Add_Expr QUO_ASSIGN Add_Expr {printf("QUO_ASSIGN\n");}
    |Add_Expr REM_ASSIGN Add_Expr {printf("REM_ASSIGN\n");}
;

Array
    :'[' INT_Literal ']' Type  { strcpy(element,sym_type) ; strcpy(sym_type, "array"); $$ = "array";}
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
    :VAR ID Type '=' Add_Expr {create_symbol(id_name,sym_type,element);}
    |VAR ID Type {create_symbol(id_name,sym_type,element);}
    |VAR ID Array {create_symbol(id_name,sym_type,element);}
;



Factor
    :ID        {  printf("IDENT "); lookup_symbol(id_name); strcpy(crr,"id");}
    |INT_Literal
    |FLOAT_Literal
    |'"' STRING_LIT '"'    { $$ = strval; printf("STRING_LIT %s\n",strval);strcpy(crr,"string");}
    |Bool
    |'+' Factor            {printf("POS\n");}
    |'-' Factor            {printf("NEG\n");}
    |Converter 
;

Add_Expr
    :Mul_Expr
    |Add_Expr '+' Mul_Expr {printf("ADD\n");}
    |Add_Expr '-' Mul_Expr {printf("SUB\n");}
    |Add_Expr INC           { printf("INC\n"); }
    |Add_Expr DEC           { printf("DEC\n"); }
    |Terminal
;

Mul_Expr
    :Samp_Expr
    |Mul_Expr  '/'   Samp_Expr { printf("QUO\n");  }
    |Mul_Expr  '*'   Samp_Expr   { printf("MUL\n");  }
    |Mul_Expr  '%'   Samp_Expr { printf("REM\n");  }
    |Mul_Expr  '>'   Samp_Expr {printf("GTR\n");}
    |Mul_Expr  '<'   Samp_Expr {printf("LSS\n");}
;

Samp_Expr
    :Terminal
    | Samp_Expr GEQ   Terminal {printf("GEQ\n");}
    | Samp_Expr LEQ   Terminal {printf("LEQ\n");}
    | Samp_Expr EQL   Terminal {printf("EQL\n");}
    | Samp_Expr NEQ   Terminal {printf("NEQ\n");}
    | Samp_Expr LAND  Terminal {printf("LAND\n");}
    | Samp_Expr LOR   Terminal {printf("LOR\n");}
;


Terminal
    :Terminal        
    |Factor
    |'(' Terminal ')' {$$ = $2;}
    |Array
    |Factor '[' Add_Expr ']'
    | '(' Add_Expr ')' {$$=$2;}
;

Type
    :INT   {strcpy(sym_type, "int32");strcpy(element,"-") ;$$ = "int32";strcpy(crr,"int32");}
    |BOOL  {strcpy(sym_type, "bool"); strcpy(element,"-") ; $$ = "bool";strcpy(crr,"bool");}
    |FLOAT {strcpy(sym_type, "float32"); strcpy(element,"-") ;  $$ = "float32";strcpy(crr,"float32");}
    |STRING    {strcpy(sym_type, "string"); strcpy(element,"-") ; $$ = "string";}
;

INT_Literal
    :INT_LIT { $$=int_num; printf("INT_LIT %d\n",int_num); strcpy(crr,"int32");}
;

FLOAT_Literal
    :FLOAT_LIT { $$=float_num; printf("FLOAT_LIT %f\n",float_num); strcpy(crr,"float32");}
;

Bool
    :TRUE {printf("TRUE\n");$$ = "bool";}
    |FALSE {printf("FALSE\n");$$ = "bool";}
;


FORStmt
    :FOR CompExpr '{' StatementList '}' {dump_symbol(1);}
    |FOR AssignStmt ';' CompExpr ';' Add_Expr '{' StatementList '}' {dump_symbol(1);}
;


Converter
    :Type '(' Add_Expr ')' {
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
                    }
                    if(strcmp(table[i].type,"float32")==0){
                        intake = 'F';
                        output = 'I';
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



CompExpr
    :Add_Expr 
    |Add_Expr '>' Add_Expr   {printf("GTR\n");}
    |Add_Expr '<' Add_Expr   {printf("LSS\n");}
    |Add_Expr GEQ Add_Expr   {printf("GEQ\n");}
    |Add_Expr LEQ Add_Expr   {printf("LEQ\n");}
    |Add_Expr EQL Add_Expr   {printf("EQL\n");}
    |Add_Expr NEQ Add_Expr   {printf("NEQ\n");}
    |Add_Expr LAND Add_Expr  {printf("LAND\n");}
    |Add_Expr LOR Add_Expr   {printf("LOR\n");}
;


PrintStmt
    :PRINT '(' Statement ')'    {printf("PRINT %s\n",crr);}
    |PRINTLN '(' Statement ')'  {printf("PRINTLN %s\n",crr);}
    |PRINT '(' ID ')' {printf("IDENT " );lookup_symbol(id_name);printf("PRINT %s\n",sym_type);}
    |PRINTLN '(' ID ')' {printf("IDENT " );lookup_symbol(id_name);printf("PRINTLN %s\n",sym_type);}
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
    yyparse();

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
    char compsamp[5] = "array";
    for(i = 0;i<table_index;i++){
        if(strcmp(varble,table[i].id) == 0 && (table[i].scope_depth == scope_index)){
            printf("(name=%s, address=%i)\n",table[i].id,table[i].addrs);
            strcpy(sym_type,table[i].type);
            //  if(strcmp(compsamp,str_type)==0)[

            //  ]
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
