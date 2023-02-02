#include "symtab.h"
#include <iostream>
#include <queue>

using namespace std;

const char* vname[] = {"Int", "Float", "Bool", "String", "Void","Array"}; 
const char* ename[] = {"Constant", "Variable", "Argument", "Function"}; 

Node::Node()
{
	this->val = false;
	this->constant = false;
	this->value = 0;
	this->value_string ="";
	this->func = false;
	this->next = NULL;
	this->num = 0;
}

Node::Node(const string id, const EntryType etype, ValueType vtype)
{
	this->identifier = id;
	this->vtype = vtype;
	this->etype = etype;
	this->val = false;
	this->constant = false;
	this->value = 0;
	this->value_string ="";
        this->func = false;
	this->next = NULL;
	this->num = 0;

}


void Node::Node_print()
{
	cout << "Identifier's Name: " << this->identifier << "\neType: " << ename[this->etype] << "\nvType: " << vname[this->vtype] << endl;
}


string Node::getIdentifier()
{
   return this->identifier;
}
ValueType Node::getvType()
{
   return this->vtype;
}
void Node::seteType(EntryType etype)
{
   this->etype = etype;
}
EntryType Node::geteType()
{
   return this->etype;
}

Node* Node::getNext()
{
    return this->next;
}
void Node::setvType(ValueType vtype)
{
   this->vtype = vtype;
}
void Node::setVal(bool b)
{
   this->val = b;
}
bool Node::getVal()
{
   return this->val;
}
void Node::setConstant(bool b)
{
   this->constant = b;
}
bool Node::getConstant()
{
   return this->constant;
}
void Node::setValue(int i)
{
   this->value = i;
}
int Node::getValue()
{
   return this->value;
}
void Node::setValue_string(string s)
{
   this->value_string = s;
}
string Node::getValue_string()
{
   return this->value_string;
}
void Node::setFunc(bool b)
{
   this->func = b;
}
bool Node::getFunc()
{
   return this->func;
}
void Node::setNum(int n)
{
   this->num = n;
}
int Node::getNum()
{
   return this->num;
}
void Node::setAssign(bool b)
{
   this->assign = b;
}
bool Node::getAssign()
{
   return this->assign;
}
//-------------------------------------------
SymbolTable::SymbolTable()
{
   this->parent = NULL;
} 
SymbolTable* SymbolTable::creat()
{
  return new SymbolTable();
  
}

Node* SymbolTable::lookup(const string id)
{
   int index = hashf(id);
   
   map<int, Node*>::iterator it;
   it = this->symbolTable.find(index);
   if(it != this->symbolTable.end()){
      Node* n = this->symbolTable[index];	   
      while(n != NULL){
         if(n->getIdentifier() == id)
            return n;
	 n = n->next;
      }
   }

   return NULL;
}
bool SymbolTable::insert(Node* n)
{
   int index = hashf(n->getIdentifier());
   map<int, Node*>::iterator it = this->symbolTable.find(index);

   if(it == this->symbolTable.end()){
      this->symbolTable[index] = n;
      return true;
   }
   else{
      Node* start = this->symbolTable[index];

      while(start->next != NULL)
	      start = start->next;
      start->next = n;
      return true;
   }
   return false;
/*   pair<map<index, *Node>::iterator, bool> retPair;
   retPair = this->symbolTable.insert(pair<int, *Node>(index, n));
   if(retPair.second == true){
	cout << "Insert Successfully\n";
        return s;
   }
   else
	cout << "Insert Failure\n";
*/
}

void SymbolTable::dump()
{
   for(const auto& entry : this->symbolTable){
      Node* temp = entry.second;
      while(temp != NULL){
         cout << temp->getIdentifier() << "  " << ename[temp->geteType()] << " " <<  vname[temp->getvType()] << endl;
         temp = temp->getNext();
      }
   }
}
void SymbolTable::dump(SymbolTable* s)
{
   for(const auto& entry : s->symbolTable){
      Node* temp = entry.second;
      while(temp != NULL){
   printf("%-20s%-20s%-20s\n", temp->getIdentifier().c_str(), ename[temp->geteType()], vname[temp->getvType()]);
         //cout << temp->getIdentifier() << " " << temp->getType() << " " <<  temp->getScope() << endl;
         temp = temp->getNext();
      }
   }
}


int SymbolTable::hashf(const string id)
{
   int asciiSum = 0;
   for(int i=0; i< id.length(); i++){
       asciiSum += id[i];
   }
   return (asciiSum % KEY_MAX);
}

map<int, Node*>  SymbolTable:: getSymbolTable()
{
   return this->symbolTable;
}
SymbolTable* SymbolTable::getParent()
{
   return this->parent;
}

void SymbolTable::setParent(SymbolTable* parent)
{
   this->parent = parent;
}
vector<SymbolTable*> SymbolTable::getChilds()
{
   return this->childs;
}
void SymbolTable::addChilds()
{
   SymbolTable* temp = creat();
   temp->setParent(this);
   return this->childs.push_back(temp);
}
//-------------------------------------------

Symtab_list::Symtab_list(){
   
   this->head = creat();
   this->head->setParent(NULL);
   this->cur  = head;
}

void Symtab_list::push()
{ 
   this->cur->addChilds();
   // this->cur->getChilds().back()->setParent(this->cur);
   //cout << "1:--------------------" <<this->cur->getParent() << endl;
   this->cur = this->cur->getChilds().back();
   
}
void Symtab_list::pop()
{
   this->cur = this->cur->getParent();
}

Node* Symtab_list::lookup_token(const string id)
{
   SymbolTable* temp = this->cur;  
   while(temp != NULL){
      Node* n = temp->lookup(id);
      if(n == NULL ){
         temp = temp->getParent();
      }else{
         return n;
      }
   }

   return NULL;
}
bool Symtab_list::insert_token(Node* ti)
{
   return this->cur->insert(ti);
}
void Symtab_list::dump_all()
{
   int count = 1;
   queue<SymbolTable*> symtab_queue;
   symtab_queue.push(this->head);
   cout << "--------------------------------------------------\n";
   printf("%-20s%-20s%-20s\n", "Name", "eType", "vType");
   while(!symtab_queue.empty()){
      cout << "Symbol Table "<< count++ << ":" << "-----------------------------------" << endl;
      SymbolTable* s = symtab_queue.front();
      if(!s->getChilds().empty()){     
         for(const auto& symtab : s->getChilds()){
            symtab_queue.push(symtab);
	 }
      }
      symtab_queue.pop();    
      dump(s);
   }
}
