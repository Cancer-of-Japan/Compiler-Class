/* Definition section */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define YY_NO_INPUT
    #define YY_NO_UNPUT
    

    int line_num = 0;
    int comment_num = 0;
%}

/* Regular expression label */
letter [a-zA-Z_]
digit [0-9]
id {letter}+({letter}|{digit})*
inumber {digit}+
fnumber ({digit}*\.{digit}+)
c_comment "/*"([^*]|\*+[^*/])*\*+"/"
cpp_comment "//".*
string \"([^"]|\"\")*\"


cstart \/\* 
cend  \*\/ 
eos \.\n

%x COMMENT 
%x STRING_STATE

/* Rules part */
%%

 /* String Constant */
\"                      { BEGIN STRING_STATE; printf("%-8s \t %s\n", yytext, "QUOTA");}
<STRING_STATE>{letter}* { printf("%-8s \t %s\n", yytext, "STRING"); }
<STRING_STATE>\"        { BEGIN INITIAL; printf("%-8s \t %s\n", yytext, "QUOTA");}
 
 /* Arithmetic */
"+"     { printf("%-8s \t %s\n", yytext, "ADD"); }
"-"     { printf("%-8s \t %s\n", yytext, "SUB"); }
"*"     { printf("%-8s \t %s\n", yytext, "MUL"); }
"/"     { printf("%-8s \t %s\n", yytext, "QUO"); }
"%"     { printf("%-8s \t %s\n", yytext, "REM"); }
"++"    { printf("%-8s \t %s\n", yytext, "INC"); }
"--"    { printf("%-8s \t %s\n", yytext, "DEC"); }
 
 /* Relational */
">"     { printf("%-8s \t %s\n", yytext, "GTR"); }
"<"     { printf("%-8s \t %s\n", yytext, "LSS"); }
">="    { printf("%-8s \t %s\n", yytext, "GEQ"); }
"<="    { printf("%-8s \t %s\n", yytext, "LEQ"); }
"=="    { printf("%-8s \t %s\n", yytext, "EQL"); }
"!="    { printf("%-8s \t %s\n", yytext, "NEQ"); }
 
 /* Assignment */
"="     { printf("%-8s \t %s\n", yytext, "ASSIGN"); }
"+="    { printf("%-8s \t %s\n", yytext, "ADD_ASSIGN"); }
"-="    { printf("%-8s \t %s\n", yytext, "SUB_ASSIGN"); }
"*="    { printf("%-8s \t %s\n", yytext, "MUL_ASSIGN"); }
"/="    { printf("%-8s \t %s\n", yytext, "QUO_ASSIGN"); }
"%="    { printf("%-8s \t %s\n", yytext, "REM_ASSIGN"); }
"->"    { printf("%-8s \t %s\n", yytext, "ARR_ASSIGN"); }
 
 /* Logical */
"&&"    { printf("%-8s \t %s\n", yytext, "LAND");}
"||"    { printf("%-8s \t %s\n", yytext, "LOR"); }
"!"     { printf("%-8s \t %s\n", yytext, "NOT"); }
 
 /* Delimiters */
"("     { printf("%-8s \t %s\n", yytext, "LPAREN"); }
")"     { printf("%-8s \t %s\n", yytext, "RPAREN"); }
"{"     { printf("%-8s \t %s\n", yytext, "LBRACE"); }
"}"     { printf("%-8s \t %s\n", yytext, "RBRACE"); }
"["     { printf("%-8s \t %s\n", yytext, "LBRACK"); }
"]"     { printf("%-8s \t %s\n", yytext, "RBRACK"); }
";"     { printf("%-8s \t %s\n", yytext, "SEMICOLON"); }
","     { printf("%-8s \t %s\n", yytext, "COMMA"); }
"\""    { printf("%-8s \t %s\n", yytext, "QUOTA"); }

  /* Number Constant */
{inumber}   { printf("%-8s \t %s\n", yytext, "INT_LIT"); }
{fnumber}   { printf("%-8s \t %s\n", yytext, "FLOAT_LIT"); }

 /* Declaration Keywords */
"int32"     { printf("%-8s \t %s\n", yytext, "INT");}
"float32"   { printf("%-8s \t %s\n", yytext, "FLOAT");}
"string"    { printf("%-8s \t %s\n", yytext, "STRING");}
"bool"      { printf("%-8s \t %s\n", yytext, "BOOL");}
"var"       { printf("%-8s \t %s\n", yytext, "VAR"); }

 /* Print Keywords */   
"print"     { printf("%-8s \t %s\n", yytext, "PRINT"); }
"println"   { printf("%-8s \t %s\n", yytext, "PRINTLN"); }

 /* Condition and Loop Keywords */
"if"        { printf("%-8s \t %s\n", yytext, "IF"); }
"else"      { printf("%-8s \t %s\n", yytext, "ELSE"); }
"for"       { printf("%-8s \t %s\n", yytext, "FOR"); }



 /* boolean Keywords */
"true"      { printf("%-8s \t %s\n", yytext, "TRUE"); }
"false"     { printf("%-8s \t %s\n", yytext, "FALSE"); }



 /* Comment for C*/
"/*"                { BEGIN COMMENT; printf("%s", yytext); }
<COMMENT>\n         { printf("%-8s \t %s\n", yytext, "C Comment");  ++comment_num; ++line_num;}
<COMMENT>[^*\n]+    { printf("%s", yytext); }
<COMMENT>"*"        { printf("%s", yytext);  }
<COMMENT>"*/"       {  BEGIN INITIAL; printf("%-8s \t %s\n", yytext, "C Comment"); }
 /* C++ type Comment */
 "//".*  { printf("%-8s \t %s\n", yytext, "C++ Comment"); ++comment_num; ++line_num;}


 /* Var ID */
 {id}        { printf("%-8s \t %s\n", yytext, "IDENT"); }

 /* some other things */
 
 
 "\n"            { printf("         \t" " %s\n", "NEWLINE"); line_num++; }
 .          {;}
[ \t]       {;} /* Ignore */
[^ \t\n]    {;}
<<EOF>>     { line_num++; yyterminate(); }

%%
/*  C Code part */
int yywrap(void){
    return 1;
}

int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    yylex();
    printf("\nFinish scanning,\n");
    if(comment_num >= 1){
            printf("total line: %d\n", --line_num);
            printf("comment line: %d\n", ++comment_num);
    }
    else{ 
            printf("total line: %d\n", line_num);
            printf("comment line: %d\n", comment_num);
    }
    
    fclose(yyin);
    return 0;
}
