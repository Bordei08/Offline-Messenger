   %{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include<sys/types.h>
#include<sys/stat.h>

extern FILE* yyin;
extern char* yytext;
extern int yylineno;


int fd;
int nr_functii=0;
int count=0;
int nr_structs=0;
//int nr_classes = 0;
int f = 0; int f_s=0;
char buf[10000];
int size;
struct container{
    char *id ;
    char *tip;
    int constant;
    int func_type;
    int struct_type;
   // int class_type;
    int isId;
}contain[100];

struct var{
    int value;
    char * type;
    char * name;
    char * str;
    int constant;
    int changed;
    int func_type;
    int struct_type;
    int class_type;
    int vector_type;
    int acces_type;

};
struct filter {
   int integer;
   int boolean;
   int character;
   int string;
   int floating;
};

struct structuri{
    struct var vars[100];
    char *name;
    int nr_vars;
}structs[100];
/*
struct clase{
    struct var vars[100];
    char * name;
    int nr_vars;
}classes[100];
*/
struct function{
    char *type;
    char * name;
    //container unde retin parametri
    struct container contain[100];
    int nr_args;
    int nr_vars;
    //variabile
    struct var vars[500];
};

struct function functions[500];
int k =0 ; int k_s=0;
int accept =1;

void isAccepted(){
    if(accept==1){
        printf("Code is accepted\n");
    }
    else{
        printf("Code is not accepted\n");
    }
}

void  print (int notEmpty ,  char *value){
    
    if(notEmpty==1){
        if(accept==1)
            printf("  %s \n",  value);
  
   }
}

void push_str(char * str,char * str1,int nr){
    if(nr==0){
        //basic variable
        contain[count].id=strdup(str1);
        contain[count].tip=strdup(str);
        contain[count].constant =0;
        contain[count].func_type =0;
        }
        else if(nr ==1){
        //constant variable
        contain[count].id=strdup(str1);
        contain[count].tip=strdup(str);
        contain[count].constant =1;
        contain[count].func_type =0;

    }else{ 
        //function
        int p =getPositionFunction(str);
        if(p==-1){
            accept=0;
            return;
        }
        contain[count].tip= strdup(functions[p].type);
        contain[count].id=strdup(str1);
        contain[count].constant =0;
        contain[count].func_type =1;
    }
    ++count;

}
void declare(int nr,char * type, char * name, int value, char * str,int init, int constant, int scope, int func_type);
int getPosition(char * name,int scope);
//nr_functii reprezinta in ce functie suntem la momentul curent
int isDeclared(char * name,int declare,int scope){
    if(k==0 && declare==1){
        return -1;
    }
    for(int i=0;i<k;i++){
        if(strcmp(name,functions[scope].vars[i].name)==0){
            return i;
        }
    }
    return -1;
}



void declare(int nr,char * type, char * name,int value,char * str, int init,int constant,int scope, int func_type){
    if(accept==1){
 struct filter filt={0,0,0,0,0};
    if(init==1){
        if(nr==0){
            filt.integer = 1;
        }else if(nr ==1){
            filt.boolean = 1; 
        }else if(nr==2){
            filt.character =1;
        }else if(nr==3){
            filt.string =1;
        }else if (nr ==4){
            filt.floating=1;
        }
    }

        int declared = 0;
        int sameValue=0;
        int p = getPosition(name,scope);
        if(p!=-1){
            declared=1;
        }
        if(declared==0){
            if(init==1){
                
                if(func_type==0){
                    functions[scope].vars[k].func_type=0;    
                    if(strcmp(type,"int")==0){
                            if(filt.integer==1){
                                functions[scope].vars[k].changed=1;
                                sameValue=1;
                                functions[scope].vars[k].value=value;
                            }   
                    }
                    else if(strcmp(type,"bool")==0){
                        if(filt.integer==1)
                        {
                            if(value==0||value==1){
                                functions[scope].vars[k].value=value;
                                functions[scope].vars[k].changed=1;
                                sameValue=1;
                            }
                        }
                    }
                    else if(strcmp(type,"char")==0){
                        if(filt.character==1){
                            sameValue=1;
                            functions[scope].vars[k].changed=1;
                            functions[scope].vars[k].str = strdup(str);
                        }
                    }
                    else if(strcmp(type,"string")==0){
                        if(filt.string==1){
                            sameValue=1;
                            functions[scope].vars[k].changed=1;
                            functions[scope].vars[k].str = strdup(str);
                        }
                    }
                    else if(strcmp(type,"float")==0){
                        if(filt.floating==1){
                            sameValue=1;
                            functions[scope].vars[k].changed=1;
                        }
                    }
                }
                else{
                    sameValue=1;
                    functions[scope].vars[k].name=strdup(name);
                    functions[scope].vars[k].type = strdup(type);
                    functions[scope].vars[k].func_type=1;    
                    ++k;
                }
                if(sameValue){
                    functions[scope].vars[k].name=strdup(name);
                    functions[scope].vars[k].type = strdup(type);
                    functions[scope].vars[k].constant = constant;
                    functions[scope].vars[k].func_type=0;    
                    ++k;
                
                }
            }
            else{
                sameValue=1;
                functions[scope].vars[k].func_type = 0;
                functions[scope].vars[k].name=strdup(name);
                functions[scope].vars[k].type = strdup(type);
                ++k;
                
            }
        }
    functions[scope].nr_vars=k;
        if(declared==1){
            accept=0;
            printf("LineNo: %d : \n",yylineno);
            printf("\tRedefinition of %s\n",name);
        }
        else if(sameValue==0){
            accept=0;
            printf("LineNo: %d : \n",yylineno);
            printf("\tCan't assing  %s\n",name);
        }
    }
}
int getPosition(char * name,int scope){
    for(int i =0 ;i<functions[scope].nr_vars;i++){
        
        if(strcmp(name,functions[scope].vars[i].name)==0){
            return i;
        }
    }    
    return -1;
}
int getValue(char * name,int scope){
    if(accept==1){
    int position =getPosition(name,scope);
    if(position==-1){
        accept = 0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No declaration of %s\n",name);
        return -1;
    }
   
    else if(strcmp(functions[scope].vars[position].type,"int")!=0){
        accept =0 ;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No matching type\n" );
        return -1;
    }
    else{
        return functions[scope].vars[position].value;
    }
    }else
        return -1;
}
int decr_incr( char * name ,int nr,int scope){
    int position = getPosition(name,scope);
    if(position==-1){
        accept = 0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No declaration of %s\n",name);
        return -1;
    }else{
        if(strcmp(functions[scope].vars[position].type,"int")==0){
            if(nr==0){
                functions[scope].vars[position].value +=1;
            }
            else{
                functions[scope].vars[position].value -=1;
            }
            return functions[scope].vars[position].value;
        }
        else{
            accept =0 ;
            printf("LineNo: %d : \n",yylineno);
            printf("\t-Identifier %s must have an integer type\n",name);
            return -1;
        }
    }
    return -1;
}   
void assignment(char * name,  int value , char * str,int nr,int scope){
    if(accept==1){
    struct filter filt={0,0,0,0,0};
    if(nr==0){
            filt.integer = 1;
        }else if(nr ==1){
            filt.boolean = 1; 
        }else if(nr==2){
            filt.character =1;
        }else if(nr==3){
            filt.string =1;
        }else if (nr ==4){
            filt.floating=1;
        }
    int position=getPosition(name,scope);
    if(position==-1){
        accept =0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No declaration of %s\n",name);
    }
    else{
        int someValue = 0;
        if(strcmp(functions[scope].vars[position].type,"int")==0){
            if(nr==0){
                someValue=1;
                functions[scope].vars[position].value=value;
                functions[scope].vars[position].changed=1;
            }
        }   
        else if (strcmp(functions[scope].vars[position].type,"string")==0){
            if(nr==1){
                someValue=1;
                functions[scope].vars[position].str= strdup(str);
                functions[scope].vars[position].changed=1;
functions[scope].vars[position].str=functions[scope].vars[position].str+1;
int len=strlen(functions[scope].vars[position].str);
strcpy(functions[scope].vars[position].str+len-1,functions[scope].vars[position].str+len);

            }
        }
        else if (strcmp(functions[scope].vars[position].type,"string")==0){
            if(nr==2){
                someValue=1;
                functions[scope].vars[position].str= strdup(str);
                functions[scope].vars[position].changed=1;
            }
        }else if (strcmp(functions[scope].vars[position].type,"float")==0){
            if(nr==3){
                someValue=1;
                functions[scope].vars[position].changed=1;
            }
        }
        else if (strcmp(functions[scope].vars[position].type,"char")==0){

            if(nr==4){

                someValue=1;
                functions[scope].vars[position].str= strdup(str);
            }
        }
        else if (strcmp(functions[scope].vars[position].type,"bool")==0){
            if(nr==0){
                if(value==0||value==1){
                    someValue=1;
                    functions[scope].vars[position].str= strdup(str);
                }
            }
        }

        if(someValue==0){
            accept = 0;
            printf("LineNo: %d : \n",yylineno);
            printf("Types don't match\n");
        }
    }
    }
}
char * getStringval(char * name,int scope){
    int position =getPosition(name,scope);
    if(position==-1){
        accept = 0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No declaration of %s\n",name);
        return "";
    }
    else if(functions[scope].vars[position].changed==0)
        {accept =0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No initialiazation of %s\n",name);
        return "";
    }
    else if(strcmp(functions[scope].vars[position].type,"string")!=0){
        accept =0 ;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No matching type\n" );
        return "";
    }
    else{
        return functions[scope].vars[position].str;
    }
}


int eq_str( char * id1, char *id2, int nr ,int scope){
    if(accept==1){
        if(nr==0){ // id id
            int p1 = getPosition(id1,scope);
            int p2 = getPosition(id2,scope);
            if(p1!=-1&&p2!=-1){
                if(strcmp(functions[scope].vars[p1].type,functions[scope].vars[p2].type)==0&&strcmp(functions[scope].vars[p1].type,"string")==0){
                    return strcmp(functions[scope].vars[p1].str,functions[scope].vars[p2].str);
                }
                else{
                    accept = 0;
                    printf("LineNo: %d : \n",yylineno);
                    printf("Identifiers don't have the same type\n");
                    return -1;
                }
            }
            else{
                accept =0;
                printf("LineNo: %d : \n",yylineno);
                printf("One of the values hasn't been declared\n");
                return -1;
            }
        }else if(nr==1){
            return (strcmp(id1,id2));//str str
        }else if(nr==2){ //id str
            int p1 = getPosition(id1,scope);
            if(p1!=-1){
                if(strcmp(functions[scope].vars[p1].type,"string")==0){
                    return strcmp(functions[scope].vars[p1].str,id2);
                }
                else{
                    accept =0 ;
                    printf("LineNo: %d : \n",yylineno);
                    printf("Identifier doesn't have the same type\n");
                    return -1;
                }
            }
            else{
                accept=0;
                printf("LineNo: %d : \n",yylineno);
                printf("No initialization of %s",id1);
                return -1;
            }
        }else if(nr==3){ //str id
            int p2 = getPosition(id2,scope);
            if(p2!=-1){
                if(strcmp(functions[scope].vars[p2].type,"string")==0){
                    return strcmp(functions[scope].vars[p2].str,id1);
                }
                else{
                    accept =0 ;
                    printf("LineNo: %d : \n",yylineno);
                    printf("Identifier doesn't have the same type\n");
                    return -1;
                }
            }
            else{
                accept=0;
                printf("LineNo: %d : \n",yylineno);
                printf("No initialization of %s",id1);
                return -1;
            }
        }
    }
    else{return -1;}
}
int getPositionFunction(char * name){
     for(int i =0 ;i<f;i++){
        if(strcmp(name,functions[i].name)==0){
            return i;
        }
    }    
    return -1;
}
void push_var(char * str,char * str1,int nr){
    if(nr==0){
        //basic variable
        contain[count].id=strdup(str1);
        contain[count].tip=strdup(str);
        contain[count].constant =0;
        contain[count].func_type =0;
        }
        else if(nr ==1){
        //constant variable
        contain[count].id=strdup(str1);
        contain[count].tip=strdup(str);
        contain[count].constant =1;
        contain[count].func_type =0;

    }else{ 
        //function
        int p =getPositionFunction(str);
        if(p==-1){
            accept=0;
            return;
        }
        contain[count].tip= strdup(functions[p].type);
        contain[count].id=strdup(str1);
        contain[count].constant =0;
        contain[count].func_type =1;
    }
    ++count;

}

void eq_functions(int k,char * name, char * type ,int nr){
    // bag din container in functions la pozitia k 
    functions[k].name=strdup(name);
    functions[k].type=strdup(type);
    if(nr==0){
    for(int i =0;i<count;i++){
        functions[k].contain[i]=contain[i];
        functions[k].nr_args=count;
    }}
    else{
        functions[k].nr_args=0;
    }
  


}
void function_declaration( char * type, char * name ,int nr){
    if(accept==1){
    int p=getPositionFunction(name);
    if(p==-1){
        eq_functions(f,name,type,nr);
        ++f;

    }

    else{
        int ok=1;
        for(int i =0;i<f;i++){
            if((strcmp(functions[i].type,type)==0)&&(strcmp(functions[i].name,name)==0) ){
                if(functions[i].nr_args==count){
                 ok=0;
                for(int o=0;o<count;o++){
                
                if(strcmp(functions[i].contain[o].tip,contain[0].tip)!=0 )ok=1;
                }
                   if(ok==0){

                    break;
                    }
                }   
            }
        }
        if(ok==0){
            printf("LineNo: %d : \n",yylineno);
            printf("\t There is another function with the same number of parameters\n");
            accept=0;
        }
        else{
            eq_functions(f,name,type,nr);
        ++f;
        }
    }

        count=0;
    }
}

void check_function(char * name,int scope){
    int p=getPositionFunction(name);
    if(p==-1){
        printf("LineNo: %d : \n",yylineno);
        printf("\t There is no function in program with the name %s \n",name);
        accept = 0;
    }
    char * type = functions[p].type;
    functions[scope].vars[k].func_type = 1;
    functions[scope].vars[k].type = strdup(type);
    functions[scope].vars[k].name = strdup(name);
    ++k;
    functions[scope].nr_args = k; 
}
struct param_call{
    char *id ;
    int isType[5];
}p_call[100];
void push_param_call(char *str, int nr)
{
    for(int i =0;i<5;i++)
        p_call[count].isType[i]=0;
    p_call[count].isType[nr]=1;
    if(nr==0||nr==3){
        p_call[count].id=strdup(str);
    }
    ++count;
}



int check_function_id(char * str,int i, int j,int scope){
    int p =getPosition(str,scope);  

    if(p==-1){
        printf("LineNo: %d : \n",yylineno);
        printf("\t No initialization of  %s \n",str);
        accept=0;

        return -1;
    }
    

    str = functions[scope].vars[p].type;
     
    if(strcmp(functions[i].contain[j].tip,str)==0){

        return 1;
         
    }
     
    return -1;
}

int check_function_nr(int i,int j,int scope ){
    if(strcmp(functions[i].contain[j].tip,"bool")==0||
    strcmp(functions[i].contain[j].tip,"int")==0){
        return 1;
    }
    return -1;
}

int check_function_string(int i,int j,int scope){
    if(strcmp(functions[i].contain[j].tip,"string")==0
    ||strcmp(functions[i].contain[j].tip,"char")==0)
    {
        return 1;
    }
    return -1;
}

int check_function_float(int i,int j,int scope ){
    
    if(strcmp(functions[i].contain[j].tip,"float")==0){
        return 1;
    }
    return -1;
}

int check_function_fuc(char * str ,int i,int j,int scope){
    
    int p =1;
  
    p =getPositionFunction(str);
    if(p==-1){
        printf("LineNo: %d : \n",yylineno);
        printf("\t No initialization of  %s \n",str);
        accept=0;
        return -1;
    }
    str = functions[p].type;
    if(strcmp(functions[i].contain[j].tip,str)==0){
        return 1;
    }
    return -1;
}
void function_call(int scope,char* name){
     if(accept==1){
    int nr_args = count;
    int p = getPositionFunction(name);
    if(p==-1){
        printf("LineNo: %d : \n",yylineno);
        printf("\t There is no function in program with the name %s \n",name);
    }else{
      int less_args=0;
      int  bad_arg=0;
      for(int i=0;i<f;i++){
      if(functions[i].nr_args==nr_args && strcmp(functions[i].name,name)==0){
      less_args=1;
   
      for(int j =0 ;j<nr_args;j++){
 
                    if(p_call[j].isType[0])
                    {
                         
                        
                        if(check_function_id(p_call[j].id,i,j,scope)==-1){
                            bad_arg=1;
                            break;
                     
                    }
                 
                    }

                    if(p_call[j].isType[1]){
           
                        
                        if(check_function_nr(i,j,scope)==-1){
                            bad_arg=1;
                            break;
                        }

                    }

                    if(p_call[j].isType[2]){
                       
                     
                        if(check_function_string(i,j,scope)==-1){
                            bad_arg=1;
                            break;
                        }

                    }

                    if(p_call[j].isType[3]){
                
                        if(check_function_fuc(p_call[j].id,i,j,scope)==-1){
                            bad_arg=1;
                            break;
                        }

                    }
                    if(p_call[j].isType[4]){
                
                        if(check_function_float(i,j,scope)==-1){
                            bad_arg=1;
                            break;
                        }

                    

                }
                
            }
            if(bad_arg==1){
 printf("LineNo: %d : \n",yylineno);
            printf("\t Invalid matching argument of function %s \n",name);
            accept=0;

            }
      }
      }
      if(less_args==0){
 printf("LineNo: %d : \n",yylineno);
            printf("\t Invalid number of arguments %s \n",name);
            accept = 0;

      }
      }

    }


}
void check_id(char * str,int scope)
{
    int p =getPosition(str,scope);
    if(p==-1){
        printf("LineNo: %d : \n",yylineno);
        printf("No initialization of %s\n",str);
        accept=0;
    }
   
}
/*
void table_select(){
    int size;
    struct container{
    char *id ;
    char *tip;
    int constant;
    int func_type;
    int isId;
}contain[100];


    bzero(buf,sizeof(buf));
    sprintf(buf,"structs\n");
    size = strlen(buf);
    write(fd,buf,size);
    for(int i =0;i<nr_structs;i++){
        write(fd,"\t",1);
        bzero(buf,sizeof(buf));
        sprintf(buf,"%s \n", structs[i].name);
        size = strlen(buf);
        write(fd, buf,size);
     
        for(int j =0 ;j<structs[i].nr_vars;j++){
            write(fd,"\t",1);
            write(fd,"\t",1);
            if(structs[i].vars[j].constant){
                bzero(buf,sizeof(buf));
                sprintf(buf,"constant ");
                size = strlen(buf);//
                write(fd,buf,size);
            }

            if(structs[i].vars[j].func_type){
                bzero(buf,sizeof(buf));
                sprintf(buf,"function ");
                size = strlen(buf);//
                write(fd,buf,size);   
            }

            bzero(buf,sizeof(buf));
            sprintf(buf,"%s %s \n ",structs[i].vars[j].type,structs[i].vars[j].name);
            size = strlen(buf);
            write(fd,buf,size);
        }

    }

    write(fd,"\n",1);
    /printez functiile declarate
     bzero(buf,sizeof(buf));
    sprintf(buf,"classes\n");
    size = strlen(buf);
    write(fd,buf,size);
    for(int i =0;i<nr_classes;i++){
        write(fd,"\t",1);
        bzero(buf,sizeof(buf));
        sprintf(buf,"%s \n", classes[i].name);
        size = strlen(buf);
        write(fd, buf,size);
     
        for(int j =0 ;j<classes[i].nr_vars;j++){
            write(fd,"\t",1);
            write(fd,"\t",1);
            if(classes[i].vars[j].constant){
                bzero(buf,sizeof(buf));
                sprintf(buf,"constant ");
                size = strlen(buf);//
                write(fd,buf,size);
            }

            if(classes[i].vars[j].func_type){
                bzero(buf,sizeof(buf));
                sprintf(buf,"function ");
                size = strlen(buf);//
                write(fd,buf,size);   
            }

            bzero(buf,sizeof(buf));
            sprintf(buf,"%s %s \n ",classes[i].vars[j].type,classes[i].vars[j].name);
            size = strlen(buf);
            write(fd,buf,size);
        }

    }

    write(fd,"\n",1);
    
    
    ////printez functiile declaratte
    bzero(buf,sizeof(buf));
    sprintf(buf,"FUNCTIONS \n");
    size = strlen(buf);
    write(fd,buf,size);
    for(int i=0;i<f;i++){
        write(fd,"\t",1);
        bzero(buf,sizeof(buf));
        sprintf(buf,"%s %s ",functions[i].type, functions[i].name);
        size = strlen(buf);
        write(fd,buf,size);
        write(fd," (",2);

        for( int j =0 ;j<functions[i].nr_args-1;j++){

        bzero(buf,sizeof(buf));
        if(functions[i].contain[j].constant == 1 ){
            bzero(buf,sizeof(buf));
            sprintf(buf,"constant ");
            size = strlen(buf);
            write(fd,buf,size);
        }
        if(functions[i].contain[j].func_type ){
            bzero(buf,sizeof(buf));
            sprintf(buf,"function ");
            size = strlen(buf);
            write(fd,buf,size);
        }
            bzero(buf,sizeof(buf));
            sprintf(buf,"%s %s ,",functions[i].contain[j].tip,functions[i].contain[j].id);
            size = strlen(buf);
            write(fd,buf,size);
          
        }
        if(functions[i].nr_args>0){
        bzero(buf,sizeof(buf));
            sprintf(buf,"%s %s ",functions[i].contain[functions[i].nr_args-1].tip,functions[i].contain[functions[i].nr_args-1].id);
            size = strlen(buf);
            write(fd,buf,size);
        }

        write(fd,") \n",3);

    }
    ////////////variabile pentru fiecare functii 
    bzero(buf,sizeof(buf));
    sprintf(buf,"\nVariabile \n");
    size = strlen(buf);
    write(fd,buf,size);
    
    for(int i=0;i<f;i++){
        write(fd,"\t",1);
        bzero(buf,sizeof(buf));
        sprintf(buf,"%s \n ",functions[i].name);
        size = strlen(buf);
        write(fd,buf,size);
     
        for(int j =0;j<functions[i].nr_vars;j++){
        if(functions[i].vars[j].acces_type==0){
            write(fd,"\t",1);
            write(fd,"\t",1);
            if(functions[i].vars[j].constant){
                bzero(buf,sizeof(buf));
                sprintf(buf,"constant ");
                size = strlen(buf);//
                write(fd,buf,size);
            }

            if(functions[i].vars[j].func_type){
                bzero(buf,sizeof(buf));
                sprintf(buf,"function ");
                size = strlen(buf);//
                write(fd,buf,size);   
            }
            if(functions[i].vars[j].struct_type){
            bzero(buf,sizeof(buf));
            sprintf(buf,"struct " );
            size=strlen(buf);
            write(fd,buf,size);

            }
            if(functions[i].vars[j].vector_type){
   bzero(buf,sizeof(buf));
            sprintf(buf,"vector ");
            size=strlen(buf);
            write(fd,buf,size);

            }
            
            bzero(buf,sizeof(buf));
            sprintf(buf,"%s %s \n\n ",functions[i].vars[j].type,functions[i].vars[j].name);
            size = strlen(buf);
            write(fd,buf,size);

        }}

    }



    ////printez variabilile din fiecare functie
}

*/
int getPositionStruct( char * name ,int scope){
    for(int i=0;i<structs[scope].nr_vars;i++){
        if(strcmp(structs[scope].vars[i].name,name)==0){
            return i;
        }
    }
    return -1;
}

void init_struct(char * name){
    int declare =0;
    for(int i =0;i<nr_structs;i++){
        if(strcmp(structs[i].name,name)==0)
        {
            declare=1;
            break;
        }
    }
    if(declare ==1){
        printf("LineNo: %d : \n",yylineno);
        printf("\tRedefinition of struct %s\n",name);
    }
    else{
        structs[nr_structs].name=strdup(name);
        ++nr_structs;
    }
}
/*
int getPositionClass( char * name ,int scope){
    for(int i=0;i<classes[scope].nr_vars;i++){
        if(strcmp(classes[scope].vars[i].name,name)==0){
            return i;
        }
    }
    return -1;
}



void init_class(char * name){
    int declare =0;
    for(int i =0;i<nr_classes;i++){
        if(strcmp(classes[i].name,name)==0)
        {
            declare=1;
            break;
        }
    }
    if(declare ==1){
        printf("LineNo: %d : \n",yylineno);
        printf("\tRedefinition of struct %s\n",name);
    }
    else{
        classes[nr_classes].name=strdup(name);
        ++nr_classes;
    }
}
*/
void declare_struct(char * type, char * name,int value,char * str, int constant,int init,struct filter filt,int scope, int func_type);
void filter_struct(int nr,char * type, char * name, int value, char * str,int init, int constant, int scope, int func_type){
    if(accept==1){
    struct filter filt={0,0,0,0,0};
    if(init==1){
        if(nr==0){
            filt.integer = 1;
        }else if(nr ==1){
            filt.boolean = 1; 
        }else if(nr==2){
            filt.character =1;
        }else if(nr==3){
            filt.string =1;
        }else if (nr ==4){
            filt.floating=1;
        }
    }
    declare_struct(type,name,value,str,constant,init,filt,scope,func_type);

    }    }

void declare_struct(char * type, char * name,int value,char * str, int constant,int init,struct filter filt,int scope, int func_type){

    if(accept==1){
        int declared = 0;
        int sameValue=0;
        int p = getPositionStruct(name,scope);
        if(p!=-1){
            declared=1;
        }
        if(declared==0){
            if(init==1){
                
                if(func_type==0){
                    structs[scope].vars[count].func_type=0;    
                    if(strcmp(type,"int")==0){
                            if(filt.integer==1){
                                structs[scope].vars[count].changed=1;
                                sameValue=1;
                                structs[scope].vars[count].value=value;
                            }   
                    }
                    else if(strcmp(type,"bool")==0){
                        if(filt.integer==1)
                        {
                            if(value==0||value==1){
                                structs[scope].vars[count].value=value;
                                structs[scope].vars[count].changed=1;
                                sameValue=1;
                            }
                        }
                    }
                    else if(strcmp(type,"char")==0){
                        if(filt.character==1){
                            sameValue=1;
                            structs[scope].vars[count].changed=1;
                            structs[scope].vars[count].str = strdup(str);
                        }
                    }
                    else if(strcmp(type,"string")==0){
                        if(filt.string==1){
                            sameValue=1;
                            structs[scope].vars[count].changed=1;
                            structs[scope].vars[count].str = strdup(str);
                        }
                    }
                    else if(strcmp(type,"float")==0){
                        if(filt.floating==1){
                            sameValue=1;
                            structs[scope].vars[count].changed=1;
                        }
                    }
                }
                else{
                    sameValue=1;
                    structs[scope].vars[count].name=strdup(name);
                    structs[scope].vars[count].type = strdup(type);
                    structs[scope].vars[count].func_type=1;    
                    ++count;
                }
                if(sameValue){
                    structs[scope].vars[count].name=strdup(name);
                    structs[scope].vars[count].type = strdup(type);
                    structs[scope].vars[count].constant = constant;
                    structs[scope].vars[count].func_type=0;    
                    ++count;
                
                }
            }
            else{
                sameValue=1;
                structs[scope].vars[count].func_type = 0;
                structs[scope].vars[count].name=strdup(name);
                structs[scope].vars[count].type = strdup(type);
                ++count;
                
            }
        }
        if(declared==1){
            accept=0;
            printf("LineNo: %d : \n",yylineno);
            printf("\tRedefinition of %s\n",name);
        }
        else if(sameValue==0){
            accept=0;
            printf("LineNo: %d : \n",yylineno);
            printf("\tCan't assing  %s\n",name);
        }
    }
    structs[scope].nr_vars=count;
}
int position_struct (char * name ){

  for(int i=0;i<nr_structs;i++){
  if(strcmp(structs[i].name,name )==0 )return i;

  }
return -1;

}
/*
void declare_class(char * type, char * name,int value,char * str, int constant,int init,struct filter filt,int scope, int func_type);
void filter_class(int nr,char * type, char * name, int value, char * str,int init, int constant, int scope, int func_type){
    if(accept==1){
    struct filter filt={0,0,0,0,0};
    if(init==1){
        if(nr==0){
            filt.integer = 1;
        }else if(nr ==1){
            filt.boolean = 1; 
        }else if(nr==2){
            filt.character =1;
        }else if(nr==3){
            filt.string =1;
        }else if (nr ==4){
            filt.floating=1;
        }
    }
    declare_class(type,name,value,str,constant,init,filt,scope,func_type);

    }    }

void declare_class(char * type, char * name,int value,char * str, int constant,int init,struct filter filt,int scope, int func_type){

    if(accept==1){
        int declared = 0;
        int sameValue=0;
        int p = getPositionClass(name,scope);
        if(p!=-1){
            declared=1;
        }
        if(declared==0){
            if(init==1){
                
                if(func_type==0){
                    classes[scope].vars[count].func_type=0;    
                    if(strcmp(type,"int")==0){
                            if(filt.integer==1){
                                classes[scope].vars[count].changed=1;
                                sameValue=1;
                                classes[scope].vars[count].value=value;
                            }   
                    }
                    else if(strcmp(type,"bool")==0){
                        if(filt.integer==1)
                        {
                            if(value==0||value==1){
                                classes[scope].vars[count].value=value;
                                classes[scope].vars[count].changed=1;
                                sameValue=1;
                            }
                        }
                    }
                    else if(strcmp(type,"char")==0){
                        if(filt.character==1){
                            sameValue=1;
                            classes[scope].vars[count].changed=1;
                            classes[scope].vars[count].str = strdup(str);
                        }
                    }
                    else if(strcmp(type,"string")==0){
                        if(filt.string==1){
                            sameValue=1;
                            classes[scope].vars[count].changed=1;
                            classes[scope].vars[count].str = strdup(str);
                        }
                    }
                    else if(strcmp(type,"float")==0){
                        if(filt.floating==1){
                            sameValue=1;
                            classes[scope].vars[count].changed=1;
                        }
                    }
                }
                else{
                    sameValue=1;
                    classes[scope].vars[count].name=strdup(name);
                    classes[scope].vars[count].type = strdup(type);
                    classes[scope].vars[count].func_type=1;    
                    ++count;
                }
                if(sameValue){
                    classes[scope].vars[count].name=strdup(name);
                    classes[scope].vars[count].type = strdup(type);
                    classes[scope].vars[count].constant = constant;
                    classes[scope].vars[count].func_type=0;    
                    ++count;
                
                }
            }
            else{
                sameValue=1;
               classes[scope].vars[count].func_type = 0;
                classes[scope].vars[count].name=strdup(name);
               classes[scope].vars[count].type = strdup(type);
                ++count;
                
            }
        }
        if(declared==1){
            accept=0;
            printf("LineNo: %d : \n",yylineno);
            printf("\tRedefinition of %s\n",name);
        }
        else if(sameValue==0){
            accept=0;
            printf("LineNo: %d : \n",yylineno);
            printf("\tCan't assing  %s\n",name);
        }
    }
   classes[scope].nr_vars=count;
}
int position_class (char * name ){

  for(int i=0;i<nr_classes;i++){
  if(strcmp(classes[i].name,name )==0 )return i;

  }
return -1;

}

*/
void struct_declaration_func(char * name1 ,char * name2 ,int scope){
  int p;
  p=position_struct(name1);
  int q;
char names[100];
char nameback[100];
strcpy(nameback,strdup(name2));



  
  q=getPosition(name2,scope);
  if(q!=-1){
   accept = 0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-Already exists a declaration of %s\n",name2);
        return ;
  }else{
  if(p==-1){
   
        accept = 0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No declaration of %s\n",name1);
        return ;
    

  }else{

 functions[scope].vars[k].func_type = 0;
 functions[scope].vars[k].struct_type=1;
                functions[scope].vars[k].name=nameback;
                functions[scope].vars[k].type = strdup(name1);
                ++k;

                functions[scope].nr_vars=k;
for(int j=0;j<structs[p].nr_vars;j++){
                       if(structs[p].vars[j].func_type){
                       functions[scope].vars[k].func_type = 1;
                               functions[scope].vars[k].acces_type=1;
strcpy(names,nameback);
  strcat(names,".");
  strcat(names,structs[p].vars[j].name);
                functions[scope].vars[k].name=strdup(names);
                
                ++k;
                       }else{

                        if(structs[p].vars[j].struct_type){
                                functions[scope].vars[k].acces_type=1;
                       functions[scope].vars[k].struct_type = 1;
strcpy(names,nameback);
  strcat(names,".");
  strcat(names,structs[p].vars[j].name);
                functions[scope].vars[k].name=strdup(names);
                
                ++k;}else{
                        functions[scope].vars[k].acces_type=1;
               functions[scope].vars[k].type=structs[p].vars[j].type;
strcpy(names,nameback);
  strcat(names,".");
  strcat(names,structs[p].vars[j].name);
                functions[scope].vars[k].name=strdup(names);
                
                ++k;
                }
                       }

                }
                    functions[scope].nr_vars=k;

               

  }

}

}

void struct_asg(char * name1,char * name2,int value,char * str,int nr,int scope){
    char * name;
    name=strdup(name1);
    strcat(name,".");
    strcat(name,strdup(name2));
    assignment(name,value,str,nr,scope);

}



/*
void class_declaration_func(char * name1 ,char * name2 ,int scope){
  int p;
  p=position_class(name1);
  int q;
char names[100];
char nameback[100];
strcpy(nameback,strdup(name2));



  
  q=getPosition(name2,scope);
  if(q!=-1){
   accept = 0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-Already exists a declaration of %s\n",name2);
        return ;
  }else{
  if(p==-1){
   
        accept = 0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-No declaration of %s\n",name1);
        return ;
    

  }else{

 functions[scope].vars[k].func_type = 0;
 functions[scope].vars[k].class_type=1;
                functions[scope].vars[k].name=nameback;
                functions[scope].vars[k].type = strdup(name1);
                ++k;

                functions[scope].nr_vars=k;
for(int j=0;j<classes[p].nr_vars;j++){
                       if(classes[p].vars[j].func_type){
                       functions[scope].vars[k].func_type = 1;
                               functions[scope].vars[k].acces_type=1;
strcpy(names,nameback);
  strcat(names,".");
  strcat(names,classes[p].vars[j].name);
                functions[scope].vars[k].name=strdup(names);
                
                ++k;
                       }else{

                        if(classes[p].vars[j].class_type){
                                functions[scope].vars[k].acces_type=1;
                       functions[scope].vars[k].class_type = 1;
strcpy(names,nameback);
  strcat(names,".");
  strcat(names,classes[p].vars[j].name);
                functions[scope].vars[k].name=strdup(names);
                
                ++k;}else{
                        functions[scope].vars[k].acces_type=1;
               functions[scope].vars[k].type=classes[p].vars[j].type;
strcpy(names,nameback);
  strcat(names,".");
  strcat(names,classes[p].vars[j].name);
                functions[scope].vars[k].name=strdup(names);
                
                ++k;
                }
                       }

                }
                    functions[scope].nr_vars=k;

               

  }

}

}

void class_asg(char * name1,char * name2,int value,char * str,int nr,int scope){
    char * name;
    name=strdup(name1);
    strcat(name,",");
    strcat(name,strdup(name2));
    assignment(name,value,str,nr,scope);

}


*/

void vector_dec_func(char * type,char* name,int nr,int scope){

    int g;
    char buff[100];
    g=getPosition(name,scope);
strcpy(buff,name);
    if(g!=-1){
     accept = 0;
        printf("LineNo: %d : \n",yylineno);
        printf("\t-Already exists a declaration of %s\n",buff);
        return ;
        }else{
 functions[scope].vars[k].vector_type = 1;

                functions[scope].vars[k].name=strdup(buff);
                functions[scope].vars[k].type = strdup(type);
                ++k;

                functions[scope].nr_vars=k;
                for(int i=0;i<nr;i++){
                bzero(buff,strlen(buff));
                sprintf(buff,"%s.%d",name,i);
                 functions[scope].vars[k].name=strdup(buff);
                 functions[scope].vars[k].acces_type=1;
                functions[scope].vars[k].type = strdup (type);
                ++k;
                }

 functions[scope].nr_vars=k;
        }

}
void vector_asg(char * name,int number,int value,char * str,int nr,int scope){
   char buff[100];
   bzero(buff,strlen(buff));
   sprintf(buff,"%s.%d",name,number);
    assignment(buff,value,str,nr,scope);

}
int getValueVec(char * name1,int nr,int scope){
    
    char buff[100];
    bzero(buff,strlen(buff));
    sprintf(buff,"%s.%d",name1,nr);
    return getValue(buff,scope);
}
%}

%token EQ_STR PRINT_STR STR_ATRIB  TO  STRUCT_ID VECID FLOATVAL CHARVAL FALSE TRUE DOT FLOAT BOOL CHAR INT STRINGTYPE  STRING ID BOPN BCLS SEMIC EQ NUMBER CONST POPN PCLS COMMA MAIN IF ELSE WHILE FOR LO GT LOEQ GTEQ EQUAL STRUCT NOTEQ AND OR NOT PLUS MINUS DIV MUL ENDIF ENDWHILE ENDFOR DECR INCR FUNCTION FUNC_ID PRINT CALL VECTOR RETURN  CLASS_ID CLASS 
%start start\
%left AND
%left OR
%left PLUS MINUS
%left MUL DIV
%left NOT
%left LO LOEQ GT GTEQ  EQUAL 
%union
{
    int num;
    char* str;
}
%type <num> boolval expr NUMBER print  string_eq condition 
%type <str> ID FLOAT INT BOOL CHAR STRING tip STRINGTYPE CHARVAL VECID param_call FUNC_ID STRUCT_ID CLASS_ID
%%
start : progr {isAccepted();}

progr : functions  main
      | sorc functions main
      | sorc main
      | main 
      ;
      
sorc : classes sorc
     |  structs  sorc
     |  classes 
     |  structs
     ;

      
functions : functions functie
        | functie
        ;

structs : structs  struct
        | struct
        ;
struct : STRUCT STRUCT_ID BOPN add_var_struct BCLS {init_struct($2);count=0;}
      | STRUCT STRUCT_ID BOPN BCLS {init_struct($2);count =0;}
      ;

add_var_struct : add_var_struct  add_struct
     | add_struct 
     ;

add_struct : tip ID  {filter_struct(-1,$1,$2,0,"",0,0,nr_structs,0);}
|tip ID EQ expr  {filter_struct(0,$1,$2,$4,"",1,0,nr_structs,0);}
| tip ID EQ CHARVAL {filter_struct(2,$1,$2,0,$4,1,0,nr_structs,0);}
| tip ID EQ STRING  {filter_struct(3,$1,$2,0,$4,1,0,nr_structs,0);}
| tip ID EQ FLOATVAL {filter_struct(4,$1,$2,0,"",1,0,nr_structs,0);}
| CONST tip ID  {filter_struct(-1,$2,$3,0,"",0,1,count,0);}
| CONST tip ID EQ expr {filter_struct(0,$2,$3,$5,"",1,1,nr_structs,0);}
| CONST tip ID EQ CHARVAL {filter_struct(2,$2,$3,0,$5,1,1,nr_structs,0);}
| CONST tip ID EQ STRING {filter_struct(3,$2,$3,0,$5,1,1,nr_structs,0);}
| CONST tip ID EQ FLOATVAL {filter_struct(4,$2,$3,0,"",1,1,nr_structs,0);}
| VECTOR tip VECID {}
| VECTOR tip VECID ':' '['list ']' {}
| VECTOR tip VECID ':' '['']' {}
;

classes : classes class
      | class
      ;


class : CLASS CLASS_ID BOPN add_var_class BCLS {}
       | CLASS CLASS_ID BOPN BCLS {}
       ;
       
 add_var_class :   add_class add_var_class
         ;
   
 add_class:   tip ID  {}
|tip ID EQ expr  {}
| tip ID EQ CHARVAL {}
| tip ID EQ STRING  {}
| tip ID EQ FLOATVAL {}
| CONST tip ID  {}
| CONST tip ID EQ expr {}
| CONST tip ID EQ CHARVAL {}
| CONST tip ID EQ STRING {}
| CONST tip ID EQ FLOATVAL {}
| VECTOR tip VECID {}
| VECTOR tip VECID ':' '['list ']' {}
| VECTOR tip VECID ':' '['']' {}
| functions {}
;  
               

functie : FUNCTION tip FUNC_ID POPN PCLS BOPN blocks BCLS {function_declaration($2,$3,1);++nr_functii;k=0;}
        |   FUNCTION tip FUNC_ID POPN parameters PCLS BOPN blocks BCLS {function_declaration($2,$3,0);
                                                                        functions[nr_functii].nr_vars=k;
                                                                        ++nr_functii;
                                                                        k=0;
                                                                            } 
        ;
parameters : param COMMA parameters 
           | param 

           ;

param :tip ID {declare(-1,$1,$2,0,"",0,0,nr_functii,0);push_str($1,$2,0);}
      | CONST tip ID {declare(-1,$2,$3,0,"",0,1,nr_functii,0); push_str($2,$3,1);}
      | FUNC_ID {check_function($1,nr_functii);push_str($1,"",3);}
      ;
function_call : CALL FUNC_ID POPN parameters_call PCLS {function_call(nr_functii,$2);count =0;}
              | CALL FUNC_ID POPN PCLS {function_call(nr_functii,$2);count=0;}
              ;
parameters_call : param_call COMMA parameters_call 
                | param_call 
                ;
param_call : ID {check_id($1,nr_functii);
                ;push_param_call($1,0);}
           | NUMBER {push_param_call("",1);}
           | STRING {push_param_call("",2);}
           | FUNC_ID {push_param_call($1,3);}
           | FLOATVAL {push_param_call("",4);}
           ;
boolval : FALSE {$$=0;}
        | TRUE {$$=1;}
        ;
      
tip : INT {$$=$1;}
    | FLOAT {$$=$1;}
    | BOOL {$$=$1;}
    | STRINGTYPE {$$=$1;}
    | CHAR {$$=$1;}
    ;

bgn_main :FUNCTION INT MAIN POPN args_main PCLS
         |FUNCTION INT MAIN POPN PCLS
         ;
args_main : parameters
          ;
main : bgn_main BOPN blocks BCLS {function_declaration("functionrq","main",1);count =0;++nr_functii;k=0;}
     | bgn_main BOPN BCLS {function_declaration("function","main",0);count =0;++nr_functii;k=0;}
     ;

blocks : block
       | blocks block
       ;
block : statements
      | print
      |   function_call
      ;
      
      
print: PRINT POPN  STRING COMMA expr PCLS {printf("%s %d \n",$3,$5);}
     


    
    
if_stmt :  IF POPN condition PCLS BOPN blocks BCLS ENDIF
      | IF POPN condition PCLS BOPN BCLS ENDIF
      | IF POPN condition PCLS BOPN blocks BCLS ELSE BOPN blocks BCLS ENDIF
      | IF POPN condition PCLS BOPN BCLS ELSE BOPN blocks BCLS ENDIF
      | IF POPN condition PCLS BOPN BCLS ELSE BOPN BCLS ENDIF
      ;

for_stmt : FOR statements TO op BOPN blocks BCLS ENDFOR
;

while_stmt : WHILE POPN condition PCLS BOPN blocks BCLS ENDWHILE
           ;

statements : expression_stmt 
          | if_stmt 
          | while_stmt 
          |for_stmt
          |return_stmt
          ;
return_stmt : RETURN op
            ;
 
expression_stmt : declaratie
                | assign
                ;

expr : expr PLUS expr {$$ = $1 + $3;}
     | expr MINUS expr {$$ = $1-$3;}
     | expr MUL expr {$$ = $1*$3;}
     | expr DIV expr {$$= $1/$3;}
     | POPN expr PCLS {$$=$2;}
     | ID {$$=getValue($1,nr_functii);}
     | VECID '['NUMBER ']' { $$=getValueVec($1,$3,nr_functii);} 
     | NUMBER {$$=$1;}
     | boolval {$$=$1;}
     | string_eq {$$=$1;}
     | expr AND expr {$$=$1&&$3;}
     | expr OR expr {$$=$1||$3;}
     | NOT expr {$$=!$2;}
     | expr LO expr {$$=$1<$3;}
     | expr GT expr {$$=$1>$3;}
     | expr GTEQ expr {$$=$1>=$3;}
     | expr LOEQ expr {$$=$1<=$3;}
     | expr EQUAL expr {$$=$1==$3;}
 
     ;
declaratie :tip ID  {declare(-1,$1,$2,0,"",0,0,nr_functii,0);}
           |tip ID EQ expr  {declare(0,$1,$2,$4,"",1,0,nr_functii,0);}
           | tip ID EQ CHARVAL {declare(2,$1,$2,0,$4,1,0,nr_functii,0);}
           | tip ID EQ STRING  {declare(3,$1,$2,0,$4,1,0,nr_functii,0);}
           | tip ID EQ FLOATVAL {declare(4,$1,$2,0,"",1,0,nr_functii,0);}
           | CONST tip ID  {declare(-1,$2,$3,0,"",0,1,nr_functii,0);}
           | CONST tip ID EQ expr {declare(0,$2,$3,$5,"",1,1,nr_functii,0);}
           | CONST tip ID EQ CHARVAL {declare(2,$2,$3,0,$5,1,1,nr_functii,0);}
           | CONST tip ID EQ STRING {declare(3,$2,$3,0,$5,1,1,nr_functii,0);}
           | CONST tip ID EQ FLOATVAL {declare(4,$2,$3,0,"",1,1,nr_functii,0);}
           | STRUCT_ID ID {struct_declaration_func($1,$2,nr_functii);}
           | CLASS_ID ID {}
           | VECTOR tip VECID '[' NUMBER ']'{vector_dec_func($2,$3,$5,nr_functii);}
           | VECTOR tip VECID ':' '['list ']' {}
           | VECTOR tip VECID ':' '['']' {}
           ;





assign : ID EQ expr {assignment($1,$3,"",0,nr_functii);}
       | ID EQ STRING {assignment($1,0,$3,1,nr_functii);}
       | ID EQ FLOATVAL {assignment($1,0,"",3,nr_functii);}
       | ID EQ CHARVAL {assignment($1,0,$3,4,nr_functii);}
       | ID INCR {decr_incr($1,0,nr_functii);}
       | ID DECR {decr_incr($1,1,nr_functii); }
       |INCR ID {decr_incr($2,0,nr_functii);}
       |DECR ID {decr_incr($2,1,nr_functii);}
        |STRUCT_ID  STR_ATRIB ID EQ expr{struct_asg($1 ,$3,$5,"",0,nr_functii);}
        |STRUCT_ID STR_ATRIB ID EQ CHARVAL{struct_asg($1 ,$3,0,$5,1,nr_functii);}
        |STRUCT_ID STR_ATRIB ID EQ STRING{struct_asg($1 ,$3,0,$5,3,nr_functii);}
         |CLASS_ID  STR_ATRIB ID EQ expr{}
        |CLASS_ID STR_ATRIB ID EQ CHARVAL{}
        |CLASS_ID STR_ATRIB ID EQ STRING{}
       |VECID '['NUMBER ']' EQ expr { vector_asg($1,$3,$6,"",0,nr_functii);   }
       ;

list : list COMMA op
     | op
     ;

string_eq : EQ_STR POPN ID COMMA ID PCLS {$$=eq_str($3,$5,0,nr_functii);} 
          | EQ_STR POPN STRING COMMA STRING PCLS {$$=eq_str($3,$5,1,nr_functii);} 
          | EQ_STR POPN ID COMMA STRING PCLS {$$=eq_str($3,$5,2,nr_functii);} 
          | EQ_STR POPN STRING COMMA ID PCLS  {$$=eq_str($3,$5,3,nr_functii);} 
          ;


condition : expr {if(accept==1){$$=$1;}}
          ;
op : ID
   | NUMBER
   | STRING
   | CHARVAL
   | FLOATVAL
   | boolval
   ;
%%
int yyerror(char * s){
    printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){

    yyin=fopen(argv[1],"r");
    yyparse();
    
} 