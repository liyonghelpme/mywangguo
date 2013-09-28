#include <map>
#include <string>
#include <iostream>
#include "cocos2d.h"
using namespace cocos2d;
using namespace std;
const int INI_LINE_MAX=400;

map<string, string> *handleIni(const char *data, long size) {
    printf("read File\n");
    for (int i = 0; i < size; i++) {
        printf("%c", data[i]);
    }
    char line[INI_LINE_MAX];
    //const char *start = data;
    bool finish = false;
    map<string, string> *nm = new map<string, string>();
    long count = 0;
    CCLog("handleIni %ld", size);
    while(!finish && count < size) {
        //CCLog("count %d %c", count, data[count]);
        int i;
        for(i=0; count < size; i++, count++) {
            if(data[count] == '\n') {
                break;
            }
            line[i] = data[count];
        }
        if(count >= size)
            finish = true;

        //start = start+i+1;
        //跳过最后的换行 或者 最后一个
        if(count < size)
            count++;

        int end = i;
        
        char key[INI_LINE_MAX];
        char value[INI_LINE_MAX];
        for(i = 0; line[i] != '=' && i < end; i++) {
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
    }
    CCLog("finish handleIni");
    return nm;
}
