/*void gcd(int* x, int* y){

    while(*x!=*y)
    {
        if(*x > *y)
            *x -= *y;
        else
            *y -= *x;
    }
}*/
int main() {
	extern int div1, div2; //32-bit
	extern int _test_start; //32-bit
    while(div1!=div2)
    {
        if(div1 > div2)
            div1 -= div2;
        else
            div2 -= div1;
    }
	//gcd(div1,div2);
	
	*(&_test_start) = div1;
	return 0;
}