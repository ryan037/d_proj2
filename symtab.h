#ifndef SYMTAB_H
#define SYMTAB_H


#include <map>
#include <string>
#include <vector>
#include "values.h"

#define KEY_MAX 100

using namespace std;

class Node {
   string identifier;
   ValueType vtype;
   EntryType etype;
   Node* next;
   bool val;
   bool constant;
   bool func;
   bool assign; // new
   int value;
   int num;
   string value_string;
public:
   vector<ValueType> func_para;
   Node();
   Node(const string id, const EntryType etype, const ValueType vtype);
   void Node_print();
   string getIdentifier();
   ValueType getvType();
   EntryType geteType();
   Node* getNext();
   
   void seteType(EntryType etype);
   void setvType(ValueType vtype);
   void setVal(bool b);
   void setRet(bool b);
   void setConstant(bool b);
   void setValue(int v);
   void setValue_string(string s);
   void setFunc(bool b);
   void setNum(int n);
   void setAssign(bool b);

   bool getVal();
   bool getConstant();
   int  getValue();
   string  getValue_string();
   bool getFunc();
   int getNum();
   bool getAssign();
   friend class SymbolTable;
   
};


class SymbolTable
{
   map<int, Node*> symbolTable;
   SymbolTable* parent;
   vector<SymbolTable*> childs;  
public:
 
   SymbolTable();
//---------------------------------------------- 
   map<int, Node*>      getSymbolTable();
   SymbolTable*         getParent();
   vector<SymbolTable*> getChilds(); 
   void setParent(SymbolTable* parent);
   void addChilds();
//---------------------------------------------- 
   SymbolTable* creat();
   Node* lookup(const string id);
   bool insert(Node* n);
   int hashf(const string id);
   void dump();
   void dump(SymbolTable* s);
};

class Symtab_list : public SymbolTable
{
   SymbolTable* head;
   SymbolTable* cur;
   
public:
   Symtab_list();
   void pop();
   void push();
   Node* lookup_token(const string id);
   bool insert_token(Node* ti);
   void dump_all();
};

#endif
