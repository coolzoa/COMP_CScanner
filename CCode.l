
%option noyywrap

%x COMMENT
%x IFILE

/*Universal char name*/
UCN (\\u[0-9a-fA-F]{4}|\\U[0-9a-fA-F]{8})

/*float exponente*/
EXP ([Ee][-+]?[0-9]+)

/*int length*/
ILEN ([Uu](L|l|LL|ll)?|(L|l|LL|ll)[Uu]?)

%{
	#include <stdio.h>
	#include <string.h>

	struct Token EmptyStruct;
	void escribir_tex(struct Token t);
	void new_frame();
	void cerrar_frame();
	void crear_archivo_salida();
	void cerrar_archivo_salida();
	void contador_tokens(int id);
	void str_replace(char *target, const char *needle, const char *replacement);
	void hacer_grafico_histo1();
	void hacer_grafico_histo2(int secuencia,int maximo);
	void grafico_pie();
	

	enum tokentype{
		KEYWORD = 258, //(8) declarativo y de control
		IDENTIFIER = 260,    //(1) 
		NUMBER = 261, //(2)  INTD decimal, INTO octal, INTH hexadecimal, FLOATD decimal, FLOATE exponente, FLOATH hexadecimal
		STRINGLITERAL = 262,	    //(3) STRL, CHARL
		OPERADOR = 263,	    //(4)
		PUNCTUATOR = 264,     //(5) PUNTAC PUNT
		NL = 265,	    //(6)
		END = 266	    //(7)
	};

	struct Token {
		int id;
		char* lexema; //guarda el valor tipo string
		int valor; //guarda el valor tipo numerico
		char tipo[9]; //siglas
	};

	char* lexema_actual;
	int valor_actual = -1;
	char tipo_actual[9] = {0};
	int id_actual = -1;
	int termino = 0;
	FILE *archivo_salida;
	int id8 = 0;
	int id1 = 0;
	int id2 = 0;
	int id3 = 0;
	int id4 = 0;
	int id5 = 0;
	float idf1,idf2,idf3,idf4,idf5,idf8;

	int defining; //para ver si el nombre es una definicion
%}


%%

"/*"			{BEGIN(COMMENT);}
<COMMENT>"*/"		{BEGIN(INITIAL);}
<COMMENT>([^*]|\n)+|.	{}
<COMMENT><<EOF>>	{printf("Comentario sin terminar\n");}
"//".*\n		{}


_Bool |
_Complex |
_Imaginary |
auto |
char |
const |
double | 
enum |
extern |
float |
inline | 
int |
long |
register |
restrict |
short |
signed |
static |
struct |
typedef |
union |
unsigned |
void |
volatile {id_actual = 8; lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char)); strcpy(lexema_actual,yytext); strcpy(tipo_actual,"KEYWORDD"); defining = 1; return KEYWORD;}

break |
case |
continue |
default |
do |
else |
for |
goto |
if |
return |
sizeof |
switch |
while {id_actual = 8; lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char)); strcpy(lexema_actual,yytext);strcpy(tipo_actual,"KEYWORDC"); return KEYWORD;}


0[0-7]*{ILEN}?	{id_actual = 2; lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char));strcpy(lexema_actual,yytext); valor_actual = atoi(yytext); return NUMBER;}

[1-9][0-9]*{ILEN}?	{id_actual = 2; lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char));strcpy(tipo_actual,"IDEC"); strcpy(lexema_actual,yytext); valor_actual = atoi(yytext); return NUMBER;}
0[Xx][0-9a-fA-F]+{ILEN}?	{id_actual = 2; lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char)); strcpy(tipo_actual,"IHEX"); strcpy(lexema_actual,yytext); valor_actual = atoi(yytext); return NUMBER;}


([0-9]*\.[0-9]+|[0-9]+\.){EXP}?[flFL]?	{id_actual = 2; lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char));strcpy(tipo_actual,"FLOATD"); strcpy(lexema_actual,yytext); valor_actual = atof(yytext); return NUMBER;}
[0-9]+{EXP}[flFL]?			{id_actual = 2; lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char));strcpy(tipo_actual,"FLOATE"); strcpy(lexema_actual,yytext); valor_actual = atof(yytext); return NUMBER;}


\'([^'\\]|\\['"?\\abfnrtv]|\\[0-7]{1,3}|\\[Xx][0-9a-fA-F]+|{UCN})+\' {id_actual = 3; lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char)); strcpy(lexema_actual,yytext);strcpy(tipo_actual,"CHARL"); return STRINGLITERAL;}

L?\"([^"\\]|\\['"?\\abfnrtv]|\\[0-7]{1,3}|\\[Xx][0-9a-fA-F]+|{UCN})*\" {id_actual = 3; lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char)); strcpy(lexema_actual,yytext);strcpy(tipo_actual,"STRL"); return STRINGLITERAL;}




"+"|"-"|"*"|"/"|"%" {id_actual = 4;strcpy(tipo_actual,"OPARI");strcpy(lexema_actual,yytext); return OPERADOR;}
"="|"+="|"-="|"*="|"/="|"%="|"&="|"^="|"<<="|">>="|"&="|"^="|"|=" {id_actual = 4;lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char));  strcpy(lexema_actual,yytext);strcpy(tipo_actual,"OPAS");return OPERADOR;}
">"|"<"|">="|"<="|"=="|"!="		{id_actual = 4; strcpy(tipo_actual,"OPR");lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char)); strcpy(lexema_actual,yytext); return OPERADOR;}
"&&"|"||"|"!"				{id_actual = 4;strcpy(tipo_actual,"OPL"); lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char)); strcpy(lexema_actual,yytext); return OPERADOR;}
"&"|"|"|"~"|"^"|"<<"|">>"		{id_actual = 4;strcpy(tipo_actual,"OPB");lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char)); strcpy(lexema_actual,yytext); return OPERADOR;}
"++"|"--"					{id_actual = 4;strcpy(tipo_actual,"OPDEIN"); lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char)); strcpy(lexema_actual,yytext); return OPERADOR;}
"?:"|"<:"|":>"|"<%"|"%>"|"%:%:"|"%:"					{id_actual = 4;strcpy(tipo_actual,"OPO"); strcpy(lexema_actual,yytext); return OPERADOR;}


"["|"]"|"("|")"|"{"|"}"|"."|"->" 			{id_actual = 5;lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char));  strcpy(lexema_actual,yytext);strcpy(tipo_actual,"PUNTAC");  return PUNCTUATOR;}

"?"|":"|";"|"..."|"#"|"##"|","			{id_actual = 5; lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char)); strcpy(lexema_actual,yytext);strcpy(tipo_actual,"PUNCT");  return PUNCTUATOR;}




([_a-zA-Z]|{UCN})([_a-zA-Z0-9]|{UCN})* {id_actual = 1;strcpy(tipo_actual,"ID");lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char)); strcpy(lexema_actual,yytext); return IDENTIFIER;}

[\n]	{id_actual = 6; lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char)); strcpy(lexema_actual,yytext);strcpy(tipo_actual,"NL"); return NL;}
[ \t]	{id_actual = 6; lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char)); strcpy(lexema_actual,yytext);strcpy(tipo_actual,"SPACE"); return NL;}


 



"#"" "*if.*\n 	{printf("Preprocesador if: %s\n",yytext);}
"#"" "*else.*\n	{printf("Preprocesador else: %s\n",yytext);}
"#"" "*endif.*\n {printf("Preprocesador endif: %s\n",yytext);}
"#"" "*define.*\n {printf("Preprocesador define: %s\n",yytext);}
"#"" "*line.*\n	   {printf("Preprocesador line: %s\n",yytext);}

^"#"[ \t]*include[ \t]*[\"<] {printf("Include: %s\n",yytext); BEGIN IFILE; }

<IFILE>[^>\"]+ {
			{ int c;
			  int indice = 0;
			  char filename[1024] = {0};
		
			  while((c = input()) && c != '\n');
			   }
				
			printf("Archivo include es: %s\n",yytext);
			BEGIN INITIAL;
			}

<IFILE>.|\n	{printf("Error en include\n");
			BEGIN INITIAL;
		}


.		{printf("Caracter misterioso %s \n",yytext);}


<<EOF>>		{id_actual = 7;  lexema_actual = (char *) calloc(strlen(yytext)+1,sizeof(char)); strcpy(lexema_actual,yytext); return END;}
%%

struct Token getToken(){
	int tipo_yylex = yylex();
	if (tipo_yylex != END){
		struct Token t2;
  		t2.lexema = (char*) malloc(strlen(lexema_actual));
		strcpy(t2.lexema, lexema_actual);
		strcpy(t2.tipo, tipo_actual);
		t2.id = id_actual;
		t2.valor = valor_actual;
		strcpy(lexema_actual,"");
		strcpy(tipo_actual,"");
		return t2;
	}
	else{
		termino = 1;
		return EmptyStruct;
	}
}


void escribir_tex(struct Token token){
	//printf("Id, lexema, tipo y valor: %d %s %s %d \n",token.id,token.lexema,token.tipo, token.valor);	
	if(token.id == 8){  //Keywords
		fprintf(archivo_salida,"%s%s%s \n","\\textbf{\\textcolor{DarkOrchid}{",token.lexema,"}}");
	}
	if(token.id == 1){ //Identifier
		str_replace(token.lexema,"_","\\_");
		
		//char *resultado = cambiar_palabra(token.lexema,"_","\\_");
		fprintf(archivo_salida,"%s%s%s \n","\\underline{\\textcolor{Thistle}{",token.lexema,"}}");  
	}
	if(token.id == 2){ //Number
		fprintf(archivo_salida,"%s%s%s \n","\\textcolor{CadetBlue}{",token.lexema,"}");
	}
	if(token.id == 3){ //Stringliteral
		str_replace(token.lexema,"\\n","\\\\\n");
		str_replace(token.lexema,"%","\\%");
		
		
		fprintf(archivo_salida,"%s%s%s \n","\\textit{\\textcolor{GreenYellow}{",token.lexema,"}}");
	}
	if(token.id == 4){ //Operador
		str_replace(token.lexema,"<","\\textless");
		str_replace(token.lexema,">","\\textgreater");
		if( strcmp(token.lexema,"^") == 0 ){fprintf(archivo_salida,"\\textcolor{JungleGreen}{\\textasciicircum}");}
		else if(strcmp(token.lexema,"~") == 0){fprintf(archivo_salida,"\\textcolor{JungleGreen}{$\\sim$}");}
		else if(strcmp(token.lexema,"<%") == 0 ){fprintf(archivo_salida,"\\textcolor{JungleGreen}{\\textless\\%}");}
		else if(strcmp(token.lexema,"--") == 0){fprintf(archivo_salida,"\\textcolor{JungleGreen}{-\\hspace{0.05cm}-}");}
		else if(strcmp(token.lexema,"&&") == 0){fprintf(archivo_salida,"\\textcolor{JungleGreen}{\\&\\&}");}
		else if(strcmp(token.lexema,"^=") == 0){fprintf(archivo_salida,"\\textcolor{JungleGreen}{\\textasciicircum =}");}
		else if(strcmp(token.lexema,"%:%:") == 0){fprintf(archivo_salida,"\\textcolor{JungleGreen}{\\%:\\%:}");}
		else if( strcmp(token.lexema,"%:") == 0 || strcmp(token.lexema,"%>") == 0  || strcmp(token.lexema,"&=") == 0  || strcmp(token.lexema,"&") == 0  || strcmp(token.lexema,"%") == 0  || strcmp(token.lexema,"%=") == 0 ){fprintf(archivo_salida,"\\textcolor{JungleGreen}{\\%s}",token.lexema);}
		else{ fprintf(archivo_salida,"%s%s%s \n","\\textcolor{JungleGreen}{",token.lexema,"}"); }
	}
	if(token.id == 5){ //Punctuator
		str_replace(token.lexema,"#","\\#");
		if(strcmp(token.lexema,"{") == 0 || strcmp(token.lexema,"}") == 0){fprintf(archivo_salida,"\\%s \n",token.lexema);}
		else{fprintf(archivo_salida,"%s \n",token.lexema);}
		
	}
	if(token.id == 6){ //Nl
		fprintf(archivo_salida,"%s \n","\\textcolor{black}{ } \\newline");
	}
}

void new_frame(){
	fprintf(archivo_salida,"%s \n","\\begin{frame}");
}

void cerrar_frame(){
	fprintf(archivo_salida,"%s \n","\\begin{multicols}{3}");
        fprintf(archivo_salida,"\t %s \n","\\begin{itemize}");
        fprintf(archivo_salida,"\t \t %s \n","\\item \\textcolor{DarkOrchid}{Keywords}");
        fprintf(archivo_salida,"\t \t %s \n","\\item \\textcolor{Thistle}{Identifiers}");
        fprintf(archivo_salida,"\t \t %s \n","\\item \\textcolor{CadetBlue}{Numbers}");
        fprintf(archivo_salida,"\t \t %s \n","\\item \\textcolor{GreenYellow}{String-literal}");
        fprintf(archivo_salida,"\t \t %s \n","\\item \\textcolor{JungleGreen}{Operators}");
        fprintf(archivo_salida,"\t \t %s \n","\\item \\textcolor{white}{Punctuators}");
        fprintf(archivo_salida,"\t %s \n","\\end{itemize}");
        fprintf(archivo_salida,"%s \n","\\end{multicols}");

	fprintf(archivo_salida,"%s \n \n","\\end{frame}");
}

void str_replace(char *target, const char *needle, const char *replacement)
{
    char buffer[1024] = { 0 };
    char *insert_point = &buffer[0];
    const char *tmp = target;
    size_t needle_len = strlen(needle);
    size_t repl_len = strlen(replacement);

    while (1) {
        const char *p = strstr(tmp, needle);

        // walked past last occurrence of needle; copy remaining part
        if (p == NULL) {
            strcpy(insert_point, tmp);
            break;
        }

        // copy part before needle
        memcpy(insert_point, tmp, p - tmp);
        insert_point += p - tmp;

        // copy replacement string
        memcpy(insert_point, replacement, repl_len);
        insert_point += repl_len;

        // adjust pointers, move on
        tmp = p + needle_len;
    }

    // write altered string back to target
    strcpy(target, buffer);
}



void crear_archivo_salida(){
	archivo_salida = fopen("archivo_salida.tex","w"); //w+
	fprintf(archivo_salida,"%s \n","\\documentclass[usenames,dvipsnames]{beamer}");
	fprintf(archivo_salida,"%s \n","\\usepackage{pgfplots}");
	fprintf(archivo_salida,"%s \n","\\usepackage{calc}");
	fprintf(archivo_salida,"%s \n","\\usepackage{ifthen}");
	fprintf(archivo_salida,"%s \n","\\usepackage{tikz}");
	fprintf(archivo_salida,"%s \n","\\pgfplotsset{compat=1.13}");
	fprintf(archivo_salida,"%s \n","\\usepackage{xcolor}");
	fprintf(archivo_salida,"%s \n","\\usepackage[utf8]{inputenc}");
	fprintf(archivo_salida,"%s \n \n \n","\\usepackage{multicol}");
	fprintf(archivo_salida,"%s \n","\\usepackage{lmodern}");
	fprintf(archivo_salida,"%s \n","\\setbeamercolor{normal text}{bg=black} %fondo negro");
	fprintf(archivo_salida,"%s \n","\\setbeamercolor{normal text}{fg=white} %letras blancas");
	fprintf(archivo_salida,"%s \n","\\setbeamercolor{white back}{bg=white} %fondo en graficos blanco");
	fprintf(archivo_salida,"%s \n","\\setbeamercolor{frametitle}{fg=Cyan} % titulos cyan");
	fprintf(archivo_salida,"%s \n \n","\\setbeamercolor*{title}{fg=Cyan} %titulo principal cyan");
	fprintf(archivo_salida,"%s \n","\\title{Proyecto 1}");
	fprintf(archivo_salida,"%s \n","\\author{Jos\\'e Pablo Murillo Vargas, Nicol Morice Sand\\'i}");
	fprintf(archivo_salida,"%s \n","\\institute[VFU]");
	fprintf(archivo_salida,"%s \n","{");
	fprintf(archivo_salida,"%s \n","\\inst{}");
	fprintf(archivo_salida,"%s \n","Instituto T\\'ecnol\\'ogico de Costa Rica");
	fprintf(archivo_salida,"%s \n","\\and");
	fprintf(archivo_salida,"%s \n","\\inst{}");
	fprintf(archivo_salida,"%s \n","Escuela de Ingenier\\'ia en Computaci\\'on");
	fprintf(archivo_salida,"%s \n","\\and");
	fprintf(archivo_salida,"%s \n","\\inst{}");
	fprintf(archivo_salida,"%s \n","Compiladores e Int\\'erpretes");
	fprintf(archivo_salida,"%s \n","}");
	fprintf(archivo_salida,"%s \n \n","\\date{19-09-2017}"); 
	fprintf(archivo_salida,"%s \n \n","\\begin{document}");
	fprintf(archivo_salida,"%s \n \n","\\frame{\\titlepage}");
	fprintf(archivo_salida,"%s \n","\\begin{frame}");
	fprintf(archivo_salida,"%s \n","\\frametitle{Explicaci\\'on del Scanner}");
	fprintf(archivo_salida,"%s \n","El scanning, o an\\'alisis l\\'exico es el proceso por el cu\\'al se toma el archivo fuente y se intenta de romper en pedacitos significativos llamados tokens.\\\\[0.2cm]");
	fprintf(archivo_salida,"%s \n","Los scanners funcionan al buscar patronos de car\\'acteres dentro del fuente. Una forma de expresar estos patronos es por medio de las \\textbf{expresiones regulares}. Por ejemplo el patrón [1-9][0-9]* ser\\'ia un patr\\'on \\'util para encontrar todos los n\\'umeros enteros dentro del archivo fuente.");
	fprintf(archivo_salida,"%s \n \n","\\end{frame}");
	fprintf(archivo_salida,"%s \n","\\begin{frame}");
	fprintf(archivo_salida,"%s \n","\\frametitle{Explicaci\\'on de Flex}");
	fprintf(archivo_salida,"%s \n","Flex (Fast lexical analyzer generator) es un programa que genera los analizadores l\\'exicos o scanners. Su prop\\'osito era mejorar las deficiencias y pulgas de Lex. \\\\[0.2cm]");
	fprintf(archivo_salida,"%s \n","Flex fue escrito originalmente por Jef Poskanzer y luego fu\\'e mejorado por Vern Paxson y Van Jacobson. \\\\[0.2cm]");
	fprintf(archivo_salida,"%s \n","Un programa en flex es usar un conjunto de expresiones regulares y escribir que acciones debe tomar cu\\'ando encuentre uno de estos en el fuente.\\\\[0.2cm]");
	fprintf(archivo_salida,"%s \n","Flex tambi\\'en traduce todas las expresiones regulares en una forma interna eficiente que le permite hacer match simult\\'aneo de todos los patrones con el archivo fuente.");
	fprintf(archivo_salida,"%s \n \n","\\end{frame}");
}


void cerrar_archivo_salida(){
	fprintf(archivo_salida,"%s \n","\\end{document}");
	fclose(archivo_salida);
	system("pdflatex archivo_salida.tex");
	system("evince archivo_salida.pdf");
}

void contador_tokens(int id){
	if(id == 8){id8++;}
	if(id == 1){id1++;}
	if(id == 2){id2++;}
	if(id == 3){id3++;}
	if(id == 4){id4++;}
	if(id == 5){id5++;}
}

void grafico_pie(){
	idf1 = id1; idf2 = id2;idf3 = id3; idf4 = id4;idf5 = id5; idf8 = id8;
	
	fprintf(archivo_salida,"%s \n","\\newcommand{\\slice}[5]{");
	fprintf(archivo_salida,"%s \n ","\\pgfmathparse{0.5*#1+0.5*#2}");
	fprintf(archivo_salida,"%s \n ","\\let\\midangle\\pgfmathresult");
	fprintf(archivo_salida,"%s \n ","\\draw[thick,fill=#5] (0,0) -- (#1:1) arc (#1:#2:1) -- cycle;");
	fprintf(archivo_salida,"%s \n ","\\node[label=\\midangle:#4] at (\\midangle:1) {};");
	fprintf(archivo_salida,"%s \n ","\\pgfmathparse{min((#2-#1-10)/110*(-0.3),0)}");
	fprintf(archivo_salida,"%s \n ","\\let\\temp\\pgfmathresult");
	fprintf(archivo_salida,"%s \n ","\\pgfmathparse{max(\\temp,-0.5) + 0.8}");
	fprintf(archivo_salida,"%s \n ","\\let\\innerpos\\pgfmathresult");
	fprintf(archivo_salida,"%s \n ","\\node at (\\midangle:\\innerpos) {#3};");
	fprintf(archivo_salida,"%s \n ","}");

	fprintf(archivo_salida,"%s \n \n","\\begin{frame}");

	fprintf(archivo_salida,"%s \n ","\\begin{tikzpicture}[scale=3]");

	fprintf(archivo_salida,"%s \n ","\\newcounter{a}");
	fprintf(archivo_salida,"%s \n ","\\newcounter{b}");

	fprintf(archivo_salida,"%s%.0f%s%.0f%s%.0f%s \n ","\\foreach \\p/\\t/\\c in {",idf8/(idf8+idf1+idf2+idf3+idf4+idf5

)*100,"/Keyword/DarkOrchid, ",idf1/(idf8+idf1+idf2+idf3+idf4+idf5

)*100,"/Identifier/Thistle, ",idf2/(idf8+idf1+idf2+idf3+idf4+idf5

)*100,"/Constant/CadetBlue,");
	fprintf(archivo_salida,"%s%.0f%s%.0f%s%.0f%s \n "," ",idf3/(idf8+idf1+idf2+idf3+idf4+idf5

)*100,"/String-literal/GreenYellow, ",idf4/(idf8+idf1+idf2+idf3+idf4+idf5

)*100,"/Operador/JungleGreen, ",idf5/(idf8+idf1+idf2+idf3+idf4+idf5

)*100,"/Punctuator/Apricot}");
	fprintf(archivo_salida,"%s \n ","  {");
	fprintf(archivo_salida,"%s \n ","\\setcounter{a}{\\value{b}}");
	fprintf(archivo_salida,"%s \n ","\\addtocounter{b}{\\p}");
	fprintf(archivo_salida,"%s \n ","\\slice{\\thea/100*360}");
	fprintf(archivo_salida,"%s \n ","{\\theb/100*360}");
	fprintf(archivo_salida,"%s \n ","{\\p\\%}{\\t}{\\c}");
fprintf(archivo_salida,"%s \n ","  }");

fprintf(archivo_salida,"%s \n ","\\end{tikzpicture}");


	fprintf(archivo_salida,"%s \n","\\end{frame}");
}

void hacer_grafico_histo1(){
	//id8 = 1000; id1 = 3000; id2 = 500; id3 = 350; id4 = 4000; id5 = 7890;
	int max = 700;
	int secuencia;
	int terminar = 0;
	if(id8 < 500 && id1 < 500 && id2 < 500 && id3 < 500 && id4 < 500 && id5 < 500){ secuencia = 50; max = 500;terminar =1;}
	while(terminar == 0){
		if(id8 < max && id1 < max && id2 < max && id3 < max && id4 < max && id5 < max){
			secuencia = max/7;
			terminar = 1;
		}
		else{
			max = max + 700;
		}	
	}
	hacer_grafico_histo2(secuencia,max);
	
}


void hacer_grafico_histo2(int secuencia,int maximo){
	//printf("Secuencia: %d Maximo: %d \n",secuencia,maximo);

	fprintf(archivo_salida,"%s \n","\\usebeamercolor[bg]{white back}");
	fprintf(archivo_salida,"%s \n \n","\\begin{frame}");
	fprintf(archivo_salida,"%s \n","\\begin{figure}");
	fprintf(archivo_salida,"%s \n","\\centering");
	fprintf(archivo_salida,"%s \n","\\begin{tikzpicture}");
	fprintf(archivo_salida,"%s \n","\\begin{axis}[");
	fprintf(archivo_salida,"%s \n","    xbar stacked,");
	fprintf(archivo_salida,"%s \n","    legend style={");
	fprintf(archivo_salida,"%s \n","    legend columns=4,");
	fprintf(archivo_salida,"%s \n","	at={(xticklabel cs:0.5)},");
	fprintf(archivo_salida,"%s \n","	anchor=north,");
	fprintf(archivo_salida,"%s \n","	draw=none");
	fprintf(archivo_salida,"%s \n","    },");
	fprintf(archivo_salida,"%s \n","    ytick=data,");
	fprintf(archivo_salida,"%s \n","    axis y line*=none,");
	fprintf(archivo_salida,"%s \n","    axis x line*=bottom,");
	fprintf(archivo_salida,"%s \n","    tick label style={font=\\footnotesize},");
	fprintf(archivo_salida,"%s \n","    legend style={font=\\footnotesize},");
	fprintf(archivo_salida,"%s \n","    label style={font=\\footnotesize},");
	fprintf(archivo_salida,"%s%d%s%d%s \n","    xtick={0,",secuencia,",...,",maximo,"},");
	fprintf(archivo_salida,"%s \n","    width=.9\\textwidth,");
	fprintf(archivo_salida,"%s \n","    bar width=6mm,");
	fprintf(archivo_salida,"%s \n","    yticklabels={{Keyword},");
	fprintf(archivo_salida,"%s \n","    {Identifier},");
	fprintf(archivo_salida,"%s \n","    {Number},");
	fprintf(archivo_salida,"%s \n","    {String literal},"); 
	fprintf(archivo_salida,"%s \n","    {Operador},"); 
	fprintf(archivo_salida,"%s \n","    {Punctuator}},");
	fprintf(archivo_salida,"%s \n","    xmin=0,");
	fprintf(archivo_salida,"%s%d%s \n","    xmax=",maximo,","); 
	fprintf(archivo_salida,"%s \n","    area legend,");
	fprintf(archivo_salida,"%s \n","    y=8mm,");
	fprintf(archivo_salida,"%s \n","    enlarge y limits={abs=0.725},"); 
	fprintf(archivo_salida,"%s \n","    nodes near coords,");
	fprintf(archivo_salida,"%s \n","    nodes near coords style={text=white, at ={(\\pgfplotspointmeta,\\pgfplotspointy)},anchor=west},");
	fprintf(archivo_salida,"%s \n","    visualization depends on=y \\as \\pgfplotspointy,");
	fprintf(archivo_salida,"%s \n","    every axis plot/.append style={fill}");
	fprintf(archivo_salida,"%s \n","]");
	fprintf(archivo_salida,"%s \n","\\addplot[DarkOrchid] coordinates");
	fprintf(archivo_salida,"%s%d%s \n","  {(",id8,",0) (0,1) (0,2) (0,3) (0,4) (0,5)};"); //cantidad de keywords
	fprintf(archivo_salida,"%s \n","\\addplot[Thistle] coordinates");
	fprintf(archivo_salida,"%s%d%s \n","  {(0,0) (",id1,",1) (0,2) (0,3) (0,4) (0,5)};"); //cantidad de identifiers
	fprintf(archivo_salida,"%s \n","\\addplot[CadetBlue] coordinates");
	fprintf(archivo_salida,"%s%d%s \n","  {(0,0) (0,1) (",id2,",2) (0,3) (0,4) (0,5)};"); //cantidad de number
	fprintf(archivo_salida,"%s \n","\\addplot[GreenYellow] coordinates");
	fprintf(archivo_salida,"%s%d%s \n","  {(0,0) (0,1) (0,2) (",id3,",3) (0,4) (0,5)};"); //cantidad de string-literal
	fprintf(archivo_salida,"%s \n","\\addplot[JungleGreen] coordinates");
	fprintf(archivo_salida,"%s%d%s \n","  {(0,0) (0,1) (0,2) (0,3) (",id4,",4) (0,5)};"); //cantidad de operador
	fprintf(archivo_salida,"%s \n","\\addplot[Apricot] coordinates");
	fprintf(archivo_salida,"%s%d%s \n","  {(0,0) (0,1) (0,2) (0,3) (0,4) (",id5,",5)};"); //cantidad de punctuator
	fprintf(archivo_salida,"%s \n","\\end{axis}");
	fprintf(archivo_salida,"%s \n \n","\\end{tikzpicture}");
	fprintf(archivo_salida,"%s \n","\\label{fig:stats}");
	fprintf(archivo_salida,"%s \n \n","\\end{figure}");
	fprintf(archivo_salida,"%s \n","\\end{frame}");
}



int main (int argc, char** argv)
{
	crear_archivo_salida();
	struct Token t;
	int num_nl = 0; 
	new_frame();
	while(termino == 0){
	   t = getToken();
	   if(t.id != EmptyStruct.id && num_nl < 11){
		if(t.id == 6){
			if(strcmp(t.tipo,"NL") == 0){num_nl++;escribir_tex(t);}	 
			if(num_nl == 10) {num_nl = 0; cerrar_frame(); new_frame();
			}	
		}else{escribir_tex(t); contador_tokens(t.id);}

	   }
	}
	cerrar_frame();
	hacer_grafico_histo1();	
	grafico_pie();
	cerrar_archivo_salida();
		
}

