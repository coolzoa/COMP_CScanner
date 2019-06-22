#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#define MAXARCHIVOS 10
#define MAXCHARS 1024


typedef struct nodo nodo;

struct nodo{
	char nombre[100];
	char valor[100];
	char tipo[100];
    nodo* siguiente;
};

//Variables-----------------------------------------------------------------------------------

nodo* primero = NULL;
nodo* ultimo = NULL;
int validacion_entrada = 1;
FILE** archivos;
FILE *archivo_salida;
int indice_pila = -1;
char buffer[MAXCHARS];
const char* compilar= "flex CCode.l";
const char* compilar2 = "cc lex.yy.c -lfl -o ejecutable";
const char* ejecutar = " ./ejecutable < archivo_salida.c";




//declararion de funciones--------------------------------------------------------------------
void crear_archivo_salida();
void cerrar_archivo_salida();
void validar_entrada(int argc, char** argv);
void reset();
void agregar_archivo(char* nombre_archivo);
void limpiar_buffer();
void validar_include(char* tira);
void validar_define(char* tira);
void agregar_archivo2(char* nombre_archivo);
void agregar_define(char* nombre, char* valor);
void imprimir();
void analizar_buffer(char* linea);
void realizar_lectura(FILE* archivo1);
int ver_existencia(nodo* nodo1);
char *cambiar_palabra(char *fila, char *encontrar, char *reemplazo);
char *encontrar_defines(char *linea);
char *encontrar_valor(char *linea);
char *encontrar_nombre(char *linea);
void cambiar_en_tabla(char *nombre, char *valor);





//implementacion de funciones-------------

void crear_archivo_salida(){
	archivo_salida = fopen("archivo_salida.c","w"); //w+
}

void cerrar_archivo_salida(){
	fclose(archivo_salida);
}




//funcion que setea variables a valores predefinidos
void reset(){
	
	validacion_entrada = 1;
	archivos = malloc(sizeof(FILE*) * MAXARCHIVOS);
	indice_pila = -1;
	
}

//funcion que valida que se este ingresando un archivo.c de entrada estandar
void validar_entrada(int argc, char** argv){
	reset();
	
	if (argc != 2){
		printf("Error, se debe pasar exactamente el nombre de un archivo seguido de .c\n");
	}else{
		char* nombre_archivo = argv[argc-1];
		int largo_nombre_archivo = strlen(nombre_archivo);
		
		//revisamos si archivo termina en .c
		if (nombre_archivo[largo_nombre_archivo-1] == 'c'  && nombre_archivo[largo_nombre_archivo-2] == '.'){
				validacion_entrada = 0;
				agregar_archivo(nombre_archivo);
				realizar_lectura(archivos[0]);
				fclose(archivos[0]);
		}else{
				printf("Debe ingresar un archivo con extension .c \n");
		}
	}
}




//funcion para abrir includes
void agregar_archivo2(char* nombre_archivo){
	FILE* archivo;
	archivo = fopen(nombre_archivo,"r");
	if(archivo){
		archivos[++indice_pila] = archivo;
		int num_indice = indice_pila;
		//printf("#include %s \n",nombre_archivo); 
		fprintf(archivo_salida,"//#include %s \n",nombre_archivo);
		realizar_lectura(archivo); 
		printf("Indice: %d \n",num_indice);
		fclose(archivos[num_indice]);
		}
	else{
		printf("Error en el include %s \n",nombre_archivo);
		}	
}

void agregar_archivo(char* nombre_archivo){

	archivos[++indice_pila] = fopen(nombre_archivo,"r");
	//printf("Archivo agregado %s \n",nombre_archivo);
	
}



//funcion que limpia buffer
void limpiar_buffer(){
	int i;
	for (i = 0; i < MAXCHARS; i++){
		buffer[i] = 0;
	}
}


//funcion que realizar lectura de archivos
void realizar_lectura(FILE* archivo_actual){	
	int indice_buffer = 0;
	char c;
	limpiar_buffer();
	
		while(1){
				c = getc(archivo_actual);
				
				if (c == '\n'){
                          
						analizar_buffer(buffer);
						limpiar_buffer();
						indice_buffer = 0;
						
				}else if(c == EOF){
						break;
				}
				buffer[indice_buffer++] = c;
		}

}


void validar_include(char* tira){
	 int n = 0; 
     while(1){
		 if (isspace(tira[n])){
			 n++;
			}else{
			break;
			}								 
	} if(tira[n] == '#'){n=n+9;}
	 int indice =0;
	 char nombre[MAXCHARS];
	 //limpiar el nombre
	 int p;
	 for (p = 0; p < MAXCHARS; p++){
		nombre[p] = 0;
 	 } 
	 while(1){
		 if (isspace(tira[n])){
			 n++;
		 }else{
			if (tira[n] == '/' && tira[n+1] == '*'){
				n++;
				n++;
				while (tira[n] != '*' && tira[n+1] != '/'){
					n++;
				}
				n++;
				n++;

			}else{
				break;
			}								 
		 }
	}

	
	
	if((tira[n] != '"') ){ if((tira[n] == '<') ){ fprintf(archivo_salida,"%s \n",tira); //printf("%s \n",tira); //aqui poner en el archivo
		} else {printf("Error en el include \n");}}
	else{
   
		n++;
		 while(1){
			 if(tira[n] == 0){printf("Error en el include \n"); break;}
			 if ( (tira[n] == '"') ){
				 agregar_archivo2(nombre);  //Aqui trata de abrir con el nombre y si esta incorrecto no lo guardamos
				 break;			 
				}else{
					
				nombre[indice++] = tira[n];}
			n++;
		}}
	 
	}
	
void validar_define(char* tira){
	int n = 0; 
     while(1){
		 if (isspace(tira[n])){
			 n++;

		 }else{
			if (tira[n] == '/' && tira[n+1] == '*'){
				n++;
				n++;
				while (tira[n] != '*' && tira[n+1] != '/'){
					n++;
				}
				n++;
				n++;

			}else{
				break;
			}								 
		 }
   								 
	} if(tira[n] == '#'){n=n+7;}
	 int indice =0;
	 int indice2 =0;
	 char nombre[MAXCHARS];
	 char nombre2[MAXCHARS];
	 //limpiar los nombres
	 int p;
	 for (p = 0; p < MAXCHARS; p++){
		nombre[p] = 0;
		nombre2[p] = 0;
 	 } 
	 while(1){
		 if (isspace(tira[n])){
			 n++;
			}else{
			break;
			}								 
	}
	if(! isalpha(tira[n]) ){ printf("Error en el define \n"); }
	else{	   
		 while(1){
			 if (isspace(tira[n])){
				
				 break;			 
				}else{					
				nombre[indice++] = tira[n];}
			n++;
		 } 
		 	    if(tira[n] == 0){ printf("Error en el define \n");}
		 else{	
		 while(1){
			 if (isspace(tira[n])){
				 n++;
				 }
				 else{ break;}			 
			 } 
		while(1){
			if(tira[n] == 0){
				 agregar_define(nombre,nombre2);
				 break;
				}
			else{
				nombre2[indice2++] = tira[n];
				n++;
				}
			}		 
		}}
}
	
	
void agregar_define(char* nombre, char* valor){
	nodo* nuevo = (nodo*) malloc(sizeof(nodo));
	strcpy(nuevo->nombre,nombre);
	strcpy(nuevo->tipo,"define");
	//ver si el valor es un define previo 
	char *nuevo_valor;
		nuevo_valor = encontrar_valor(valor);
		if(strcmp(nuevo_valor,"")){
			char *nombre2 = encontrar_nombre(valor);
			  nuevo_valor = cambiar_palabra(valor,nombre2,nuevo_valor);
			  strcpy(nuevo->valor,nuevo_valor);
			  fprintf(archivo_salida,"//#define %s %s \n",nombre,nuevo->valor);
			}else{	
				nodo* actual = primero;
				int distinto =1;
				while(actual != NULL && strcmp(actual->tipo,"define") == 0){
					
				if(strcmp(valor,actual->nombre) == 0){ //son iguales
					  strcpy(nuevo->valor,actual->valor);
					  fprintf(archivo_salida,"//#define  %s %s \n",nombre,nuevo->valor);
					  distinto = 0;
					  break;
					}						
				actual = actual->siguiente;		
				}
				if(distinto == 1){ //no se habian definido antes
						strcpy(nuevo->valor,valor);
						fprintf(archivo_salida,"//#define  %s %s \n",nombre,nuevo->valor);}
				}	
	nuevo->siguiente = NULL;
	if( ver_existencia(nuevo) == 1){
		if(primero == NULL){ primero = nuevo;}
		else{ 
			nodo* nodo_actual = primero; 
			while(nodo_actual->siguiente != NULL){
				nodo_actual = nodo_actual->siguiente;
			}
			nodo_actual->siguiente = nuevo;
		}
		
	}else{cambiar_en_tabla(nombre,nuevo->valor); printf("Warning : Ya existe un define llamado %s \n",nombre);}
}



void cambiar_en_tabla(char *nombre, char *valor) {
	nodo* actual = primero;
	while(actual != NULL){
		if(strcmp(actual->nombre,nombre) == 0){
			strcpy(actual->valor,valor);
			//printf("Cambie  %s por el nuevo valor %s \n",actual->nombre,actual->valor);
		} 
		actual = actual->siguiente;		
		}	

	
}




void imprimir(){
	nodo* actual = primero;
	while(actual != NULL){
		printf("tipo, nombre y valor: %s %s %s \n",actual->tipo,actual->nombre,actual->valor); 
		actual = actual->siguiente;		
		}	
}

int ver_existencia(nodo* nodo1){ //si regresa un 0 lo encontro, de da un 1 no lo encontro
	nodo* actual = primero;
	while(actual != NULL){
		if(strcmp(actual->nombre,nodo1->nombre) == 0){
			return 0;}
		actual = actual->siguiente;		
		}	
	return 1;	
}

void analizar_buffer(char* linea){
	int n=0;
	//Ver si hay espacios al inicio
	while(1){
		if (isspace(linea[n])){
			 n++;
		}else{
			break;
		}								 
	}
	//Ver si es un #include o un #define
	if(linea[n] == '#'){
		if(linea[n+1] == 'd' && linea[n+2] == 'e' && linea[n+3] == 'f' && linea[n+4] == 'i' && linea[n+5] == 'n' && linea[n+6] == 'e' && linea[n+7] == ' '){
			validar_define(linea);}
		if(linea[n+1] == 'i' && linea[n+2] == 'n' && linea[n+3] == 'c' && linea[n+4] == 'l' && linea[n+5] == 'u' && linea[n+6] == 'd' && linea[n+7] == 'e' && linea[n+8] == ' '){
			validar_include(linea);}
	}else{
			char *nuevo_valor;
			nuevo_valor = encontrar_valor(linea);
			//no encontro valor
			if(strcmp(nuevo_valor,"") == 0){
					fprintf(archivo_salida,"%s\n",linea);
			}	
			else{ //si encontro valor 
				  char *nombre = encontrar_nombre(linea);
				  while(strcmp(nombre,"")){				 
					  linea = cambiar_palabra(linea,nombre,nuevo_valor);
					  nuevo_valor = encontrar_valor(linea);
					  if(strcmp(nuevo_valor,"")){// encontro otro valor	
						nombre = encontrar_nombre(linea);	
					  }else{nombre = "";}	//ya no encontro valor, salir del while	  
					  
					}
				   fprintf(archivo_salida,"%s \n",linea);
				  
				}
			}
	}

	

char *encontrar_defines(char *linea){
	nodo* actual = primero;
	char *result = linea;
	while(actual != NULL && strcmp(actual->tipo,"define") == 0){
		result = cambiar_palabra(result,actual->nombre,actual->valor);
		actual = actual->siguiente;		
		}

	return 	result;
	}
	

char *encontrar_valor(char *linea){
	nodo* actual = primero;
	char* temporal = NULL;
	while(actual != NULL && strcmp(actual->tipo,"define") == 0){
		//+
		asprintf(&temporal, "%s%s", actual->nombre,"+");
		if (strstr(linea, temporal) != NULL) {
			return actual->valor;
		}
		//-
		asprintf(&temporal, "%s%s", actual->nombre,"-");
		if (strstr(linea, temporal) != NULL) {
			return actual->valor;
		}
		//*
		asprintf(&temporal, "%s%s", actual->nombre,"*");
		if (strstr(linea, temporal) != NULL) {
			return actual->valor;
		}
		//  /
		asprintf(&temporal, "%s%s", actual->nombre,"/");
		if (strstr(linea, temporal) != NULL) {
			return actual->valor;
		}
		// =
		asprintf(&temporal, "%s%s", actual->nombre,"=");
		if (strstr(linea, temporal) != NULL) { 
			printf("Error , no se puede redefinir el define %s \n",actual->nombre);
		}
		// espacio
		asprintf(&temporal, "%s%c", actual->nombre,' ');		
		if (strstr(linea, temporal) != NULL) { 
			return actual->valor;
		}
		// espacio 2
		asprintf(&temporal, "%c%s",' ', actual->nombre);		
		if (strstr(linea, temporal) != NULL) { 
			return actual->valor;
		}
		// espacio 3
		asprintf(&temporal, "%c%s%c",' ', actual->nombre,' ');		
		if (strstr(linea, temporal) != NULL) { 
			return actual->valor;
		}
		// ;
		asprintf(&temporal, "%s%s", actual->nombre,";");
		if (strstr(linea, temporal) != NULL) { 
			return actual->valor;
		}
		//si es exactamente igual
		//printf("linea:%s? nombreactual:%s? soniguales: %d \n",linea,actual->nombre,strcmp(linea, actual->nombre));
		if (strcmp(linea, actual->nombre) == 0) { 
			return actual->valor;
		}
		//Salto de linea antes
		asprintf(&temporal, "%c%s",'\n', actual->nombre);
		if(strcmp(linea, temporal) == 0){
			return actual->valor;
		}
		actual = actual->siguiente;		
		}
	return 	"";
	}
	
char *encontrar_nombre(char *linea){
	nodo* actual = primero;
	char* temporal = NULL;
	while(actual != NULL && strcmp(actual->tipo,"define") == 0){
		//+
		asprintf(&temporal, "%s%s", actual->nombre,"+");
		if (strstr(linea, temporal) != NULL) {
			return actual->nombre;
		}
		//-
		asprintf(&temporal, "%s%s", actual->nombre,"-");
		if (strstr(linea, temporal) != NULL) {
			return actual->nombre;
		}
		//*
		asprintf(&temporal, "%s%s", actual->nombre,"*");
		if (strstr(linea, temporal) != NULL) {
			return actual->nombre;
		}
		//  /
		asprintf(&temporal, "%s%s", actual->nombre,"/");
		if (strstr(linea, temporal) != NULL) {
			return actual->nombre;
		}
		// =
		asprintf(&temporal, "%s%s", actual->nombre,"=");
		if (strstr(linea, temporal) != NULL) { 
			printf("Error , no se puede redefinir el define %s \n",actual->nombre);
		}
		// espacio
		asprintf(&temporal, "%s%c", actual->nombre,' ');		
		if (strstr(linea, temporal) != NULL) { 
			return actual->nombre;
		}
		// espacio 2
		asprintf(&temporal, "%c%s",' ', actual->nombre);		
		if (strstr(linea, temporal) != NULL) { 
			return actual->nombre;
		}
		// espacio 3
		asprintf(&temporal, "%c%s%c",' ', actual->nombre,' ');		
		if (strstr(linea, temporal) != NULL) { 
			return actual->nombre;
		}
		// ;
		asprintf(&temporal, "%s%s", actual->nombre,";");
		if (strstr(linea, temporal) != NULL) { 
			return actual->nombre;
		}
		// si es exactamente igual
		if (strcmp(linea, actual->nombre) == 0) { 
			return actual->nombre;
		}
		//Salto de linea antes
		asprintf(&temporal, "%c%s",'\n', actual->nombre);
		if(strcmp(linea, temporal) == 0){
			return actual->nombre;
		}
		actual = actual->siguiente;		
	
	}
		

	return 	"";
	}



char *cambiar_palabra(char *fila, char *encontrar, char *reemplazo)
{
    char *cambio = malloc (strlen(fila)-strlen(encontrar)+strlen(reemplazo)+1);
    char *ptr;

    strcpy (cambio, fila);

    ptr = strstr (cambio, encontrar);
    if (ptr)
    {
        memmove (ptr+strlen(reemplazo), ptr+strlen(encontrar), strlen(ptr+strlen(encontrar))+1);
        strncpy (ptr, reemplazo, strlen(reemplazo));
    }
    return cambio;
}
	
	
	


int main(int argc, char** argv){
	crear_archivo_salida();

	validar_entrada(argc, argv);
	
	//free(archivos);
	
	imprimir();
	
	cerrar_archivo_salida();
	
	system(compilar);
	system(compilar2);
	system(ejecutar);
	
	return 0;
}


