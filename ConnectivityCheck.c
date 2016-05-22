// This is a mex/C script to simplify and speed up a thinning opperation
#include "mex.h"
#include "matrix.h"
#include "stdlib.h"
#include "stdint.h"
#include "string.h"

#define IS_REAL_2D_FULL_UINT8(P) (!mxIsComplex(P) && \
        mxGetNumberOfDimensions(P) == 2 && !mxIsSparse(P) && mxIsUint8(P) )

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    //Input is unit8 matrix. Output is same size uint8 matrix to delete
    //Acquire and comfirm inputs/outputs
    //Pad with zeros around
    //loop through elements, pull the local 3x3, perform connectivity check
    //write to delete as 1 true, leave alone as 0 false
    #define A_IN prhs[0]
    #define X_OUT plhs[0]
    mxArray *A, *X, *PAD, *padSize, *toPad[2]; 
    padSize = mxCreateNumericMatrix( 1, 2, mxUINT8_CLASS, mxREAL );
    int M, N, m, n, *vals;
    vals[0] = 1; vals[1] = 1; mxSetData( padSize, vals );
    
    if( nrhs != 1 )
        mexErrMsgTxt("Wrong number of input arguments.");
    else if( nlhs != 1 )
        mexErrMsgTxt("Wrong number of output arguments.");
    if( !IS_REAL_2D_FULL_UINT8( A_IN ) )
        mexErrMsgTxt("Input must be uint8, not sparse, and 2D real.");
    
    M = mxGetM(A_IN);
    N = mxGetN(A_IN);
    A = (mxArray*)mxGetPr(A_IN);
    X = (mxArray*)mxGetPr(X_OUT);
    X = mxCreateNumericMatrix( 0, 0, mxUINT8_CLASS, mxREAL );
    mxSetM( X, M+2 );
    mxSetN( X, N+2 );
    mxSetData( X, mxMalloc( sizeof(uint8_t)*(M+2)*(N+2) ) );
    PAD = mxCreateNumericMatrix( 0, 0, mxUINT8_CLASS, mxREAL );
    mxSetM( PAD, M+2 );
    mxSetN( PAD, N+2 );
    mxSetData( PAD, mxMalloc( sizeof(uint8_t)*(M+2)*(N+2) ) );
    toPad[0] = A; toPad[1] = padSize;
    mexCallMATLAB( 1, &PAD, 2, toPad, "padarray" );
    memcpy( mxGetPr(X), PAD, sizeof(uint8_t)*(M+2)*(N+2) );
    
    return;
}

