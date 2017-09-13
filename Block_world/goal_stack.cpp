#include<bits/stdc++.h>

using namespace std;

enum Action { unstack,stack,pickup,putdown };

class action{
public:
    Action type;
    string X;
    string Y;
    action(Action t, string box){
        type = t;
        X = box;
    }
    action(Action t, string box1,string box2){
        type = t;
        X = box1;
        Y = box2;
    }
}

enum Predicate { on,ont,cl,hold,ae };

class predicate{
public:
    Predicate type;
    string X;
    string Y;
    predicate(Predicate t){
        type = t;
    }
    predicate(Predicate t, string box){
        type = t;
        X = box;
    }
    predicate(Predicate t, string box1, string box2){
        type = t;
        X = box1;
        Y = box2;
    }
}

class stack_element{
public:
    int type;  // 0 for predicate 1 for action
    predicate p;
    action a;
}

vector<predicate> getPreList(action a){
    vector<predicate> v;
    switch(a.type){
        case stack: 
                predicate p1(cl,a.Y);
                predicate p2(hold,a.X);
                v.push_back(p1);
                v.push_back(p2);
                break;
        case unstack: 
                predicate p1(on,a.X,a.Y);
                predicate p2(cl,a.X);
                predicate p3(ae);                
                v.push_back(p1);
                v.push_back(p2);
                v.push_back(p3);                
                break;
        case pickup: 
                predicate p1(ont,a.X);
                predicate p2(cl,a.X);
                predicate p3(ae);                
                v.push_back(p1);
                v.push_back(p2);
                v.push_back(p3);                
                break;
        case putdown: 
                predicate p1(hold,a.X);
                v.push_back(p1);
                break; 
    }
    return v;
}



vector<predicate> getDelList(action a){
    vector<predicate> v;
    switch(a.type){
        case stack: 
                predicate p1(cl,a.Y);
                predicate p2(hold,a.X);
                v.push_back(p1);
                v.push_back(p2);
                break;
        case unstack: 
                predicate p1(on,a.X,a.Y);
                predicate p3(ae);                
                v.push_back(p1);
                v.push_back(p3);                
                break;
        case pickup: 
                predicate p1(ont,a.X);
                predicate p3(ae);                
                v.push_back(p1);
                v.push_back(p3);                
                break;
        case putdown: 
                predicate p1(hold,a.X);
                v.push_back(p1);
                break; 
    }
    return v;
}


vector<predicate> getAddList(action a){
    vector<predicate> v;
    switch(a.type){
        case stack: 
                predicate p1(ae);
                predicate p2(on,a.X,a.Y);
                v.push_back(p1);
                v.push_back(p2);
                break;
        case unstack: 
                predicate p1(hold,a.X);
                predicate p3(cl,a.Y);                
                v.push_back(p1);
                v.push_back(p3);                
                break;
        case pickup: 
                predicate p1(hold,a.X);
                v.push_back(p1);
                break;
        case putdown: 
                predicate p1(ont,a.X);
                predicate p2(ae);
                v.push_back(p1);
                v.push_back(p2);
                break; 
    }
    return v;
}

void solve(vector<stack_element>)







int main(){



}