#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define S_POS 5

int sensor[11];
int C, L, CMAX;
char buffer[3];
char adress[4];

int decideMove() {

    if (sensor[S_POS-1] > 100 && sensor[S_POS+1] > 100) {
        return 0;
    }

    int fLeft = -1, fRight = 1;

    for (int i = 0; i < S_POS; i++) {
        if(sensor[i] > 100) {
            fLeft = 0;
            break;
        }
    }
    
    for (int i = S_POS+1; i < S_POS+6; i++) {
        if(sensor[i] > 100) {
            fRight = 0;
            break;
        }
    }

    if (fLeft != 0 && fRight == 0) {
        return fLeft;
    } 

    if (fLeft == 0 && fRight != 0) {
        return fRight;
    }

    if(fLeft != 0 && fRight != 0) {
        return 0;
    }

    return fLeft && fRight;
}

void printPos(int x, int y) {
    printf("POS: %.4d %.4d\n", x, y);
}

char readChar() {
    char c;
    scanf("%c", &c);
    return c;
}

void convertValue(int numChs, int index) {

    int converted = 0;
    int pow, digit;
    
    for (int i = 0; i < numChs; i++) {
        digit = buffer[i] - 48;
        pow = 1;
        for (int j = 0; j < numChs-i-1; j++) {
            pow = pow * 10;
        }
        converted += digit*pow;
    }

    sensor[index] = converted;
}

void convertString(int value, int numChars, char* adress) {
    int div = 1000;
    char c;
    for (int i = 0; i < numChars; i++) {
        c = (value/div) + 48;
        adress[i] = c;
        value = value % div;
        div = div/10;
    }
    adress[4] = 0;
}

void printPosition(int x, int y) {
    char strX[5];
    char strY[5];
    convertString(x, 4, strX);
    convertString(y, 4, strY);    
    printf("POS: %s %s\n", strX, strY);
}

void printSensor(int len) {
    printf("Valores no Sensor:\n");
    for (int i = 0; i < len; i++) {
        printf("%d ", sensor[i]);
    }
    printf("\n");
}

void readLine() {
    char crtChar;
    int bCounter = 0;

    do {
        crtChar = readChar();
        if (crtChar >= '0' && crtChar <='9'){
            buffer[bCounter] = crtChar;
            bCounter++;
        } 

    } while(crtChar != '\n' && crtChar != ' ');

    convertValue(bCounter, 0);
}

void readSensor(int X0) {
    char crtChar;
    int cCounter = 0, bCounter = 0, nCounter = 0;
    int inFlag = 0;

    do {
        
        crtChar = readChar();

        if (crtChar == ' ') {
            cCounter++;
            if (inFlag) {
                convertValue(bCounter, nCounter++);
                inFlag = 0;
                bCounter = 0;
            } 

        }

        else if (X0-5 <=cCounter && cCounter < X0+6) {
            buffer[bCounter] = crtChar;
            bCounter++;
            inFlag = 1;
        }

    } while (crtChar != '\n');

    //printSensor(nCounter);
}


int main() {

    int x, y;

    scanf("%d %d\n", &x, &y);
    scanf("%d %d\n", &C, &L);
    scanf("%d\n", &CMAX);

    //printf("%d %d %d %d %d\n", x, y, L, C, CMAX);
    readSensor(x);

    while(y < L-1) {
        readSensor(x);
        y++;
        x += decideMove();
        printPosition(x, y);
    }
    
    return 0;
}
