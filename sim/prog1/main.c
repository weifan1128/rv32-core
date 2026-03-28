#include <stdint.h>
#include <stdio.h>

extern int array_size;
extern int _test_start;
extern unsigned int array_addr[];
int main() {
    int len = array_size;
    int *resArr = &_test_start;
    int j, key;
    for(int i = 0; i < array_size; i++)
        resArr[i] = array_addr[i];
    int *arr = resArr;
    for (int i = 1; i < array_size; i++) {
        key = arr[i];
        j = i - 1;
        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            j = j - 1;
        }
        arr[j + 1] = key;
    }
}