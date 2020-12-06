#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int sensor[11];
int C, L, CMAX;
char buffer[3];

int decideMove() {
    return 0;
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

void printSensor(int len) {
    printf("Valores no Sensor:\n");
    for (int i = 0; i < len; i++) {
        printf("%d ", sensor[i]);
    }
    printf("\n");
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

    printSensor(nCounter);
}


int main() {

    int x, y;

    scanf("%d %d\n", &x, &y);
    scanf("%d %d\n", &L, &C);
    scanf("%d\n", &CMAX);

    printf("%d %d %d %d %d\n", x, y, L, C, CMAX);
    
    while(y < L) {
        readSensor(x);
        y++;
    }
    
    return 0;
}
