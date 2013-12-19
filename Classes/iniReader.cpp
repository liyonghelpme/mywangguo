#include <map>
#include <string>
#include <iostream>
#include "cocos2d.h"
using namespace cocos2d;
using namespace std;
const int INI_LINE_MAX=400;

map<string, string> *handleIni(const char *data, long size) {
    char line[INI_LINE_MAX];
    const char *start = data;
    bool finish = false;
    map<string, string> *nm = new map<string, string>();
    long count = 0;
    CCLog("handleIni %d", size);
    while(!finish && count < size) {
        CCLog("count %d %c", count, data[count]);
        int i = 0;
        while(start[0] == '\r' || start[0] == '\n') {
            start = start++;
            count++;
        }

        for(i=0; count < size; i++, count++) {
            //request neturl not matter \n \r 
            if(start[i] == '\n' || start[i] == '\r') {
                break;
            }
            line[i] = start[i];
        }
        if(count >= size)
            finish = true;

        start = start+i+1;
        count++;

        int end = i;
        
        char key[INI_LINE_MAX];
        char value[INI_LINE_MAX];
        for(i = 0; line[i] != '='; i++) {
            key[i] = line[i];
        }
        key[i]='\0';
        int j;
        i++;
        for(j=0; i < end; i++, j++) {
            value[j] = line[i];
        }
        value[j] = '\0';
        (*nm)[(char*)key] = (char*)value; 
        CCLog("key value %s %s", key, value);

        while(start[0] == '\r' || start[0] == '\n') {
            start = start++;
            count++;
        }
    }
    CCLog("finish handleIni");
    return nm;
}
